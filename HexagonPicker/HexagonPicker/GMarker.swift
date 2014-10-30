//
//  GMarker.swift
//  HexagonPicker
//
//  Created by Vlasov Illia on 24.10.14.
//  Copyright (c) 2014 vaisoft. All rights reserved.
//

import UIKit

class GMarker: GMSMarker {
    
    let art: Art?
    
    
    class func addMarkerForArt(art: Art, _ map: GMSMapView) {
        var marker = GMarker(art, map)
    }
   
    
    init(_ art: Art, _ map: GMSMapView) {
        super.init()
        position = art.location!
        title = art.artDescription
        snippet = "Tap me"
        icon = art.iconImage//UIImage(named: "annotation.png")
        self.map = map
        self.art = art
    }
}
