//
//  Art.swift
//  HexagonPicker
//
//  Created by Vlasov Illia on 24.10.14.
//  Copyright (c) 2014 vaisoft. All rights reserved.
//

import UIKit

var arts: [Art] = []


protocol ArtDelegate {
    func artTapped(art: Art)
}


class Art: NSObject {
    let LATITUDE_FIELD_ID = "lat"
    let LONGITUDE_FIELD_ID = "lng"
    let ART_DESCRIPTION_ID = "image_alt"
    let WORK_STATUS_ID = "work_status"
    
    var delegate: ArtDelegate?
    
    weak var artist: Artist?
   
    var image: UIImage?
    var iconImage: UIImage?
    var artDescription: String = "Description unavailable"
    var artStatus: String = "Status unavailable"
    var location: CLLocationCoordinate2D?
    
    
    init(_ artist: Artist, _ pfObject: PFObject) {
        super.init()
        let lat = (pfObject[LATITUDE_FIELD_ID] as NSString).doubleValue
        let lng = (pfObject[LONGITUDE_FIELD_ID] as NSString).doubleValue
        location = CLLocationCoordinate2D(latitude: lat, longitude: lng)
//        location = CLLocationCoordinate2D(latitude: pfObject[LATITUDE_FIELD_ID] as CLLocationDegrees, longitude: pfObject[LONGITUDE_FIELD_ID] as CLLocationDegrees)
        artDescription = pfObject[ART_DESCRIPTION_ID] as String
        artStatus = pfObject[WORK_STATUS_ID] as String
        let imageFile = pfObject["image"] as PFFile
        imageFile.getDataInBackgroundWithBlock {(imageData: NSData!, error: NSError!) -> Void in
            if error == nil {
                self.image = UIImage(data:imageData)
                self.initIconImage()
            }
        }
    }
    
    
    convenience init(_ imageName: String, _ location: CLLocationCoordinate2D) {
        self.init(UIImage(named: imageName)!, location)
        initIconImage()
    }
    
    
    
    func initIconImage() {
        var offset = CGPoint()
        var ratio: CGFloat?
        var delta: CGFloat?
        var destinationSize = CGSize(width: 30, height: 30)
        let imageSize = image!.size
        
        ratio = destinationSize.width / imageSize.width;
        if imageSize.width > imageSize.height {
            delta = ratio! * (imageSize.width - imageSize.height);
            offset = CGPointMake(delta! / 2, 0);
        } else {
            delta = ratio! * (imageSize.height - imageSize.width);
            offset = CGPointMake(0, delta! / 2);
        }
        var clipRect = CGRectMake(-offset.x, -offset.y, (ratio! * imageSize.width) + delta!, (ratio! * imageSize.height) + delta!);
        
        if UIScreen.mainScreen().respondsToSelector("scale") {
            UIGraphicsBeginImageContextWithOptions(destinationSize, true, 0.0)
        } else {
            UIGraphicsBeginImageContext(destinationSize);
        }
        UIRectClip(clipRect)
        image!.drawInRect(clipRect)
        self.iconImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext();
    }
    
    
    init(_ image: UIImage, _ location: CLLocationCoordinate2D) {
        self.image = image
        self.location = location
    }
    
    
    
    class func initArts() {
        let locations = [
//            CLLocationCoordinate2D(latitude: 50.491927, longitude: 30.336178),
//            CLLocationCoordinate2D(latitude: 50.421927, longitude: 30.436178),
//            CLLocationCoordinate2D(latitude: 50.471927, longitude: 30.406178),
//            CLLocationCoordinate2D(latitude: 50.431927, longitude: 30.486178),
//            CLLocationCoordinate2D(latitude: 50.441927, longitude: 30.456178),
//            CLLocationCoordinate2D(latitude: 50.461927, longitude: 30.416178),
            
            CLLocationCoordinate2D(latitude: 25.810941, longitude: -80.195838),
            CLLocationCoordinate2D(latitude: 25.813176, longitude: -80.195365),
            CLLocationCoordinate2D(latitude: 25.811619, longitude: -80.191840),
            CLLocationCoordinate2D(latitude: 25.797963, longitude: -80.189307),
            CLLocationCoordinate2D(latitude: 25.798237, longitude: -80.196991),
            CLLocationCoordinate2D(latitude: 25.795400, longitude: -80.206027),
        ]
        for index in 1...6 {
            Art.addArt("Picture\(index).jpg", locations[index - 1])
        }
//        Picture1(25.810941, -80.195838).JPG
//        Picture2(25.813176, -80.195365).jpg
//        Picture3(25.811619, -80.191840).JPG
//        addMarker(50.491927, 30.336178, 1)
//        addMarker(50.421927, 30.436178, 2)
//        addMarker(50.471927, 30.406178, 3)
//        //25.797963, -80.189307 - Picture4
//        //25.798237, -80.196991 - Picture5
//        //25.795400, -80.206027 - Picture6
    }
    
    
    
    class func addArt(artist: Artist, _ pfObject: PFObject) -> Art {
        let art = Art(artist, pfObject)
        arts.append(art)
        return art
    }
    
    
    
    class func addArt(imageName: String, _ location: CLLocationCoordinate2D) {
        let art = Art(imageName, location)
        art.artDescription = imageName
        arts.append(art)
    }
    
    
    
    func tapDetected(gestureRecognizer: UITapGestureRecognizer) {
        delegate!.artTapped(self)
    }
}
