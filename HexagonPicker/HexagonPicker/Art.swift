//
//  Art.swift
//  HexagonPicker
//
//  Created by Vlasov Illia on 24.10.14.
//  Copyright (c) 2014 vaisoft. All rights reserved.
//

import UIKit

var arts: [Art] = []

class Art: NSObject {
   
    var image: UIImage?
    var artDescription: String = "Description"
    var location: CLLocationCoordinate2D?
    
    
    convenience init(_ imageName: String, _ location: CLLocationCoordinate2D) {
        self.init(UIImage(named: imageName)!, location)
    }
    
    
    
    init(_ image: UIImage, _ location: CLLocationCoordinate2D) {
        self.image = image
        self.location = location
    }
    
    
    
    class func initArts() {
        let locations = [
            CLLocationCoordinate2D(latitude: 50.491927, longitude: 30.336178),
            CLLocationCoordinate2D(latitude: 50.421927, longitude: 30.436178),
            CLLocationCoordinate2D(latitude: 50.471927, longitude: 30.406178),
            CLLocationCoordinate2D(latitude: 50.431927, longitude: 30.486178),
            CLLocationCoordinate2D(latitude: 50.441927, longitude: 30.456178),
            CLLocationCoordinate2D(latitude: 50.461927, longitude: 30.416178),
        ]
        for index in 1...6 {
            Art.addArt("Picture\(index).jpg", locations[index - 1])
        }
//        addMarker(50.491927, 30.336178, 1)
//        addMarker(50.421927, 30.436178, 2)
//        addMarker(50.471927, 30.406178, 3)
//        //25.797963, -80.189307 - Picture4
//        //25.798237, -80.196991 - Picture5
//        //25.795400, -80.206027 - Picture6
    }
    
    
    
    class func addArt(imageName: String, _ location: CLLocationCoordinate2D) {
        let art = Art(imageName, location)
        art.artDescription = imageName
        arts.append(art)
    }
}
