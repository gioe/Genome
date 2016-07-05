//
//  DataManager.swift
//  Genome
//
//  Created by Matt Gioe on 6/29/16.
//  Copyright © 2016 Matt Gioe. All rights reserved.
//

import Foundation
import MapKit
import GoogleMaps
import Alamofire
import AlamofireImage
import SwiftyJSON

typealias NearbyPlacesRequestCompletionBlock = ([GNMPlaceModel]?, NSError?) -> ()
typealias JSONRequestCompletionBlock = (JSON?, NSError?) -> ()
typealias GetIndividualPlaceRequestCompletionBlock = (GMSPlace?, NSError?) -> ()

///Class for managing all HTTP requests
 
class GNMGoogleDataManager : NSObject{
    
    let imageCache = AutoPurgingImageCache()
    var currentPlace = GMSPlace?()
    var jsonArray : [AnyObject] = []
    var pageString : String?
    
    
    /**
        Determine the users current "place" as defined by GoogleMaps
     
     - parameter place: Place object determined by GoogleMaps API
     
     */
    
    func getCurrentPlace(completionHandler: GetIndividualPlaceRequestCompletionBlock) {
        
        //get the current place from google so we can communicate our position with them
        GMSPlacesClient.sharedClient().currentPlaceWithCallback({
            (placeLikelihoodList: GMSPlaceLikelihoodList?, error: NSError?) -> Void in
            if let error = error {
                print("Pick Place error: \(error.localizedDescription)")
                completionHandler(nil, error)
            }
            if let placeLikelihoodList = placeLikelihoodList {
                if let place = placeLikelihoodList.likelihoods.first?.place {
                    completionHandler(place, nil)
                }
            }
        })
    }
    
    /**
     Request additional data about a place from GoogleMapsAPI
     
     - parameter placeID: Unique identifier for place required by GoogleMaps Query
     - parameter completion : Closure which returns a GoogleMaps Place and an error if applicable
     
     */
    
    func getPlaceFromID(placeID : String, completion : (GMSPlace?, NSError?) -> ()){
        //grab indivdual place data for the locationdetailvc. we don't get nearly enough detail from the nearbyPlaces query. we need to request them individually
        GMSPlacesClient.sharedClient().lookUpPlaceID(placeID, callback: { (place: GMSPlace?, error: NSError?) -> Void in
            if let error = error {
                print("lookup place id query error: \(error.localizedDescription)")
                completion(nil, error)
                return
            }
            
            if let place = place {
                completion(place, nil)
            }

        })
        
    }

    /**
     Use our APIServices class to make request to GoogleMaps Web API
     
     - parameter completion : Closure returning array of GNMPlaceModel objects determined from GoogleMaps JSON
     */

    
    func getNearbyLocationsWithCompletion(completion : NearbyPlacesRequestCompletionBlock) {
        //find a list of nearby places from our current postition
        getCurrentPlace { (place, error) in
            
            if let place = place {
                self.currentPlace = place
                
                GNMAPIService.makeJSONRequest(.GetNearbyPlaces(nextPage : nil, place : self.currentPlace!), success: { (responseObject) in
                    self.pageString = responseObject["next_page_token"].stringValue
                    
                    //add the new results to the class property
                    self.jsonArray += responseObject["results"].arrayObject!
                    if self.jsonArray.count < 25{
                        
                        let delay = dispatch_time(DISPATCH_TIME_NOW, Int64(2 * Double(NSEC_PER_SEC)))
                        
                        dispatch_after(delay, dispatch_get_main_queue()) {
                            
                            GNMAPIService.makeJSONRequest(.GetNearbyPlaces(nextPage : nil, place : self.currentPlace!), success: { (responseObject) in
                                    completion(self.parseJSONResponse(responseObject), nil)
                                }, failure: { (error) in
                                    completion(nil, error)
                            })
                        }
                        
                    }
                    } , failure: { (error) in
                        completion(nil, error)
                })
                
                
            } else {
                completion(nil, error)
            }
        }
    }
    
    /**
     Generates GNMModelPlace objects from the JSON object returned from the Google Maps API
     
     - parameter responseObject : JSON object from Google Maps API
     - returns : array of GNMPlaceModel objects for internal use
     */

 
    func parseJSONResponse(responseObject: JSON) -> [GNMPlaceModel]?{
        //can't limit the api request so in order to get to 25, we had to go up to 40 and then cut out the first 25
        
        print(responseObject)
        let subArray = responseObject.arrayObject![0...24]
        var finalArray = [GNMPlaceModel]()
        
        //iterate through the array of 25 JSON objects and create Place objects from them
        for place in subArray {
            if let placeID = place["place_id"], name = place["name"], icon = place["icon"]{
                let newPlace = GNMPlaceModel.init(id: placeID as! String, name: name as! String, icon: icon as! String)
                if let photoArray = place["photos"] as? [AnyObject]{
                    if let imageString = photoArray[0]["photo_reference"] as? String{
                        newPlace.imageUrl = imageString
                    }
                }
                finalArray.append(newPlace)
            }
        }
        
        return finalArray
        
    }
    
}




