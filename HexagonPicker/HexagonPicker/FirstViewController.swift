//
//  FirstViewController.swift
//  Silkscreen
//
//  Created by Vlasov Illia on 05.11.14.
//  Copyright (c) 2014 vaisoft. All rights reserved.
//

import UIKit


protocol ClearOnDismiss {
    func clear()
}


var presentedViewControllers: [ClearOnDismiss] = []


class FirstViewController: UIViewController {

    @IBOutlet weak var loginButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if NSUserDefaults.standardUserDefaults().boolForKey("UserLoddedIn") {
            loginButton.hidden = true
        }
    }
    
    
    
    override func viewDidAppear(animated: Bool) {
        if NSUserDefaults.standardUserDefaults().boolForKey("UserLoddedIn") {
            performSegueWithIdentifier("loginSegue", sender: self)
        }
    }
    
    
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }

}
