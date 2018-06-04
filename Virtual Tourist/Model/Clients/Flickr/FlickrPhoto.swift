//
//  FlickrPhoto.swift
//  Virtual Tourist
//
//  Created by roberto fernandes filho on 03/06/2018.
//  Copyright © 2018 Betocorporation. All rights reserved.
//

import Foundation

struct FlickrPhoto {
    let id : String?
    let server : String?
    let farm : Int?
    let secret : String?
    let url : String?
    
    init(dic: [String:AnyObject]) {
        id = dic[FlickrClient.JSONResponseKeys.PhotoID] as? String
        server = dic[FlickrClient.JSONResponseKeys.PhotoServerID] as? String
        farm = dic[FlickrClient.JSONResponseKeys.PhotoFarm] as? Int
        secret = dic[FlickrClient.JSONResponseKeys.PhotoSecret] as? String
        url = "https://farm\(farm ?? 0).staticflickr.com/\(server ?? "")/\(id ?? "")_\(secret ?? "").jpg"
    }
}
