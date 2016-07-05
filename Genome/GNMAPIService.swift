//
//  APIService.swift
//  Genome
//
//  Created by Matt Gioe on 7/2/16.
//  Copyright © 2016 Matt Gioe. All rights reserved.
//

import Foundation
import Alamofire
import GoogleMaps
import SwiftyJSON

enum GNMAPIService {
    
    /// Returns a list of nearby Place objects
    case GetNearbyPlaces(nextPage : String?, place : GMSPlace)
    
    /// Requests an image for a particular place
    case GetPlaceImage(placeImageString : String?, place : GNMPlaceModel)
    
    var url : String {
        switch self {
            
        case .GetPlaceImage(let placeImageString, let place):
            
            if let placeImageString = placeImageString{
                return "\(GNMConstants.googleRootUrl)photo?maxwidth=400&photoreference=\(placeImageString)&key=\(GNMConstants.GoogleAPIKey)"
            }
            
            return place.icon
            
        case .GetNearbyPlaces(let nextPageString, let place):
            if let nextPageString = nextPageString{
                return "\(GNMConstants.googleRootUrl)nearbysearch/json?location=\(place.coordinate.latitude),\(place.coordinate.longitude)&radius=100&key=\(GNMConstants.GoogleAPIKey)&pagetoken=\(nextPageString)"
            }
            
            return "\(GNMConstants.googleRootUrl)nearbysearch/json?location=\(place.coordinate.latitude),\(place.coordinate.longitude)&radius=100&key=\(GNMConstants.GoogleAPIKey)"
        
        }
    }
    
}

extension GNMAPIService {
    var alamofireMethod : Alamofire.Method {
        switch self {
        case .GetPlaceImage(_):
            return .GET
        case .GetNearbyPlaces:
            return .GET
        }
    }
    
    static func makeJSONRequest(endpoint : GNMAPIService, success:(JSON) -> Void, failure:(NSError) -> Void) {
        Alamofire.request(endpoint.alamofireMethod, endpoint.url).responseJSON { (responseObject) -> Void in
            
            print(responseObject) //it will print the response success/failure anything
            
            if responseObject.result.isSuccess {
                let resJson = JSON(responseObject.result.value!)
                success(resJson)
            }
            if responseObject.result.isFailure {
                let error : NSError = responseObject.result.error!
                failure(error)
            }
        }
    }
    
    static func makeImageRequest(endpoint : GNMAPIService, success:(UIImage) -> Void, failure:(NSError) -> Void) {
        Alamofire.request(endpoint.alamofireMethod, endpoint.url).responseImage { response in
            print(response)
            switch response.result {
            case .Success(let value):
                //return the image, add it to the cache
                success(value)
            case .Failure(let value):
                failure(value)
            }
        }
    }
}
