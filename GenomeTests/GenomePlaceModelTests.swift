//
//  GenomePlaceModelTests.swift
//  Genome
//
//  Created by Matt Gioe on 7/1/16.
//  Copyright © 2016 Matt Gioe. All rights reserved.
//

import XCTest
@testable import Genome

class GenomePlaceModelTests: XCTestCase {
   
    var placeName : String = "Matt"
    var placeID : String = "1"
    var placeIcon : String = "icon.png"
    
    func testPlaceModelCreation(){
       let place = PlaceModel.init(id: placeName, name: placeID, icon: placeIcon)
        XCTAssertNotNil(place)
    }
    
    func testReturnPlaceAttributes(){
        let place = PlaceModel.init(id: placeID, name: placeName, icon: placeIcon)

        XCTAssertEqual(place.name, "Matt")
        XCTAssertEqual(place.icon, "icon.png")
        XCTAssertEqual(place.id, "1")
    }

    
}
