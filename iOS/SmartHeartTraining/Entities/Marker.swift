//
//  Marker.swift
//  SmartLog
//
//  Created by Dmytro Lisitsyn on 6/17/16.
//  Copyright © 2016 MadAppGang. All rights reserved.
//

import Foundation

func == (lhs: Marker, rhs: Marker) -> Bool {
    return lhs.hashValue == rhs.hashValue
}

struct Marker: Equatable, Hashable {
    
    let sessionID: Int
    let dateAdded: Date
    
    var hashValue: Int {
        return dateAdded.hashValue
    }
    
}
