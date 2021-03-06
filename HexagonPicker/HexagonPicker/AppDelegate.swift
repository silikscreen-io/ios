//
//  AppDelegate.swift
//  HexagonPicker
//
//  Created by Vlasov Illia on 18.10.14.
//  Copyright (c) 2014 vaisoft. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    let ARTISTS_CLASS_NAME = "Artists"
    let ARTS_CLASS_NAME = "Arts"
    let ADDITIONAL_RESOURCES_CLASS_NAME = "AdditionalResources"
    
    let parseApplicationId = "CHd4NrA6zIzEIvYXUKcsOKvo3rLmRNwwt9LV3DwA"
    let parseClientKey = "Fy6hMPkvDVoif4oVXTep04gVi726t22VQdbGdmVW"

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        GMSServices.provideAPIKey("AIzaSyAVpKvbAoNl3qQUiUkdUM9kMKO4rl2SJUM");
        //Art.initArts()
        UIDevice.currentDevice().beginGeneratingDeviceOrientationNotifications()
        Parse.setApplicationId(parseApplicationId, clientKey: parseClientKey)
        PFAnalytics.trackAppOpenedWithLaunchOptions(launchOptions)

        queryArts()
        deviceOrientation = UIDevice.currentDevice().orientation
        let devOrientation =  ((deviceOrientation! == UIDeviceOrientation.Portrait) || (deviceOrientation! == UIDeviceOrientation.PortraitUpsideDown)) ? "Portrait" : "Landscape"
        println("deviceOrientation " + devOrientation)
        
        //Ubertesters.shared().initializeWithOptions(UbertestersActivationModeShake)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "deviceOrientationDidChange:", name: UIDeviceOrientationDidChangeNotification, object: nil)
        return true
    }
    
    
    
    func deviceOrientationDidChange(notification: NSNotification) {
        let orientation = UIDevice.currentDevice().orientation
        
        if orientation == UIDeviceOrientation.PortraitUpsideDown || orientation == UIDeviceOrientation.FaceUp || orientation == UIDeviceOrientation.FaceDown || orientation == UIDeviceOrientation.Unknown || deviceOrientation == orientation || deviceOrientation == nil {
            let devOrientation =  ((deviceOrientation! == UIDeviceOrientation.Portrait) || (deviceOrientation! == UIDeviceOrientation.PortraitUpsideDown)) ? "Portrait" : "Landscape"
            deviceOrientation = orientation;
            return;
        }
        deviceOrientation = orientation;
        deviceOrientationLandscape = (deviceOrientation! != UIDeviceOrientation.Portrait) && (deviceOrientation! != UIDeviceOrientation.PortraitUpsideDown)
        let devOrientation =  ((deviceOrientation! == UIDeviceOrientation.Portrait) || (deviceOrientation! == UIDeviceOrientation.PortraitUpsideDown)) ? "Portrait" : "Landscape"
        //println("deviceOrientationChanged: " + devOrientation)
        NSNotificationCenter.defaultCenter().postNotificationName(ORIENTATION_CHANGED_NOTIFICATION, object: nil)
    }
    
    
    
    func queryArtists() {
        var query = PFQuery(className: ARTISTS_CLASS_NAME)
        query.limit = 1000
        query.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
            if error == nil {
                var allObjects = objects as [PFObject]
                println(sizeofValue(allObjects))
                println(allObjects.count)
                for object in allObjects {
                    Artist.addArtist(object)
                }
            } else {
            }
            Art.connectArtsToArtists()
            Artist.sort()
        }
    }
    
    
    
    func queryArts() {
        println("arts loading started         : \(NSDate().timeIntervalSince1970)")
        var query = PFQuery(className: ARTS_CLASS_NAME)
        query.limit = 1000
        query.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
            if error == nil {
                var allObjects = objects as [PFObject]
                numberOfArts = allObjects.count
                for object in allObjects {
                    Art.addArt(object)
                }
            } else {
            }
            artsDidLoaded = true
            dispatch_async(dispatch_get_main_queue(), {
                NSNotificationCenter.defaultCenter().postNotificationName(ARTS_LOADED_NOTIFICATION, object: nil)
            })
            self.queryArtists()
            self.queryAdditionalResources()
        }
    }
    
    
    
    func queryAdditionalResources() {
        var query = PFQuery(className: ADDITIONAL_RESOURCES_CLASS_NAME)
        query.limit = 1000
        query.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
            if error == nil {
                var allObjects = objects as [PFObject]
                for object in allObjects {
                    Art.addAdditionalResources(object)
                }
            } else {
            }
        }
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

