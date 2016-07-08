//
//  PebbleDataKey.swift
//  SmartHeartTraining
//
//  Created by Dmytro Lisitsyn on 7/7/16.
//  Copyright © 2016 MadAppGang. All rights reserved.
//

import Foundation

func == (lhs: PebbleDataKey, rhs: PebbleDataKey) -> Bool {
    return lhs.hashValue == rhs.hashValue
}

struct PebbleDataKey: Equatable, Hashable {

    enum DataType: Int {
        case accelerometerData = 0
        case marker = 1
    }
    
    let sessionID: Int
    let dataType: DataType
    
    var hashValue: Int {
        return "\(sessionID)\(dataType.rawValue)".hashValue
    }
    
}