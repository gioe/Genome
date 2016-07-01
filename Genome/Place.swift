//
//  Place.swift
//  Genome
//
//  Created by Matt Gioe on 6/29/16.
//  Copyright © 2016 Matt Gioe. All rights reserved.
//

import Foundation

class Place : NSObject {
    var id : String
    var name : String
    var imageUrl : String?
    var address : String?
    var phoneNumber : String?
    var webSite : NSURL?
    var icon : String
    
    init(id: String, name: String, icon : String) {
        self.id = id
        self.name = name
        self.icon = icon
        super.init()
    }
    
}