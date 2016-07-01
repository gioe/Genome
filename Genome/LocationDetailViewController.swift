//
//  LocationDetailViewController.swift
//  Genome
//
//  Created by Matt Gioe on 6/30/16.
//  Copyright © 2016 Matt Gioe. All rights reserved.
//

import UIKit

class LocationDetailViewController: UIViewController {

    var place : Place!
    let imageHandler = LocationImageModel()
    let placesManager = GoogleDataManager()

    @IBOutlet weak var websiteLabel: UILabel!
    @IBOutlet weak var phoneNumberLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var locationImage: UIImageView!
 
    init(place: Place){
        self.place = place
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewWillAppear(animated: Bool) {
        
        //we now need to query google again to get more place information. we only got a few bits of information in the initial query. now we get some more.
        placesManager.getPlaceFromID(place.id) { (place, error) in
            
            if let website = place?.website{
                self.websiteLabel.text = website.absoluteString
                self.place.webSite = website
            }
            if let address = place?.formattedAddress{
                self.addressLabel.text = address
                self.place.address = address
                
            }
            if let phone = place?.phoneNumber{
                self.phoneNumberLabel.text = phone
                self.place.phoneNumber = phone
            }
        }
    }
    
    override func viewDidLoad() {
        if let place = self.place{
            nameLabel.text = place.name
            imageHandler.grabImageForPlace(place) { (image,error) -> (Void) in
                self.locationImage.image = image
            }
        }
    }
}