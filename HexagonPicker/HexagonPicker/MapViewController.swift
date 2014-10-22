//
//  MapViewController.swift
//  HexagonPicker
//
//  Created by Vlasov Illia on 21.10.14.
//  Copyright (c) 2014 vaisoft. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

let iOS8Delta = (((UIDevice.currentDevice().systemVersion as NSString).floatValue >= 8.0 ) ? true : false )


class MapViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    let reuseAnnotationId = "myAnnotation"
    let locationManager = CLLocationManager()
    
    var pickedAnnotation: MyAnnotation?
    var currentLocation: CLLocationCoordinate2D?

    @IBOutlet weak var mapView: MKMapView!
    
    var firstLook = true
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        locationManager.distanceFilter = 10
        if (iOS8Delta) {
            locationManager.requestAlwaysAuthorization()
            locationManager.requestWhenInUseAuthorization()
        }
        locationManager.startUpdatingLocation()
        mapView!.delegate = self
        mapView!.showsUserLocation = true
//        Picture1(25.810941, -80.195838).JPG
//        Picture2(25.813176, -80.195365).jpg
//        Picture3(25.811619, -80.191840).JPG
        var annotation = MyAnnotation(coordinate: CLLocationCoordinate2D(latitude: 25.810941, longitude: -80.195838), title: "Picture 1", subtitle: "25.810941, -80.195838")
//        addAnnotation(25.810941, -80.195838, 1)
//        addAnnotation(25.813176, -80.195365, 2)
//        addAnnotation(25.811619, -80.191840, 3)
        addAnnotation(50.491927, 30.336178, 1)
        addAnnotation(50.421927, 30.436178, 2)
        addAnnotation(50.471927, 30.406178, 3)
    }
    
    
    
    func addAnnotation(latitude: Double, _ longitude: Double, _ pictureNumber: Int) {
        var annotation = MyAnnotation(coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude), title: "Picture \(pictureNumber)", subtitle: "\(latitude), \(longitude)")
        mapView.addAnnotation(annotation)
    }
    
    
    
    func mapView(mapView: MKMapView!, didSelectAnnotationView view: MKAnnotationView!) {
        pickedAnnotation = view.annotation as? MyAnnotation
        if pickedAnnotation!.routeDisplayed {
            //mapView.removeOverlay(overlay: MKOverlay!)
        } else {
            createRoute(pickedAnnotation!.coordinate, currentLocation!)
        }
    }
    
    
    
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        
        if annotation is MKUserLocation {
            return nil
        }
        
        
        var annotationView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseAnnotationId)
        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseAnnotationId)
            annotationView!.canShowCallout = true
            annotationView!.image = UIImage(named: "annotation")
        } else {
            annotationView!.annotation = annotation
        }
        
        return annotationView
    }
    
    
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        currentLocation = (locations as [CLLocation])[locations.count - 1].coordinate
        if (firstLook) {
            firstLook = false
            let region = MKCoordinateRegionMakeWithDistance(currentLocation!, 250, 250)
            mapView.setRegion(region, animated: true)
            //var points = calculateRoutes(CLLocationCoordinate2D(latitude: 50.421927, longitude: 30.436178), currentLocation!)
        }
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
                let locations = self.getLocationsFromRequest(responseData)
                var locationsPointer = UnsafeMutablePointer<CLLocationCoordinate2D>(locations)
                let route = MKPolyline(coordinates: locationsPointer, count: locations.count)
                dispatch_async(dispatch_get_main_queue(), {
                    let routeOverlayIndex = self.mapView.overlaysInLevel(MKOverlayLevel.AboveRoads).count
                    self.pickedAnnotation?.routeOverlayIndex = routeOverlayIndex
                    self.pickedAnnotation?.routeDisplayed = true
                    self.mapView.insertOverlay(route, atIndex: routeOverlayIndex, level: MKOverlayLevel.AboveRoads)
                })
            } else {
            }
        })
    }
    
    
    
    func getLocationsFromRequest(data: NSData!) -> [CLLocationCoordinate2D] {
        var jsonResult: NSDictionary = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: nil) as NSDictionary
        var routes: [NSDictionary] = jsonResult.objectForKey("routes") as [NSDictionary]
        var locations: [CLLocationCoordinate2D] = []
        for route in routes {
            var legs: [NSDictionary] = route.objectForKey("legs") as [NSDictionary]
            for leg in legs {
                var steps: [NSDictionary] = leg.objectForKey("steps") as [NSDictionary]
                for step in steps {
                    var polyline = (step.objectForKey("polyline") as NSDictionary).objectForKey("points") as String
                    var location = decodePolyline(polyline)
                    locations.append(location)
                }
            }
        }
        return locations
    }
    
    
    
    func mapView(mapView: MKMapView!, rendererForOverlay overlay: MKOverlay!) -> MKOverlayRenderer! {
        var renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = UIColor.blueColor()
        renderer.lineWidth = 5.0
        return renderer
    }
    
    
    
    func decodePolyline(encoded: NSString) -> CLLocationCoordinate2D {
        var index = 0
        var lat = 0
        var lng = 0
        var b = 0
        var shift = 0
        var result: NSInteger = 0
        do {
            b = encoded.characterAtIndex(index++) - 63
            result |= (b & 0x1f) << shift
            shift += 5
        } while (b >= 0x20)
        var dlat: NSInteger = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1))
        lat += dlat
        shift = 0
        result = 0
        do {
            b = encoded.characterAtIndex(index++) - 63
            result |= (b & 0x1f) << shift
            shift += 5
        } while (b >= 0x20)
        var dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1))
        lng += dlng
        return CLLocationCoordinate2D(latitude: Double(lat) * 1e-5, longitude: Double(lng) * 1e-5)
    }

}
