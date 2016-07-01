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

class LocationImageModel: UIImage {
    
    let imageCache = AutoPurgingImageCache()
    
    func queryStringForImageForPlace(place : Place) -> String{
        
        if let imageURL = place.imageUrl{
            return "https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photoreference=\(imageURL)&key=\(GoogleApiKey)"
        }
        
        return place.icon
        
    }
    
    func makeRequestForImageFromPlace(place : Place, completion : ImageRequestCompletionBlock) {
        Alamofire.request(.GET, queryStringForImageForPlace(place), parameters: nil)
            .responseImage { response in
                print(response)
                switch response.result {
                case .Success(let value):
                    //return the image, add it to the cache
                    completion(value, nil)
                    self.imageCache.addImage(value, withIdentifier: place.name)
                case .Failure(let value):
                    completion(nil, value)
                }
        }
    }
    
    func grabImageForPlace(place : Place, completion : ImageRequestCompletionBlock){
        //check if the image is already cached and return it. if not, make the server request
        if let image = returnCachedImage(place.name){
            completion(image, nil)
        } else {
            
            makeRequestForImageFromPlace(place, completion: { (image, error) -> (Void) in
                completion(image, error)
            })
        }
    }
    
    func returnCachedImage(name: String) -> UIImage? {
        return imageCache.imageWithIdentifier(name)
    }

}
