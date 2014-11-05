//
//  Art.swift
//  HexagonPicker
//
//  Created by Vlasov Illia on 24.10.14.
//  Copyright (c) 2014 vaisoft. All rights reserved.
//

import UIKit

let IMAGE_FOR_ART_LOADED_NOTIFICATION_ID = "imageForArtLoadedNotification"
let IMAGE_FOR_ART_RELOADED_NOTIFICATION_ID = "imageForArtReloadedNotification"
let ICON_LOADED_NOTIFICATION_ID = "iconLoadedNotification"
let PREVIEW_LOADED_NOTIFICATION_ID = "previewLoadedNotification"

var arts: [Art] = []
var artsDictionary: [String: Art] = [:]
var artsDisplayed: [Art] = []
let MAX_NUMBER_OF_LOADED_IMAGES = 20
var currentNumberOfLoadedImages = 0
var iconAdded = 0

protocol ArtDelegate {
    func artTapped(art: Art)
}


class Art: NSObject {
    let LOCATION_FIELD_ID = "location"
    let LATITUDE_FIELD_ID = "lat"
    let LONGITUDE_FIELD_ID = "lng"
    let ART_DESCRIPTION_ID = "image_alt"
    let WORK_STATUS_ID = "work_status"
    
    var delegate: ArtDelegate?
    
    var pfObject: PFObject?
    var pfObjectAdditionalResources: PFObject?
    
    weak var artist: Artist?
   
    var image: UIImage?
    var iconImage: UIImage?
    var previewImage: UIImage?
    var artDescription: String = "Description unavailable"
    var artStatus: String = "Status unavailable"
    var location: CLLocationCoordinate2D?
    
    var imageIndex: Int?
    
    
    init(_ artist: Artist?, _ pfObject: PFObject) {
        super.init()
        if artist != nil {
            self.artist = artist
            self.artist!.addArt(self)
        }
        self.pfObject = pfObject
        let locationObject = pfObject[LOCATION_FIELD_ID] as PFGeoPoint
        self.location = CLLocationCoordinate2D(latitude: locationObject.latitude, longitude: locationObject.longitude)
        artDescription = pfObject[ART_DESCRIPTION_ID] as String
        artStatus = pfObject[WORK_STATUS_ID] as String
        loadImage()
    }
    
    
    
    func loadImage(_ artView: ArtView? = nil, _ forFeed: Bool = true) {
        if currentNumberOfLoadedImages < MAX_NUMBER_OF_LOADED_IMAGES || !forFeed {
            if forFeed {
                currentNumberOfLoadedImages++
            }
//            println("Image started load: \(currentNumberOfLoadedImages)")
            self.imageIndex = currentNumberOfLoadedImages
            let imageFile = pfObject!["image"] as PFFile
            imageFile.getDataInBackgroundWithBlock {(imageData: NSData!, error: NSError!) -> Void in
                if error == nil {
                    self.image = UIImage(data:imageData)
                    artsDisplayed.append(self)
                    NSNotificationCenter.defaultCenter().postNotificationName(IMAGE_FOR_ART_LOADED_NOTIFICATION_ID, object: nil, userInfo: ["art" : self, "artView": artView == nil ? NSNull() : artView!, "loadedForFeed": NSNumber(bool: forFeed)])
                }
            }
        }
    }
    
    
    
    func reloadImage(artView: ArtView) {
        self.imageIndex = currentNumberOfLoadedImages
        let imageFile = pfObject!["image"] as PFFile
        imageFile.getDataInBackgroundWithBlock {(imageData: NSData!, error: NSError!) -> Void in
            if error == nil {
                //println("Image end load: \(self.imageIndex)")
                self.image = UIImage(data:imageData)
                //                    currentNumberOfLoadedImages++
                //println("Image loaded: \(NSDate().timeIntervalSince1970)")
                artsDisplayed.append(self)
                NSNotificationCenter.defaultCenter().postNotificationName(IMAGE_FOR_ART_RELOADED_NOTIFICATION_ID, object: nil, userInfo: ["art" : self, "artView": artView])
            }
        }
    }
    
    
    
    convenience init(_ imageName: String, _ location: CLLocationCoordinate2D) {
        self.init(UIImage(named: imageName)!, location)
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
        art.pfObject = pfObject
        arts.append(art)
        artsDictionary[pfObject["objectId"] as String] = art
        return art
    }
    
    
    
    class func addArt(pfObject: PFObject) {
        let artistsIds = pfObject["artist"] as NSArray
        var artist: Artist?
        if artists.count > 0 {
            let artistId = artistsIds[0] as? String
            if artistId != nil {
                artist = artists[artistId!]
            }
        }
        let art = Art(artist, pfObject)
        art.pfObject = pfObject
        arts.append(art)
        artsDictionary[pfObject.objectId] = art
    }
    
    
    
    class func addAdditionalResources(pfObject: PFObject) {
        let artObject = pfObject["art"] as PFObject
        let art = artsDictionary[artObject.objectId]!
        var imageFile = pfObject["thumbnail"] as PFFile
        imageFile.getDataInBackgroundWithBlock {(imageData: NSData!, error: NSError!) -> Void in
            if error == nil {
                art.iconImage = UIImage(data:imageData)
                NSNotificationCenter.defaultCenter().postNotificationName(ICON_LOADED_NOTIFICATION_ID, object: nil, userInfo: ["art": art])
//                println("Image icon added: \(iconAdded++)")
            }
        }
        art.pfObjectAdditionalResources = pfObject
    }
    
    
    
    func getPreview() {
        var imageFile = pfObjectAdditionalResources!["preview"] as PFFile
        imageFile.getDataInBackgroundWithBlock {(imageData: NSData!, error: NSError!) -> Void in
            if error == nil {
                let image = UIImage(data:imageData)!
                NSNotificationCenter.defaultCenter().postNotificationName(PREVIEW_LOADED_NOTIFICATION_ID, object: nil, userInfo: ["preview" :image])
            }
        }
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
