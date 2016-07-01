//
//  LocationDetailViewController.swift
//  Genome
//
//  Created by Matt Gioe on 6/30/16.
//  Copyright © 2016 Matt Gioe. All rights reserved.
//

import UIKit
import ARSLineProgress

//given more time, i'd implement a cache system here so we're not querying google every time the view loads

class GNMLocationDetailViewController: UIViewController {

    var place : GNMPlaceModel!
    let imageHandler = GNMLocationImageModel()
    let placesManager = GNMGoogleDataManager()
    @IBOutlet weak var websiteLabel: UILabel!
    @IBOutlet weak var phoneNumberLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var locationImage: UIImageView!
 
    init(place: GNMPlaceModel){
        self.place = place
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewWillAppear(animated: Bool) {
        ARSLineProgress.show()
        //we now need to query google again to get more place information. we only got a few bits of information in the initial query. now we get some more.
        placesManager.getPlaceFromID(place.id) { (place, error) in
            
            if let website = place?.website{
                self.websiteLabel.text = website.absoluteString
            }
            if let address = place?.formattedAddress{
                self.addressLabel.text = address
                
            }
            if let phone = place?.phoneNumber{
                self.phoneNumberLabel.text = phone
            }
            if ARSLineProgress.shown{
                ARSLineProgress.hide()
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
