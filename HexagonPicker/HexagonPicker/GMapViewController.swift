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

protocol GMapViewControllerDelegate {
    func dismissGMapViewController()
}

class GMapViewController: UIViewController, CLLocationManagerDelegate, GMSMapViewDelegate, ArtViewControllerDelegate {
    var homeViewController: UIViewController?
    var artForRoute: Art?
    
    var delegate: GMapViewControllerDelegate!
    
    let SHOW_ART_SEGUE_ID = "showArtSegue"
    
    let locationManager = CLLocationManager()
    
    var mapView: GMSMapView?
    var tappedMarker: GMarker?
    var polyline: GMSPolyline?
    
    var firstLook = true
    var currentLocation: CLLocationCoordinate2D?

    var homeToolbar: UIToolbar!
    var homeToolbarItems: [UIBarItem]!
    
    var screenSize: CGRect?
    var firstLayout = true
    
    var previewLoaded = false
    var infoPreview: UIImageView?
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "orientationChanged", name: ORIENTATION_CHANGED_NOTIFICATION, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "iconLoaded:", name: ICON_LOADED_NOTIFICATION_ID, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "previewLoaded:", name: PREVIEW_LOADED_NOTIFICATION_ID, object: nil)
    }
    
    
    
    override func viewWillLayoutSubviews() {
        if !firstLayout {
            return
        }
        firstLayout = false
        screenSize = self.view.bounds
        //updateScreenSize()
        
        locationManager.delegate = self
        locationManager.distanceFilter = 10
        if (iOS8Delta) {
            locationManager.requestAlwaysAuthorization()
            locationManager.requestWhenInUseAuthorization()
        }
        locationManager.startUpdatingLocation()
        initMap()
        initMarkers()
        initNavigationBar()
    }
    
    
    
    func initNavigationBar() {
        var frame = screenSize!
        frame.origin.y = frame.height - 30
        frame.size.height = 30
        homeToolbar = UIToolbar(frame: frame)
        homeToolbar!.barStyle = UIBarStyle.Black
        homeToolbar!.alpha = 0.7
        self.view.addSubview(homeToolbar!)
        
        var homeImage = UIImage(named: "home_icon.png")
        var destinationSize = CGSize(width: 30, height: 30)
        UIGraphicsBeginImageContext(destinationSize)
        homeImage!.drawInRect(CGRectMake(0, 0, destinationSize.width, destinationSize.height))
        var newHomeImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();

        var item = UIBarButtonItem(image: newHomeImage, style: UIBarButtonItemStyle.Plain, target: self, action: "homeTapped")
        item.setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.whiteColor()], forState: UIControlState.Normal)
        var space = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
        homeToolbarItems = Array(arrayLiteral: space, item, space)
        homeToolbar.items = homeToolbarItems
    }
    
    
    
    func updateScreenSize() -> Bool {
        let deviceOrientationPortrait =  ((deviceOrientation == UIDeviceOrientation.Portrait) || (deviceOrientation == UIDeviceOrientation.PortraitUpsideDown)) ? true : false
        let minSize = screenSize!.size.width < screenSize!.height ? screenSize!.size.width : screenSize!.height
        let maxSize = screenSize!.size.width > screenSize!.height ? screenSize!.size.width : screenSize!.height
        if deviceOrientationPortrait {
            if minSize == screenSize!.size.width {
                return false
            }
            screenSize!.size = CGSize(width: minSize, height: maxSize)
        } else {
            if maxSize == screenSize!.size.width {
                return false
            }
            screenSize!.size = CGSize(width: maxSize, height: minSize)
        }
        return true
    }
    
    
    
    func homeTapped() {
        if delegate == nil {
            if homeViewController != nil {
                (homeViewController as ArtViewController).dismissMap()
            }
        } else {
            delegate!.dismissGMapViewController()
        }
    }
    
    
    
    func iconLoaded(notification: NSNotification) {
        let notificationDictionary = (notification.userInfo! as NSDictionary)
        let art = notificationDictionary.objectForKey("art") as Art
        addMarker(art)
    }
    
    
    
    func previewLoaded(notification: NSNotification) {
        let notificationDictionary = (notification.userInfo! as NSDictionary)
        
        dispatch_async(dispatch_get_main_queue(), {
            let image = notificationDictionary.objectForKey("preview") as? UIImage
            self.infoPreview!.image = notificationDictionary.objectForKey("preview") as? UIImage
            if !self.previewLoaded {
                self.previewLoaded = !self.previewLoaded
                self.mapView!.selectedMarker = self.tappedMarker!
            }
        })
    }
    
    
    func mapView(mapView: GMSMapView!, markerInfoWindow marker: GMSMarker!) -> UIView! {
        if self.previewLoaded {
            self.previewLoaded = !self.previewLoaded
        } else {
            (marker as GMarker).art!.getPreview()
            infoPreview = UIImageView(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
        }
        return infoPreview
    }
    
    
    
    func mapView(mapView: GMSMapView!, didTapInfoWindowOfMarker marker: GMSMarker!) {
        let artViewController = ArtViewController()
        artViewController.art = tappedMarker!.art
        artViewController.homeViewController = self
        artViewController.delegate = self
        if iOS8Delta {
            self.showViewController(artViewController, sender: self)
        } else {
            presentViewController(artViewController, animated: true, completion: nil)
        }
    }
    
    
    
    func initMap() {
        var target: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 51.6, longitude: 17.2)
        var camera: GMSCameraPosition = GMSCameraPosition(target: target, zoom: 6, bearing: 0, viewingAngle: 0)
        mapView = GMSMapView(frame: CGRectMake(0, 0, screenSize!.width, screenSize!.height))
        if let map = mapView? {
            map.myLocationEnabled = true
            map.camera = camera
            map.delegate = self
            map.settings.myLocationButton = true
            map.settings.compassButton = true
            map.padding = UIEdgeInsets(top: self.topLayoutGuide.length + 5, left: 0, bottom: 30, right: 0)
            
            self.view.addSubview(mapView!)
        }
    }
    
    
    
    func initMarkers() {
        for art in arts {
            addMarker(art)
        }
    }
    
    
    
    func addMarker(art: Art) {
        if art.iconImage != nil {
            GMarker.addMarkerForArt(art, mapView!)
        }
    }
    
    
    
    func dismissArtViewController() {
        self.dismissViewControllerAnimated(true, completion: nil)
        createRouteAndAppropriateZoom(currentLocation, tappedMarker!.position)
    }
    
    
    
    func dismissArtViewControllerWithowtShowingRout() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    
    func createRouteAndAppropriateZoom(firstLocation: CLLocationCoordinate2D?, _ secondLocation: CLLocationCoordinate2D) {
        if let location = firstLocation {
            createRoute(location, secondLocation)
            let bounds = GMSCoordinateBounds(coordinate: location, coordinate: secondLocation)
            let boundsCameraUpdate = GMSCameraUpdate.fitBounds(bounds, withPadding: 30)
            mapView!.animateWithCameraUpdate(boundsCameraUpdate)
        } else {
            mapView!.camera = GMSCameraPosition(target: secondLocation, zoom: 14, bearing: 0, viewingAngle: 0)
            cantCreateRouteAlert()
        }
    }
    
    
    
    func cantCreateRouteAlert() {
        let title = "Warning"
        let message = "Sorry, can't create route!"
        let alertDialog = UIAlertView(title: title, message: message, delegate: nil, cancelButtonTitle: "OK")
        alertDialog.show()
    }
    
    
    
    func mapView(mapView: GMSMapView!, didTapMarker marker: GMSMarker!) -> Bool {
        tappedMarker = marker as? GMarker
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
    
    
    
    func createPolyline(data: NSData!) {
        let jsonResult: NSDictionary = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: nil) as NSDictionary
        let routes: [NSDictionary] = jsonResult["routes"] as [NSDictionary]
        if routes.count == 0 {
            return
        }
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
    }
    
    
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        currentLocation = (locations as [CLLocation])[locations.count - 1].coordinate
        if firstLook {
            firstLook = false
            var camera: GMSCameraPosition = GMSCameraPosition(target: currentLocation!, zoom: 14, bearing: 0, viewingAngle: 0)
            mapView!.camera = camera
            if artForRoute != nil && homeViewController!.isMemberOfClass(ArtViewController.self) {
                createRouteAndAppropriateZoom(currentLocation, artForRoute!.location!)
                artForRoute = nil
            }
        }
    }
    
    
    
    func orientationChanged() {
        if !updateScreenSize() {
            return
        }
        var frame = mapView!.frame
        frame.size.width = mapView!.frame.size.height
        frame.size.height = mapView!.frame.size.width
        mapView!.frame = frame
        
        frame = screenSize!
        homeToolbar.frame.origin.y = frame.height - 30
        homeToolbar.frame.size.width = frame.width
    }
    
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == SHOW_ART_SEGUE_ID {
            let artViewController = segue.destinationViewController as ArtViewController
            artViewController.art = tappedMarker!.art
            artViewController.delegate = self
        }
    }
    
}