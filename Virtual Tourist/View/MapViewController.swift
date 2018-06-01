//
//  MapViewController.swift
//  Virtual Tourist
//
//  Created by roberto fernandes filho on 31/05/2018.
//  Copyright © 2018 Betocorporation. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class MapViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!

    var dataController : DataController!
    
    var fetchedResultsController : NSFetchedResultsController<Pin>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let initialLocation = CLLocation(latitude: 21.282778, longitude: -157.829444)
    
        centerMapOnLocation(location: initialLocation)
        
        addLongGestureRecognizer()
        
        setupFetchedResultsController()
        
        loadMapData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setupFetchedResultsController()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        fetchedResultsController = nil
    }
    
    func setupFetchedResultsController() {
        let fetchRequest : NSFetchRequest<Pin> = Pin.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: "pins")
        
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("The fecth could not be performed: \(error.localizedDescription)")
        }
    }
    
    func centerMapOnLocation(location: CLLocation) {
        let regionRadius : CLLocationDistance = 1000
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, regionRadius, regionRadius)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    fileprivate func addLongGestureRecognizer() {
        let longGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(addAnnotation))
        longGestureRecognizer.minimumPressDuration = 1.5
        
        mapView.addGestureRecognizer(longGestureRecognizer)
    }
    
    @objc func addAnnotation(gestureRecognizer: UIGestureRecognizer) {
        if gestureRecognizer.state == UIGestureRecognizerState.began {
            let touchPoint = gestureRecognizer.location(in: mapView)
            let newCoordinates = mapView.convert(touchPoint, toCoordinateFrom: mapView)
            
            let pin = Pin(context: dataController.viewContext)
            pin.latitude = newCoordinates.latitude
            pin.longitude = newCoordinates.longitude
            pin.creationDate = Date()
            try? dataController.viewContext.save()
        }
    }
    
    func loadMapData() {
        for pin in fetchedResultsController.fetchedObjects! {
            let annotation = MKPointAnnotation()
            annotation.coordinate.latitude = pin.latitude
            annotation.coordinate.longitude = pin.longitude
            mapView.addAnnotation(annotation)
        }
    }
}

extension MapViewController : NSFetchedResultsControllerDelegate {
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            let pin = fetchedResultsController.object(at: newIndexPath!)
            let annotation = MKPointAnnotation()
            annotation.coordinate.latitude = pin.latitude
            annotation.coordinate.longitude = pin.longitude
            mapView.addAnnotation(annotation)
            break
        case .delete:
            break
        default:
            ()
        }
    }
    
}
