//
//  FirstViewController.swift
//  Silkscreen
//
//  Created by Vlasov Illia on 05.11.14.
//  Copyright (c) 2014 vaisoft. All rights reserved.
//

import UIKit

class FirstViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    
    override func viewDidAppear(animated: Bool) {
        if NSUserDefaults.standardUserDefaults().boolForKey("UserLoddedIn") {
            performSegueWithIdentifier("loginSegue", sender: self)
        }
    }

}
