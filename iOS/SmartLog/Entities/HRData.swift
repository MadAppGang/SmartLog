//
//  HRData.swift
//  SmartLog
//
//  Created by Dmytro Lisitsyn on 11/9/16.
//  Copyright © 2016 MadAppGang. All rights reserved.
//

import Foundation

enum HRSensorContactStatus: Int {
    case notSupported = 0
    case detected = 1
    case lost = 2
}

func == (lhs: HRData, rhs: HRData) -> Bool {
    return lhs.hashValue == rhs.hashValue
}

struct HRData: Equatable, Hashable {
    
    let sessionID: Int
    let heartRate: Int
    let sensorContactStatus: HRSensorContactStatus
    let dateTaken: Date
    
    var hashValue: Int {
        return dateTaken.hashValue
    }
}
