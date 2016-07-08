//
//  PebbleData.swift
//  SmartHeartTraining
//
//  Created by Dmytro Lisitsyn on 7/7/16.
//  Copyright © 2016 MadAppGang. All rights reserved.
//

import Foundation

struct PebbleData {

    enum PebbleDataType: Int {
        case accelerometerData = 0
        case markers = 1
    }
    
    let sessionID: Int
    let type: PebbleDataType
    let binaryData: NSData
    
}