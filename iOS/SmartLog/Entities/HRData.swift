//
//  HRData.swift
//  SmartLog
//
//  Created by Dmytro Lisitsyn on 11/9/16.
//  Copyright © 2016 MadAppGang. All rights reserved.
//

import Foundation

enum HRSensorContactStatus {
    case notSupported
    case detected
    case lost
}

struct HRData {
    let heartRate: Int
    let sensorContactStatus: HRSensorContactStatus
    let dateTaken: Date
}
