//
//  FlickrConvenience.swift
//  Virtual Tourist
//
//  Created by roberto fernandes filho on 03/06/2018.
//  Copyright © 2018 Betocorporation. All rights reserved.
//

import Foundation

extension FlickrClient {
    
    func getPhotosFromLocation(pin: Pin, completion: @escaping(_ result: [FlickrPhoto]?, _ error: NSError?) -> Void) {
        
        getMaxPhotoPagesFromLocation(pin: pin) { (numberOfPages, error) in
            if error != nil {
                print("Error \(error?.localizedDescription)")
            } else {
                if let pages = numberOfPages {
                    let params : [String:Any] = [ParameterKeys.PerPage: 10, ParameterKeys.Format : "json", ParameterKeys.Page : pages, ParameterKeys.Latitude : pin.latitude, ParameterKeys.Longitude : pin.longitude]
                    
                    let method = Methods.findPhotosByLocation
                    
                    let _ = self.taskForGETMethod(method, params: params as [String:AnyObject]) { (results, error) in
                        if let error = error {
                            completion(nil, error)
                        } else {
                            if let results = results as? [String:AnyObject] {
                                if let photosSection = results[FlickrClient.JSONResponseKeys.Photos] as? [String:AnyObject] {
                                    print("TOTAL = \(photosSection["total"])")
                                    if let photos = photosSection[FlickrClient.JSONResponseKeys.Photo] as? [[String:AnyObject]] {
                                        var flickrPhotos : [FlickrPhoto] = [FlickrPhoto]()
                                        for photo in photos {
                                            
                                            let flickrPhoto = FlickrPhoto.init(dic: photo)
                                            
                                            flickrPhotos.append(flickrPhoto)
                                        }
                                        completion(flickrPhotos, nil)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        
        
        
        
    }
    
    func getMaxPhotoPagesFromLocation(pin: Pin, completion: @escaping (_ numberOfPages: Int?, _ error: NSError?) -> Void) {
        let params : [String:Any] = [ParameterKeys.PerPage: 10, ParameterKeys.Format : "json", ParameterKeys.Page : 1, ParameterKeys.Latitude : pin.latitude, ParameterKeys.Longitude : pin.longitude]

        let method = Methods.findPhotosByLocation

        let _ = taskForGETMethod(method, params: params as [String:AnyObject]) { (results, error) in
            if let error = error {
                completion(nil, error)
            } else {
                if let results = results as? [String:AnyObject] {
                    if let photosSection = results[FlickrClient.JSONResponseKeys.Photos] as? [String:AnyObject] {
                        completion(photosSection["pages"] as? Int, nil)
                    }
                }
            }
        }
    }
}
