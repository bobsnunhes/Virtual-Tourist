//
//  FlickrConstants.swift
//  Virtual Tourist
//
//  Created by roberto fernandes filho on 03/06/2018.
//  Copyright © 2018 Betocorporation. All rights reserved.
//

import Foundation

extension FlickrClient {
    
    
    struct Constants {
        static let APIScheme = "https"
        static let APIHost = "api.flickr.com"
        static let APIPath = "/services/rest"
    }
    
    struct Methods {
        static let findPhotosByLocation = "flickr.photos.search"
    }
    
    struct ParameterKeys {
        static let APIKey = "api_key"
        static let Method = "method"
        static let Callback = "nojsoncallback"
        static let Format = "format"
        static let Latitude = "lat"
        static let Longitude = "lon"
        static let PerPage = "per_page"
        static let Page = "page"
    }
    
    struct ParameterValues {
        static let APIKey = "1429c4540db12a039f242dadc0fa8833"
    }
    
    struct URLKeys {
        static let ID = "id"
    }
    
    struct JSONResponseKeys {
        static let Photos = "photos"
        static let Photo = "photo"
        static let PhotoID = "id"
        static let PhotoTitle = "title"
        static let PhotoFarm = "farm"
        static let PhotoServerID = "server"
        static let PhotoSecret = "secret"
    }
    
}
