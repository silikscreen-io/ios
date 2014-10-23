//
//  GMapViewController.swift
//  HexagonPicker
//
//  Created by Vlasov Illia on 22.10.14.
//  Copyright (c) 2014 vaisoft. All rights reserved.
//

import UIKit
import CoreLocation

let iOS8Delta = (((UIDevice.currentDevice().systemVersion as NSString).floatValue >= 8.0 ) ? true : false )

class GMapViewController: UIViewController, CLLocationManagerDelegate, GMSMapViewDelegate, ArtViewControllerDelegate {
    var deviceOrientation: UIDeviceOrientation?
    
    let SHOW_ART_SEGUE_ID = "showArtSegue"
    
    let locationManager = CLLocationManager()
    
    var mapView: GMSMapView?
    var tappedMarker: GMSMarker?
    var polyline: GMSPolyline?
    
    var firstLook = true
    var currentLocation: CLLocationCoordinate2D?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.distanceFilter = 10
        if (iOS8Delta) {
            locationManager.requestAlwaysAuthorization()
            locationManager.requestWhenInUseAuthorization()
        }
        locationManager.startUpdatingLocation()
        initMap()
        initMarkers()
    }
    
    
    
    func mapView(mapView: GMSMapView!, didTapInfoWindowOfMarker marker: GMSMarker!) {
        performSegueWithIdentifier(SHOW_ART_SEGUE_ID, sender: self)
    }
    
    
    
    func initMap() {
        var target: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 51.6, longitude: 17.2)
        var camera: GMSCameraPosition = GMSCameraPosition(target: target, zoom: 6, bearing: 0, viewingAngle: 0)
        mapView = GMSMapView(frame: CGRectMake(0, 0, self.view.bounds.width, self.view.bounds.height))
//        var myOptions = {
//            zoom: 15,
//            center: new google.maps.LatLng(53.385873, -1.471471),
//            mapTypeId: google.maps.MapTypeId.ROADMAP,
//            styles: style_array_from_above_here
//        };
//        
//        var map = new google.maps.Map(document.getElementById('map'), myOptions);
        if let map = mapView? {
            map.myLocationEnabled = true
            map.camera = camera
            map.delegate = self
            map.settings.myLocationButton = true
            map.settings.compassButton = true
            map.padding = UIEdgeInsets(top: self.topLayoutGuide.length + 5, left: 0, bottom: 0, right: 0)
            
            self.view.addSubview(mapView!)
        }
    }
    
    
    
    func initMarkers() {
        addMarker(50.491927, 30.336178, 1)
        addMarker(50.421927, 30.436178, 2)
        addMarker(50.471927, 30.406178, 3)
    }
    
    
    
    func addMarker(latitude: Double, _ longitude: Double, _ pictureNumber: Int) {
        var marker = GMSMarker(position: CLLocationCoordinate2D(latitude: latitude, longitude: longitude))
        marker.title = "Picture \(pictureNumber)"
        //marker.snippet = "\(latitude), \(longitude)"
        marker.snippet = "Tap me"
        marker.icon = UIImage(named: "annotation.png")
        marker.map = mapView
    }
    
    
    
    override func viewDidAppear(animated: Bool) {
        deviceOrientation = UIDevice.currentDevice().orientation
    }
    
    
    
    func dismissArtViewController() {
        self.dismissViewControllerAnimated(true, completion: nil)
        createRoute(currentLocation!, tappedMarker!.position)
        let bounds = GMSCoordinateBounds(coordinate: currentLocation!, coordinate: tappedMarker!.position)
        let boundsCameraUpdate = GMSCameraUpdate.fitBounds(bounds, withPadding: 30)
        mapView!.animateWithCameraUpdate(boundsCameraUpdate)
    }
    
    
    
    func mapView(mapView: GMSMapView!, didTapMarker marker: GMSMarker!) -> Bool {
        tappedMarker = marker
//        createRoute(currentLocation!, marker!.position)
        return false
    }
    
    
    
    func createRoute(firstLocation: CLLocationCoordinate2D, _ secondLocation: CLLocationCoordinate2D) {
        var strOrigin = "origin=\(firstLocation.latitude),\(firstLocation.longitude)"
        var strDest = "destination=\(secondLocation.latitude),\(secondLocation.longitude)"
        var sensor = "sensor=false"
        var parameters = strOrigin + "&" + strDest + "&" + sensor + "&mode=walking"
        var output = "json"
        var url = "https://maps.googleapis.com/maps/api/directions/" + output + "?" + parameters
        
        sendRouteRequest(url)
    }
    
    
    
    func sendRouteRequest(urlString: String) {
        var url = NSURL(string: urlString)!
        var request = NSURLRequest(URL: url)
        var queue: NSOperationQueue = NSOperationQueue()
        NSURLConnection.sendAsynchronousRequest(request, queue: queue, completionHandler:{(response: NSURLResponse!, responseData: NSData!, error: NSError!) in
            if error == nil {
                self.createPolyline(responseData)
            } else {
            }
        })
    }
    
    
    
    func createPolyline(data: NSData!) -> [CLLocationCoordinate2D] {
        let jsonResult: NSDictionary = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: nil) as NSDictionary
        let routes: [NSDictionary] = jsonResult["routes"] as [NSDictionary]
        var locations: [CLLocationCoordinate2D] = []
        let overviewPolyline = (routes[0] as NSDictionary)["overview_polyline"] as NSDictionary
        let points = overviewPolyline["points"] as String
        let path = GMSPath(fromEncodedPath: points)
        if polyline != nil {
            polyline!.map = nil
            polyline = nil
        }
        polyline = GMSPolyline(path: path)
        polyline!.strokeWidth = 5
        polyline!.strokeColor = UIColor.blueColor()
        polyline!.map = mapView
        return locations
    }
    
    
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        currentLocation = (locations as [CLLocation])[locations.count - 1].coordinate
        if firstLook {
            firstLook = false
            var camera: GMSCameraPosition = GMSCameraPosition(target: currentLocation!, zoom: 14, bearing: 0, viewingAngle: 0)
            mapView!.camera = camera
        }
    }
    
    
    
    override func viewWillLayoutSubviews() {
        if deviceOrientation == nil {
            return
        }
        let previousOrientation = deviceOrientation
        deviceOrientation = UIDevice.currentDevice().orientation
        if previousOrientation == deviceOrientation {
            return
        }
        var frame = mapView!.frame
        frame.size.width = mapView!.frame.size.height
        frame.size.height = mapView!.frame.size.width
        mapView!.frame = frame
    }
    
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == SHOW_ART_SEGUE_ID {
            let artViewController = segue.destinationViewController as ArtViewController
            artViewController.delegate = self
        }
    }
    
}