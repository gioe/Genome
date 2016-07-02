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

enum APIService {
    
    /// Returns a list of nearby Place objects
    case GetNearbyPlaces(nextPage : String?, place : GMSPlace)
    
    /// Requests an image for a particular place
    case GetPlaceImage(placeImageString : String?)
    
    var url : String {
        switch self {
            
        case .GetPlaceImage(let placeImageString):
            return "\(Constants.googleRootUrl)photo?maxwidth=400&photoreference=\(placeImageString)&key=\(Constants.GoogleAPIKey)"
            
        case .GetNearbyPlaces(let nextPageString, let place):
            if let nextPageString = nextPageString{
                return "\(Constants.googleRootUrl)location=\(place.coordinate.latitude),\(place.coordinate.longitude)&radius=100&key=\(Constants.GoogleAPIKey)&pagetoken=\(nextPageString)"
            }
            
            return "\(Constants.googleRootUrl)location=\(place.coordinate.latitude),\(place.coordinate.longitude)&radius=100&key=\(Constants.GoogleAPIKey)&pagetoken=\(nextPageString)"
        
        }
    }
    
}

extension APIService {
    var alamofireMethod : Alamofire.Method {
        switch self {
        case .GetPlaceImage(_):
            return .GET
        case .GetNearbyPlaces:
            return .GET
        }
    }
}