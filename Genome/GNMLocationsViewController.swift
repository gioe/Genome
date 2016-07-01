//
//  LocationsViewController.swift
//  Genome
//
//  Created by Matt Gioe on 6/29/16.
//  Copyright © 2016 Matt Gioe. All rights reserved.
//

import UIKit
import GoogleMaps
import ARSLineProgress

private let LocationCellIdentifer = "LocationCell"
private let LocationSequeIdentifier = "showLocationDetail"

///TableViewController of nearby locations
class GNMLocationsViewController: UITableViewController {
    
    var placeData = [GNMPlaceModel]?()
    let placesManager = GNMGoogleDataManager()
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        
        //thanks to the tab controller, this VC is initialized very early on in the apps lifecycle so we can gather the data before the user accesses the screen. not stricly necessary but allows for less UI lag.
        ARSLineProgress.show()
        refreshTable()
    }
    
    override func viewDidLoad() {
        
         tableView.registerNib(UINib(nibName: "GNMLocationTableViewCell", bundle: nil), forCellReuseIdentifier: LocationCellIdentifer)
        refreshControl!.addTarget(self, action: #selector(GNMLocationsViewController.refreshTable), forControlEvents: UIControlEvents.ValueChanged)
        
    }
    
    /**
     Generates data for the tableview and refreshes it upon succss. Displays an error message if it fails.
     */
    
    func refreshTable() {
        
        placesManager.getNearbyLocationsWithCompletion{ (data,error) in
            
            if ARSLineProgress.shown{
                ARSLineProgress.hide()
            }
            
            if let error = error{
                self.throwErrorPop(error)
                return
            }
            
            self.placeData = data
            self.tableView.reloadData()
            self.refreshControl?.endRefreshing()
            
        }
        
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

        let cell = tableView.dequeueReusableCellWithIdentifier(LocationCellIdentifer, forIndexPath: indexPath) as! GNMLocationTableViewCell
        cell.setUpCell(data[indexPath.row])
        return cell
        
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        guard placeData != nil else {
            return
        }
        
        self.performSegueWithIdentifier(LocationSequeIdentifier, sender: indexPath)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if (segue.identifier == LocationSequeIdentifier) {
            let destinationVC = segue.destinationViewController as! GNMLocationDetailViewController
            let row = (sender as! NSIndexPath).row;
            
            //we're going to pass in the selected place as soon as the user selects a row so there is data ready to go when the screen appears. architecturally this is negotiable. just one way of doing it.
            
            destinationVC.place = placeData![row]
            
        }
    }
    
    /**
     Displays an alert view if location services requests fail
     */
    
    func throwErrorPop(error: NSError?) {
        
        let alert = UIAlertController.init(title: "Genome", message: error?.localizedDescription , preferredStyle: .Alert)
        let dismissAction = UIAlertAction.init(title: "OK!", style: .Cancel, handler: { (action) in
        })
        alert.addAction(dismissAction)
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
}
