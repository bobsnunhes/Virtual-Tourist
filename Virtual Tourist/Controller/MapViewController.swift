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
    
    let photosSegue = "photosSegue"
    
    let pinID = "pin"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let initialLocation = CLLocation(latitude: 21.282778, longitude: -157.829444)
        
        mapView.delegate = self
    
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
        let sortDescriptor = NSSortDescriptor(key: "latitude", ascending: false)
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
        longGestureRecognizer.minimumPressDuration = 1.0
        
        mapView.addGestureRecognizer(longGestureRecognizer)
    }
    
    @objc func addAnnotation(gestureRecognizer: UIGestureRecognizer) {
        if gestureRecognizer.state == UIGestureRecognizerState.began {
            let touchPoint = gestureRecognizer.location(in: mapView)
            let newCoordinates = mapView.convert(touchPoint, toCoordinateFrom: mapView)
            
            let pin = Pin(context: dataController.viewContext)
            pin.latitude = newCoordinates.latitude
            pin.longitude = newCoordinates.longitude
            try? dataController.viewContext.save()
        }
    }
    
    func loadMapData() {
        for pin in fetchedResultsController.fetchedObjects! {
            let annotation = TouristAnnotation()
            annotation.coordinate.latitude = pin.latitude
            annotation.coordinate.longitude = pin.longitude
            annotation.indexPath = fetchedResultsController.indexPath(forObject: pin)
            mapView.addAnnotation(annotation)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == photosSegue {
            if let touristAnnotation = sender as? TouristAnnotation {
                if let pinPhotosViewController = segue.destination as? PinPhotosViewController {
                    pinPhotosViewController.pin = fetchedResultsController.object(at: touristAnnotation.indexPath)
                    pinPhotosViewController.dataController = dataController
                }
            }
        }
    }
}

//MARK: Map View Delegate
extension MapViewController : MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if let touristAnnotation = view.annotation as? TouristAnnotation {
            
            mapView.deselectAnnotation(touristAnnotation, animated: true)
            
            performSegue(withIdentifier: photosSegue, sender: touristAnnotation)
        }
    }
    
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
extension MapViewController : NSFetchedResultsControllerDelegate {
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            if let pin = controller.object(at: newIndexPath!) as? Pin {
                let indexPath = fetchedResultsController.indexPath(forObject: pin)
                let annotation = TouristAnnotation()
                annotation.coordinate.latitude = pin.latitude
                annotation.coordinate.longitude = pin.longitude
                annotation.indexPath = newIndexPath!
                let pinAnnotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: pinID)
                mapView.addAnnotation(pinAnnotationView.annotation!)
            }
            
//            let pin = fetchedResultsController.object(at: newIndexPath!)
//            let annotation = TouristAnnotation()
//            annotation.coordinate.latitude = pin.latitude
//            annotation.coordinate.longitude = pin.longitude
//            annotation.indexPath = newIndexPath
//
//            let pinAnnotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: pinID)
//            mapView.addAnnotation(pinAnnotationView.annotation!)
            break
        case .delete:
            break
        default:
            ()
        }
    }

    
}
