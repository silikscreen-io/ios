//
//  Artist.swift
//  HexagonPicker
//
//  Created by Vlasov Illia on 30.10.14.
//  Copyright (c) 2014 vaisoft. All rights reserved.
//

import UIKit

var artists: [String: Artist] = [:]
let ARTIST_NAME_FIELD_ID = "artist_name"

class Artist: NSObject {
    
    var name: String = "Name unavailable"
   
    var arts: [Art] = []
    
    
    init(_ name: String) {
        self.name = name
    }
    
    
    
    class func addArtist(pfObject: PFObject) {
        let artistName = pfObject[ARTIST_NAME_FIELD_ID] as String!
        var artist = artists[artistName]
        if artist == nil {
            artist = Artist(artistName)
        }
        artist!.arts.append(Art.addArt(artist!, pfObject))
    }
}
