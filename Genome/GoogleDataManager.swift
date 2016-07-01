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
private let GoogleApiKey = "AIzaSyAe6warIT1Ngcvui5Q6DNYoUQ2re0xga3s"
typealias PlaceRequestCompletionBlock = ([Place]?, NSError?) -> ()
typealias JSONRequestCompletionBlock = (JSON?, NSError?) -> ()

class GoogleDataManager : NSObject{
    
    let imageCache = AutoPurgingImageCache()
    var jsonArray : [AnyObject] = []
    var pageString : String = ""
    
    func getCurrentPlace(completionHandler: (place: GMSPlace?) -> ()) {
        
        //get the current place from google so we can communicate our position with them
        GMSPlacesClient.sharedClient().currentPlaceWithCallback({
            (placeLikelihoodList: GMSPlaceLikelihoodList?, error: NSError?) -> Void in
            if let error = error {
                print("Pick Place error: \(error.localizedDescription)")
                return
            }
            if let placeLikelihoodList = placeLikelihoodList {
                if let place = placeLikelihoodList.likelihoods.first?.place {
                    completionHandler(place: place)
                }
            }
        })
    }
    
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
    
    func stringForNearbyPlacesQueryFromPlace(place : GMSPlace) -> String{
        //generate a url based on whether or not we're on the first or second page of the query. first page only returns 20 results so we need to query twice with a different token the second time for the extra 5 locations
        
        if pageString.isEmpty{
            return "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=\(place.coordinate.latitude),\(place.coordinate.longitude)&radius=\(kCurrentSearchRadius)&key=\(GoogleApiKey)"
        } else {
            return "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=\(place.coordinate.latitude),\(place.coordinate.longitude)&radius=\(kCurrentSearchRadius)&key=\(GoogleApiKey)&pagetoken=\(pageString)"
        }
        
    }
    
    func getNearbyLocationsWithCompletion(completion : PlaceRequestCompletionBlock) {
        //find a list of nearby places from our current postition
        getCurrentPlace { (place) in
            
            if let place = place {
                self.makeAPIRequest(place, completion: { (responseObject, error) in
                    if responseObject != nil {
                        //break the json up into pieces so we can use the places individually
                        completion(self.parseJSONResponse(JSON(self.jsonArray)), nil)
                    }
                })
            }
        }
    }
    
    func makeAPIRequest(place : GMSPlace?, completion : JSONRequestCompletionBlock){
       
        //this function i'd love to refactor given more time. i'd like to do a little more resarch into the best conventions behind chained API requests. here i'm checking to see if the json array is less than 25 because if it is, we need to request more places per the spec. that means back to back api calls for which i'm sure there's an ccepted convention
        
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
                    self.makeAPIRequest(place, completion: { (json, error) in
                        completion(JSON(self.jsonArray),nil)
                    })
                } else {
                    completion(JSON(self.jsonArray), nil)
                }
                
            case .Failure(let value):
                completion(nil , value)
            }
        }

    }

    func parseJSONResponse(responseObject: JSON) -> [Place]?{
        //can't limit the api request so in order to get to 25, we had to go up to 40 and then cut out the first 25
        let subArray = responseObject.arrayObject![0...24]
        var finalArray = [Place]()
        
        //iterate through the array of 25 JSON objects and create Place objects from them
        for place in subArray {
            if let placeID = place["place_id"], name = place["name"], icon = place["icon"]{
                let newPlace = Place.init(id: placeID as! String, name: name as! String, icon: icon as! String)
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




