//
//  AccelerometerData.swift
//  SmartLog
//
//  Created by Dmytro Lisitsyn on 6/15/16.
//  Copyright © 2016 MadAppGang. All rights reserved.
//

import Foundation

func == (lhs: AccelerometerData, rhs: AccelerometerData) -> Bool {
    return lhs.hashValue == rhs.hashValue
}

struct AccelerometerData: Equatable, Hashable {
    
    let sessionID: Int
    let x: Int
    let y: Int
    let z: Int
    let dateTaken: Date
    
    var hashValue: Int {
        return dateTaken.hashValue
    }
}
