//
//  MyAnnotation.swift
//  HexagonPicker
//
//  Created by Vlasov Illia on 21.10.14.
//  Copyright (c) 2014 vaisoft. All rights reserved.
//

import UIKit
import MapKit

class MyAnnotation : NSObject, MKAnnotation {
    
    var routeOverlayIndex: Int?
    var routeDisplayed = false
    var route: MKPolyline?
    
    var coordinate: CLLocationCoordinate2D
    var title: String
    var subtitle: String
    
    init(coordinate: CLLocationCoordinate2D, title: String, subtitle: String) {
        self.coordinate = coordinate
        self.title = title
        self.subtitle = subtitle
    }
    
    
    
    func setRouteOverlayIndex(mapView: MKMapView) {
        routeOverlayIndex = mapView.overlaysInLevel(MKOverlayLevel.AboveRoads).count
    }
}
