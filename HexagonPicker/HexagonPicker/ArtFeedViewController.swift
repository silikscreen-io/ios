//
//  ArtFeedViewController.swift
//  HexagonPicker
//
//  Created by Vlasov Illia on 23.10.14.
//  Copyright (c) 2014 vaisoft. All rights reserved.
//

import UIKit

class ArtFeedViewController: UIViewController, GMapViewControllerDelegate {
    
    let SHOW_MAP_SEGUE_ID = "showMapSegue"

    @IBOutlet weak var scrollView: UIScrollView!
    
    var buttonsToolbar: UIToolbar!
    var buttonItems: [UIBarItem] = []
    var homeToolbar: UIToolbar!
    var homeToolbarItems: [UIBarItem]!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initNavigationBar()
    }
    
    
    
    func initNavigationBar() {
        var frame = self.view.bounds
        frame.origin.y = frame.height
        frame.size.height = 20
        homeToolbar = UIToolbar()
        addToolbar(&homeToolbar, frame)
        initHomeToolbar()
        
        println(frame)
        frame.origin.y = self.view.bounds.height - 40
        frame.size.height += 20
        println(frame)
        buttonsToolbar = UIToolbar()
        addToolbar(&buttonsToolbar, frame)
        initButtonsToolbar()
    }
    
    
    
    func addToolbar(inout toolbar: UIToolbar!, _ frame: CGRect) {
        toolbar!.frame = frame
        toolbar!.barStyle = UIBarStyle.Black
        toolbar!.alpha = 0.7
        self.view.addSubview(toolbar!)
    }
    
    
    
    func initHomeToolbar() {
        var item = UIBarButtonItem(title: "Home", style: UIBarButtonItemStyle.Plain, target: self, action: "homeButtonTapped")
        item.setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.whiteColor()], forState: UIControlState.Normal)
        var space = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
        homeToolbarItems = Array(arrayLiteral: space, item, space)
        homeToolbar.items = homeToolbarItems
    }
    
    
    
    func initButtonsToolbar() {
        var item = UIBarButtonItem(image: UIImage(named: "map_icon.png"), style: UIBarButtonItemStyle.Plain, target: self, action: "mapButtonTapped")
        item.setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.whiteColor()], forState: UIControlState.Normal)
        var space = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
        buttonItems = Array(arrayLiteral: space, item, space)
        buttonsToolbar.items = buttonItems
    }
    
    
    
    func homeButtonTapped() {
        var newPosition = self.view.bounds.height
        UIView.animateWithDuration(0.4, animations: {
            self.homeToolbar.frame.origin.y = newPosition
        })
    }
    
    
    
    func mapButtonTapped() {
        performSegueWithIdentifier("showMapSegue", sender: self)
    }
    
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == SHOW_MAP_SEGUE_ID {
            let mapViewController = segue.destinationViewController as GMapViewController
            mapViewController.delegate = self
        }
    }
    
    
    
    func dismissGMapViewController() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    


    override func shouldAutorotate() -> Bool {
        return false
    }

}
