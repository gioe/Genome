//
//  MapViewController.swift
//  Genome
//
//  Created by Matt Gioe on 6/29/16.
//  Copyright © 2016 Matt Gioe. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import GoogleMaps

class GNMMapViewController: UIViewController, MKMapViewDelegate {
    
    var currentPlace : GMSPlace?
    
    var locationManager : CLLocationManager! {
        didSet {
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestWhenInUseAuthorization()
            locationManager.startUpdatingLocation()
        }
    }

    @IBOutlet var mapView: MKMapView! {
        didSet {
            mapView.delegate = self
            mapView.mapType = MKMapType.Standard
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //initialze location manager
        locationManager = CLLocationManager()
        
        //set current location button in navbar
        let trackingButton = MKUserTrackingBarButtonItem.init(mapView: mapView)
        navigationItem.rightBarButtonItem = trackingButton
        
        //start tracing. we can't do this until we have the permissions from the location manager
        mapView.showsUserLocation = true
        
    }
    
}
