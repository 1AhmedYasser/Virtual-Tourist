//
//  FlickerApi.swift
//  Virtual Tourist
//
//  Created by Ahmed yasser on 5/25/19.
//  Copyright © 2019 Ahmed yasser. All rights reserved.
//

import Foundation
import UIKit

// A class that handles Flicker api requests and image downloads
class FlickerApi {
    
    // static api key
    static let apiKey = "b266bbb36456df463cb877ebeef01362"
    
    // Struct that contains location info and can be used throughout the app
    struct LocationInfo {
        static var lat = 0.0
        static var long = 0.0
        static var page = 1
        static var totalPages = 1
    }
    
    // Enum that stores the base url for flicker api and photo search url
    enum Endpoints {
        static let base = "https://api.flickr.com/services"
        
        case photoSearch
        
        var stringValue: String {
            switch self {
            case .photoSearch: return Endpoints.base + "/rest/?method=flickr.photos.search&api_key=\(apiKey)&lat=\(LocationInfo.lat)&lon=\(LocationInfo.long)&per_page=21&page=\(LocationInfo.page)&format=json&nojsoncallback=1"
            }
        }
        
        var url: URL {
            return URL(string: stringValue)!
        }
    }
    
    /* A class function that request a photo search from flicker and returning an array of photos in response to
     the request or an error with a status code if the search fails
     */
    class func getPhotosForCoordinates(desiredPage: Int,completionHandler: @escaping ([Photo],Int,Error?) -> Void){
        LocationInfo.page = desiredPage
        let request = URLRequest(url: Endpoints.photoSearch.url)
        
        let task = URLSession.shared.dataTask(with: request, completionHandler: {(data,response,error) in
            
            if error != nil {
                DispatchQueue.main.async {
                    completionHandler([],0,error)
                }
                return
            }
            
            guard let httpStatusCode = (response as? HTTPURLResponse)?.statusCode else {
                return
            }
            if httpStatusCode >= 200 && httpStatusCode < 300 {
                let decoder = JSONDecoder()
                do {
                    let response = try decoder.decode(PhotosResponse.self, from: data!)
                    LocationInfo.totalPages = response.photos.pages
                    DispatchQueue.main.async {
                        completionHandler(response.photos.photo,httpStatusCode,nil)
                    }
                } catch {
                    do {
                        let response = try decoder.decode(PhotoSearchFailResponse.self, from: data!)
                        DispatchQueue.main.async {
                            switch response.code {
                            case 100: completionHandler([],100,error)
                            case 105: completionHandler([],105,error)
                            case 111: completionHandler([],111,error)
                            case 112: completionHandler([],112,error)
                            case 116: completionHandler([],116,error)
                            default: completionHandler([],0,error)
                            }
                        }
                    } catch {
                        DispatchQueue.main.async {
                            completionHandler([],0,error)
                        }
                    }
                }
            } else {
                DispatchQueue.main.async {
                    completionHandler([],0,error)
                }
            }
        })
        task.resume()
    }
    
    // A class function that handles image download for a given image using the image information
    class func getActualPhoto(photo: Photo,completionHandler: @escaping (UIImage?,Error?) -> Void) {
        
        let photoURL = URL(string: "https://farm\(photo.farm).staticflickr.com/\(photo.server)/\(photo.id)_\(photo.secret)_q.jpg")!
        
        let request = URLRequest(url: photoURL)
        
        let task = URLSession.shared.dataTask(with: request, completionHandler: {(data,response,error) in
            
            if error != nil {
                DispatchQueue.main.async {
                    completionHandler(nil,error)
                }
                return
            }
            
            let downloadedImage = UIImage(data: data!)
            DispatchQueue.main.async {
                completionHandler(downloadedImage,nil)
            }
        })
        task.resume()
    }
}
