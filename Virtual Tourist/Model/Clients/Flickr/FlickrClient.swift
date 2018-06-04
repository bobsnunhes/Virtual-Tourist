//
//  FlickrClient.swift
//  Virtual Tourist
//
//  Created by roberto fernandes filho on 03/06/2018.
//  Copyright © 2018 Betocorporation. All rights reserved.
//

import Foundation

class FlickrClient : NSObject {
    
    var sharedSession = URLSession.shared
    
    //MARK: GET Method
    func taskForGETMethod(_ method: String, params: [String:AnyObject], completion: @escaping(_ result: AnyObject?, _ error: NSError?) -> Void) -> URLSessionDataTask {
        
        var paramsWithAPIKey = params
        
        paramsWithAPIKey[FlickrClient.ParameterKeys.Method] = method as AnyObject
        paramsWithAPIKey[FlickrClient.ParameterKeys.Callback] = "1" as AnyObject
        paramsWithAPIKey[FlickrClient.ParameterKeys.APIKey] = FlickrClient.ParameterValues.APIKey as AnyObject
        
        let request = NSMutableURLRequest(url: flickrURLFromParameters(paramsWithAPIKey, withPathExtension: ""))
        let task = sharedSession.dataTask(with: request as URLRequest) { (data, response, error) in
            
            func showError(_ error: String) {
                print(error)
                let userInfo = [NSLocalizedDescriptionKey : error]
                completion(nil, NSError(domain: "taskForGETMethod", code: 1, userInfo: userInfo))
            }
            
            guard error == nil else {
                showError("Request error: \(error?.localizedDescription ?? "")")
                return
            }
            
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                showError("Request returned a status code other than 2xx!")
                return
            }
            
            guard let data = data else {
                showError("No data was returned by the request.")
                return
            }
            
            self.convertDataWithCompletionHandler(data, completion: completion)
        }
        
        task.resume()
        
        return task
    }
    
    //MARK: GET Image
    
    func taskForGETImage(url: String, completion: @escaping (_ imageData: Data?, _ error: NSError?) -> Void) {
        let url = URL(string: url)!
        
        let task = sharedSession.dataTask(with: URLRequest(url: url)) { (data, response, error) in
            func showError(_ error: String) {
                print(error)
                let userInfo = [NSLocalizedDescriptionKey : error]
                completion(nil, NSError(domain: "taskForGETImage", code: 1, userInfo: userInfo))
            }
            
            guard error == nil else {
                showError("Request error: \(error?.localizedDescription ?? "")")
                return
            }
            
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                showError("Request returned a status code other than 2xx!")
                return
            }
            
            guard let data = data else {
                showError("No data was returned by the request.")
                return
            }
            
            completion(data, nil)
        }
        
        task.resume()
    }
    
    private func convertDataWithCompletionHandler(_ data: Data, completion: (_ result: AnyObject?, _ error: NSError?) -> Void) {
        
        var parsedResult: AnyObject! = nil
        do {
            parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as AnyObject
        } catch {
            let userInfo = [NSLocalizedDescriptionKey : "Could not parse the data as JSON: '\(data)'"]
            completion(nil, NSError(domain: "convertDataWithCompletionHandler", code: 1, userInfo: userInfo))
        }
        
        completion(parsedResult, nil)
    }
    
    private func flickrURLFromParameters(_ parameters: [String:AnyObject], withPathExtension: String? = nil) -> URL {
        var components = URLComponents()
        components.scheme = FlickrClient.Constants.APIScheme
        components.host = FlickrClient.Constants.APIHost
        components.path = FlickrClient.Constants.APIPath + (withPathExtension ?? "")
        components.queryItems = [URLQueryItem]()
        
        for (key, value) in parameters {
            let queryItem = URLQueryItem(name: key, value: "\(value)")
            components.queryItems!.append(queryItem)
        }
        
        return components.url!
    }
    
    class func sharedInstance() -> FlickrClient {
        struct Singleton {
            static var sharedInstance = FlickrClient()
        }
        return Singleton.sharedInstance
    }
}
