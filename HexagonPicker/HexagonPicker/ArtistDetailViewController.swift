//
//  ArtistDetailViewController.swift
//  HexagonPicker
//
//  Created by Vlasov Illia on 30.10.14.
//  Copyright (c) 2014 vaisoft. All rights reserved.
//

import UIKit

class ArtistDetailViewController: CollectionsViewController {
    
    var artist: Artist?
    
    override func viewDidLoad() {
        personName = artist!.name
        artsSource = artist!.arts
        super.viewDidLoad()
    }
}