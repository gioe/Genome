//
//  Place.swift
//  Genome
//
//  Created by Matt Gioe on 6/29/16.
//  Copyright © 2016 Matt Gioe. All rights reserved.
//

import Foundation
///  A model of place objects based on Places in the GoogleMaps API
class PlaceModel : NSObject {
    
    /// ID of the Place from GoogleMaps
    var id : String
    
    /// Name of the Place from GoogleMaps
    var name : String
    
    /// Optional URL for image of the place if it exists
    var imageUrl : String?
    
    /// Optional address for the place if it exists
    var address : String?
    
    /// Optional phone number for the place if it exists
    var phoneNumber : String?
    
    /// Optional website for the place if it exists
    var webSite : NSURL?
    
    /// Icon for the Place to be used if there is no ImageURL
    var icon : String
    
    /**
     Initializes a PlaceModel object with id, name and icon from GoogleMapsAPI
     
     
     - parameter id: The GoogleMaps Place plan_id
     - parameter name: The GoogleMaps Place name
     - parameter icon : The GoogleMaps Place name
     
     - Returns: A PlaceModel object
     */
    init(id: String, name: String, icon : String) {
        self.id = id
        self.name = name
        self.icon = icon
        super.init()
    }
    
}