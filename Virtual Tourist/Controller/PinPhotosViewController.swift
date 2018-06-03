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
    var fetchedResultsController : NSFetchedResultsController<Photo>!
    let pinID = "pin"
    let cellID = "photoCell"

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupPinToMapView()
        
        setupFetchedResultsController()
        
        photosCollectionView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setupFetchedResultsController()
        
        if let indexPaths = photosCollectionView.indexPathsForSelectedItems {
            photosCollectionView.deselectItem(at: indexPaths[0], animated: false)
            photosCollectionView.reloadData()
        }
        
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
}
//MARK: Collection View Delegate
extension PinPhotosViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fetchedResultsController.sections?[0].numberOfObjects ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let photo = fetchedResultsController.object(at: indexPath)
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath)
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
