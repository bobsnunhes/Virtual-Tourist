//
//  MapViewController.swift
//  Virtual Tourist
//
//  Created by roberto fernandes filho on 31/05/2018.
//  Copyright © 2018 Betocorporation. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!

    var dataController : DataController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let initialLocation = CLLocation(latitude: 21.282778, longitude: -157.829444)
    
        centerMapOnLocation(location: initialLocation)
        
        addLongGestureRecognizer()
    }
    
    
    func centerMapOnLocation(location: CLLocation) {
        let regionRadius : CLLocationDistance = 1000
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, regionRadius, regionRadius)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    fileprivate func addLongGestureRecognizer() {
        let longGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(addAnnotation))
        longGestureRecognizer.minimumPressDuration = 2.0
        
        mapView.addGestureRecognizer(longGestureRecognizer)
    }
    
    @objc func addAnnotation(gestureRecognizer: UIGestureRecognizer) {
        if gestureRecognizer.state == UIGestureRecognizerState.began {
            let touchPoint = gestureRecognizer.location(in: mapView)
            let newCoordinates = mapView.convert(touchPoint, toCoordinateFrom: mapView)
            
            let virtualTourist = VirtualTourist(context: dataController.viewContext)
            virtualTourist.latitude = newCoordinates.latitude
            virtualTourist.longitude = newCoordinates.longitude
            virtualTourist.creationDate = Date()
            try? dataController.viewContext.save()
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = newCoordinates
            mapView.addAnnotation(annotation)
            
        }
    }
    
}
