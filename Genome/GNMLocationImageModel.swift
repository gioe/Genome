//
//  LocationImageModel.swift
//  Genome
//
//  Created by Matt Gioe on 6/29/16.
//  Copyright © 2016 Matt Gioe. All rights reserved.
//

import UIKit
import AlamofireImage
import Alamofire

private let GoogleApiKey = "AIzaSyAe6warIT1Ngcvui5Q6DNYoUQ2re0xga3s"
typealias ImageRequestCompletionBlock = (UIImage?, NSError?) -> (Void)

///Class for handling image management

class GNMLocationImageModel: UIImage {
    
    let imageCache = AutoPurgingImageCache()
    /**
     Returns an image for GNMPlaceModel
     - parameter place : GNMPlaceModel object whose image we want
     - parameter completion : closure returning optional UIImage if it exists
     
     */
    
    func grabImageForPlace(place : GNMPlaceModel, completion : ImageRequestCompletionBlock){
        //check if the image is already cached and return it. if not, make the server request
        if let image = returnCachedImage(place.name){
            completion(image, nil)
        } else {
            
            GNMAPIService.makeImageRequest(.GetPlaceImage(placeImageString : place.imageUrl, place : place), success: { (image) in
                self.imageCache.addImage(image, withIdentifier: place.name)
                completion(image, nil)
                }, failure: { (error) in
                    completion(nil, error)
            })
        }
    }
    
    /**
     Returns a cached copy of a GNMPlaceModel's image
     - parameter place : GNMPlaceModel object whose image we want
     - returns: Optinal UIImage if it exists in the cache
     */
    
    func returnCachedImage(name: String) -> UIImage? {
        return imageCache.imageWithIdentifier(name)
    }

}
