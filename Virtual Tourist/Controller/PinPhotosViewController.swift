//
//  PinPhotosViewController.swift
//  Virtual Tourist
//
//  Created by roberto fernandes filho on 03/06/2018.
//  Copyright © 2018 Betocorporation. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import MapKit

class PinPhotosViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var photosCollectionView: UICollectionView!
    
    var dataController : DataController!
    var pin: Pin!
    var photosCollection : [Photo] = [Photo]()
    var flickrPhotos : [FlickrPhoto] = [FlickrPhoto]()
    var fetchedResultsController : NSFetchedResultsController<Photo>!
    let pinID = "pin"
    let cellID = "photoCell"

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupPinToMapView()
        
        setupFetchedResultsController()
        
        photosCollectionView.delegate = self
        photosCollectionView.dataSource = self
        
        if (fetchedResultsController.fetchedObjects?.count)! > 0 {
            photosCollection = fetchedResultsController.fetchedObjects!
        } else {
            loadPhotosFromFlickr()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setupFetchedResultsController()
        
        if let indexPaths = photosCollectionView.indexPathsForSelectedItems {
            if indexPaths.count > 0 {
                photosCollectionView.deselectItem(at: indexPaths.first!, animated: false)
            }
            
            photosCollectionView.reloadData()
        }
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        fetchedResultsController = nil
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        
        let width = floor(self.photosCollectionView.frame.size.width / 3)
        layout.itemSize = CGSize(width: width, height: width)
        photosCollectionView.collectionViewLayout = layout
    }
    
    func setupPinToMapView() {
        mapView.delegate = self
        
        let annotation = TouristAnnotation()
        annotation.coordinate.latitude = pin.latitude
        annotation.coordinate.longitude = pin.longitude
        mapView.addAnnotation(annotation)
        
        let regionRadius : CLLocationDistance = 500
        let coordRegion = MKCoordinateRegionMakeWithDistance(CLLocationCoordinate2D(latitude: pin.latitude, longitude: pin.longitude), regionRadius, regionRadius)
        mapView.setRegion(coordRegion, animated: true)
    }
    
    func setupFetchedResultsController() {
        let fetchRequest:NSFetchRequest<Photo> = Photo.fetchRequest()
        let predicate = NSPredicate(format: "pin == %@", pin)
        fetchRequest.predicate = predicate
        let sortDescriptor = NSSortDescriptor(key: "image", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: "\(pin)-photos")
        fetchedResultsController.delegate = self
        
        do {
        try fetchedResultsController.performFetch()
        } catch {
        fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
    }
    
    func loadPhotosFromFlickr() {
        FlickrClient.sharedInstance().getPhotosFromLocation(pin: pin) { (flickrPhotos, error) in
            if let error = error {
                print("loadPhotosFromFlickr error: \(error.localizedDescription)")
            } else {
                self.flickrPhotos = flickrPhotos!
                
                DispatchQueue.main.async {
                    self.photosCollectionView.reloadData()
                }
            }
        }
    }
}
//MARK: Collection View Delegate
extension PinPhotosViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if photosCollection.count > 0 {
            return photosCollection.count
        } else {
            return flickrPhotos.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var cellImage = UIImage()
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as! PhotosCollectionViewCell
        if photosCollection.count > 0 {
            cellImage = UIImage(data: photosCollection[indexPath.row].image!)!
            cell.imageView.image = cellImage
        } else if flickrPhotos.count > 0 {
            cell.startLoading()
            print("URL \(flickrPhotos[indexPath.row].url!)")
            FlickrClient.sharedInstance().taskForGETImage(url: flickrPhotos[indexPath.row].url!) { (data, error) in
                if error != nil {
                    print("taskForGETImage error: \(error?.localizedDescription ?? "")")
                } else {
                    if let data = data {
                        if let image = UIImage(data: data) {
                            DispatchQueue.main.async {
                                cell.imageView.image = image
                                let photo = Photo(context: self.dataController.viewContext)
                                photo.image = data
                                photo.pin = self.pin
                                try? self.dataController.viewContext.save()
                                cell.stopLoading()
                            }
                        }
                    }
                }
                
                
            }
        }
        return cell
    }
}


//MARK: Map View Delegate
extension PinPhotosViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let touristAnnotation = annotation as? TouristAnnotation {
            var pinAnnotationView = mapView.dequeueReusableAnnotationView(withIdentifier: pinID)
            if pinAnnotationView == nil {
                pinAnnotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: pinID)
            }
            
            pinAnnotationView?.annotation = touristAnnotation
            
            return pinAnnotationView
        }
        return nil
    }
}

//MARK: Fetched Results Controller Delegate
extension PinPhotosViewController: NSFetchedResultsControllerDelegate {
    
}
