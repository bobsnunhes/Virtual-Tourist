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
        mapView.isUserInteractionEnabled = false
        
        DispatchQueue.main.async {
            let annotation = TouristAnnotation()
            annotation.coordinate.latitude = self.pin.latitude
            annotation.coordinate.longitude = self.pin.longitude
            self.mapView.addAnnotation(annotation)
            
            let regionRadius : CLLocationDistance = 9999
            let coordRegion = MKCoordinateRegionMakeWithDistance(CLLocationCoordinate2D(latitude: self.pin.latitude, longitude: self.pin.longitude), regionRadius, regionRadius)
            self.mapView.setRegion(coordRegion, animated: true)
        }
        
    }
    
    func setupFetchedResultsController() {
        let fetchRequest:NSFetchRequest<Photo> = Photo.fetchRequest()
        let predicate = NSPredicate(format: "pin == %@", pin)
        fetchRequest.predicate = predicate
        let sortDescriptor = NSSortDescriptor(key: "image", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: "\(pin)-photos")
        
        
        do {
        try fetchedResultsController.performFetch()
        } catch {
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
    }
    
    func loadPhotosFromFlickr() {
        FlickrClient.sharedInstance().getPhotosFromLocation(pin: pin) { (flickrPhotos, error) in
            if let error = error {
                debugPrint("loadPhotosFromFlickr error: \(error.localizedDescription)")
            } else {
                DispatchQueue.main.async {
                    self.flickrPhotos.removeAll()
                    
                    self.flickrPhotos = flickrPhotos!
                    
                    self.photosCollectionView.reloadData()
                }
            }
        }
    }
    
    @IBAction func newCollectionAction(_ sender: Any) {
        if photosCollection.count > 0 {
            
            if flickrPhotos.count > 0 {
                flickrPhotos.removeAll()
            }
            
            for photo in photosCollection {
                dataController.viewContext.delete(photo)
                try? dataController.viewContext.save()
            }
            photosCollection.removeAll()
            
            DispatchQueue.main.async {
                self.photosCollectionView.reloadData()
            }
        }
        
        loadPhotosFromFlickr()
    }
    
}
//MARK: Collection View Delegate
extension PinPhotosViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        var count : Int!
        if photosCollection.count > 0 {
            count = photosCollection.count
        } else {
            count = flickrPhotos.count
        }
        
        return count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var cellImage = UIImage()
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as! PhotosCollectionViewCell
        
        if photosCollection.count > 0 {
            DispatchQueue.main.async {
                cell.imageView.backgroundColor = UIColor.yellow
                cellImage = UIImage(data: self.photosCollection[indexPath.row].image!)!
                cell.imageView.image = cellImage
                cell.isUserInteractionEnabled = true
            }
        } else if flickrPhotos.count > 0 {
            DispatchQueue.main.async {
                cell.imageView.backgroundColor = UIColor.yellow
                cell.startLoading()
            }
            
            debugPrint("URL = \(flickrPhotos[indexPath.row].url!)")
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
                                self.photosCollection.append(photo)
                                cell.isUserInteractionEnabled = true
                            }
                        }
                    }
                }
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if flickrPhotos.count > 0 {
            flickrPhotos.removeAll()
        }
        
        //Remove from Core Data
        let photo = photosCollection[indexPath.item]
        
        dataController.viewContext.delete(photo)
        try? dataController.viewContext.save()

        //remove from array
        if photosCollection.count > 0 {
            photosCollection.remove(at: indexPath.item)
        }
        
        collectionView.deleteItems(at: [indexPath])
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
