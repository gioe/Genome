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

private let kCurrentSearchRadius = String(100)
private let GoogleURL = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?"
private let GoogleApiKey = "AIzaSyAe6warIT1Ngcvui5Q6DNYoUQ2re0xga3s"
typealias NearbyPlacesRequestCompletionBlock = ([GNMPlaceModel]?, NSError?) -> ()
typealias JSONRequestCompletionBlock = (JSON?, NSError?) -> ()
typealias GetIndividualPlaceRequestCompletionBlock = (GMSPlace?, NSError?) -> ()

class GNMGoogleDataManager : NSObject{
    
    let imageCache = AutoPurgingImageCache()
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
     Dynamically generates query string for a query of nearby places
     
     - parameter place: Current GoogleMaps place used to determine nearby places
     
     */
    
    func stringForNearbyPlacesQueryFromPlace(place : GMSPlace) -> String{
        
        //generate a url based on whether or not we're on the first or second page of the query. first page only returns 20 results so we need to query twice with a different token the second time for the extra 5 locations
        
        if let nextPage = pageString{
            return "\(GoogleURL)location=\(place.coordinate.latitude),\(place.coordinate.longitude)&radius=\(kCurrentSearchRadius)&key=\(GoogleApiKey)&pagetoken=\(nextPage)"
        }
        
        return "\(GoogleURL)=\(place.coordinate.latitude),\(place.coordinate.longitude)&radius=\(kCurrentSearchRadius)&key=\(GoogleApiKey)"
        
    }
    
    /**
     Request nearby places from GoogleMaps API
     
     - parameter completion : Closure which returns an array of PlaceModel objects and error if applicable
     
     */
    
    func getNearbyLocationsWithCompletion(completion : NearbyPlacesRequestCompletionBlock) {
        //find a list of nearby places from our current postition
        getCurrentPlace { (place, error) in
            
            if let place = place {
                self.makeAPIRequest(place, completion: { (responseObject, error) in
                    if responseObject != nil {
                        //generate places from JSON
                        completion(self.parseJSONResponse(JSON(self.jsonArray)), nil)
                        
                        //set next page to nil in case we refresh and want the original places
                        self.pageString = nil;
                        
                    } else {
                        completion(nil, error)
                    }
                })
            }
            
            completion(nil, error)
        }
    }
    
    /**
     Use Alamofire to make request to GoogleMaps Web API
     
     - parameter place : GoogleMaps current Place required for nearby place querying
     - parameter completion : Closure returning optional JSON from successful request
     */
    
    func makeAPIRequest(place : GMSPlace?, completion : JSONRequestCompletionBlock){
        
        /**
         this function i'd love to refactor given more time. i'd like to do a little more resarch into the best conventions behind chained API requests. here i'm checking to see if the json array is less than 25 because if it is, we need to request more places per the spec. that means back to back api calls for which i'm sure there's an ccepted convention
         */
        
        Alamofire.request(.GET, self.stringForNearbyPlacesQueryFromPlace(place!), parameters: nil) .responseJSON { response in
            print(response)
            switch response.result {
            case .Success( _):
                let json = JSON(data: response.data!)
                //grab the token for query pagination
                self.pageString = json["next_page_token"].stringValue
                
                //add the new results to the class property
                self.jsonArray += json["results"].arrayObject!
                if self.jsonArray.count < 25{
                    
                    //add a two second delay until the next call so the server doesn't return an error
                    let delay = dispatch_time(DISPATCH_TIME_NOW, Int64(2 * Double(NSEC_PER_SEC)))
                    dispatch_after(delay, dispatch_get_main_queue()) {
                        self.makeAPIRequest(place, completion: { (json, error) in
                            completion(JSON(self.jsonArray),nil)
                        })
                    }
                   
                } else {
                    completion(JSON(self.jsonArray), nil)
                }
                
            case .Failure(let value):
                completion(nil , value)
            }
        }

    }
   
    /**
     Generate PlaceModel objects from JSON generated by makeAPIRequest()
     
     - parameter responseObject : JSON passed in from makeAPIRequest()
     - returns: Array of PlaceModel objects determined by JSON
     
     */
    
    func parseJSONResponse(responseObject: JSON) -> [GNMPlaceModel]?{
        //can't limit the api request so in order to get to 25, we had to go up to 40 and then cut out the first 25
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




