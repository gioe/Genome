//
//  LocationTableViewCell.swift
//  Genome
//
//  Created by Matt Gioe on 6/29/16.
//  Copyright © 2016 Matt Gioe. All rights reserved.
//

import UIKit

///TableViewCell for GNMPlaceModel

class GNMLocationTableViewCell: UITableViewCell {

    @IBOutlet private weak var locationImage: UIImageView!
    @IBOutlet private weak var locationLabel: UILabel!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    let placesManager = GNMGoogleDataManager()
    let imageManager = GNMLocationImageModel()
    
    /**
     Configures TableViewCell with data we have for PlaceModel
     - parameter place : GNMPlaceModel object used to generate cell UI
     */
    
    func setUpCell(place: GNMPlaceModel) {
        
        startActivityIndicator()
       imageManager.grabImageForPlace(place) { (image, error) -> (Void) in
        self.locationImage.image = image
        self.stopActivityIndicator()
        }
        locationLabel.text = place.name
        self.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
    }

    /**
     Starts an activity indicator if no image has been set
     */
    func startActivityIndicator(){
        if let activityIndicator = activityIndicator{
            activityIndicator.startAnimating()
            activityIndicator.hidesWhenStopped = true
        }
    }
    
    /**
     Stops an activity indicator if image is set
     */
    func stopActivityIndicator(){
        if let activityIndicator = self.activityIndicator{
            activityIndicator.stopAnimating()
        }
    }
    
    
}
