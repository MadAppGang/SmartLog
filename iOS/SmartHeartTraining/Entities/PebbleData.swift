//
//  PebbleData.swift
//  SmartHeartTraining
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
        case marker = 1
    }
    
    let id: Int
    let sessionID: Int
    let dataType: DataType
    let binaryData: NSData
    
    var hashValue: Int {
        return id.hashValue
    }
    
}