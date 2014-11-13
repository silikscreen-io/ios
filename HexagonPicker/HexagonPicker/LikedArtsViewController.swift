//
//  LikedArtsViewController.swift
//  Silkscreen
//
//  Created by Vlasov Illia on 13.11.14.
//  Copyright (c) 2014 vaisoft. All rights reserved.
//

import UIKit

class LikedArtsViewController: CollectionsViewController {

    override func viewDidLoad() {
        personName = "Liked"
        artsSource = currentUser!.likes
        super.viewDidLoad()
    }

}
