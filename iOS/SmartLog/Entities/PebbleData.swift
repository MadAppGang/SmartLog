//
//  PebbleData.swift
//  SmartLog
//
//  Created by Dmytro Lisitsyn on 7/7/16.
//  Copyright © 2016 MadAppGang. All rights reserved.
//

import Foundation

func == (lhs: PebbleData, rhs: PebbleData) -> Bool {
    return lhs.hashValue == rhs.hashValue
}

struct PebbleData: Equatable, Hashable {

    enum DataType: Int {
        case accelerometerData = 0
        case markers = 1
        case activityType = 2
    }
    
    let id: Int
    let sessionID: Int
    let dataType: DataType
    let binaryData: Data
    
    var hashValue: Int {
        return id.hashValue
    }
    
}
