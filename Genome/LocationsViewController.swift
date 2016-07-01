//
//  LocationsViewController.swift
//  Genome
//
//  Created by Matt Gioe on 6/29/16.
//  Copyright © 2016 Matt Gioe. All rights reserved.
//

import UIKit
import GoogleMaps

private let LocationCellIdentifer = "LocationCell"

class LocationsViewController: UITableViewController {
    
    var placeData = [Place]?()
    let placesManager = GoogleDataManager()
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        
        //thanks to the tab controller, this VC is initialized very early on in the apps lifecycle so we can gather the data before the user accesses the screen. not stricly necessary but allows for less UI lag.
        placesManager.getNearbyLocationsWithCompletion{ (data,error) in
            if (data != nil){
                self.placeData = data
            }
        }
    }
    
    override func viewDidLoad() {
         tableView.registerNib(UINib(nibName: "LocationTableViewCell", bundle: nil), forCellReuseIdentifier: LocationCellIdentifer)
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        guard placeData != nil else {
            return 0
        }
        
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        guard let data = placeData else {
            return 0
        }
        
        return data.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        guard let data = placeData else {
            fatalError("Application error no cell data available")
        }

        let cell = tableView.dequeueReusableCellWithIdentifier(LocationCellIdentifer, forIndexPath: indexPath) as! LocationTableViewCell
        cell.setUpCell(data[indexPath.row])
        return cell
        
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        guard placeData != nil else {
            fatalError("Application error no cell data available")
        }
        
        self.performSegueWithIdentifier("showLocationDetail", sender: indexPath)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if (segue.identifier == "showLocationDetail") {
            let destinationVC = segue.destinationViewController as! LocationDetailViewController
            let row = (sender as! NSIndexPath).row;
            
            //we're going to pass in the selected place as soon as the user selects a row so there is data ready to go when the screen appears. architecturally this is negotiable. just one way of doing it.
            
            destinationVC.place = placeData![row]
            
        }
    }
    
}
