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
     Use AlamoFire to request and save image for GNMPlaceModel if one doesn't exist locally
     - parameter place : GNMPlaceModel object whose image we want to request
     - paramter completion : Closure which returns optional UIImage after successful request or an error
     */
    
    
    func sendRequest(endpoint endpoint: APIService,
                 completion: ImageRequestCompletionBlock) {
    
        Alamofire.request(endpoint.alamofireMethod, endpoint.url, parameters: nil)
            .responseImage { response in
                print(response)
                switch response.result {
                case .Success(let value):
                    //return the image, add it to the cache
                    completion(value, nil)
//                    self.imageCache.addImage(value, withIdentifier: place.name)
                case .Failure(let value):
                    completion(nil, value)
                }
        }

    }
    
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
            sendRequest(endpoint: .GetPlaceImage(placeImageString : place.imageUrl!), completion: { (image
                , error) -> (Void) in
                
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
