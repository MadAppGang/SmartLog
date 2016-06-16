//
//  AccelerometerData.swift
//  SmartHeartTraining
//
//  Created by Dmytro Lisitsyn on 6/15/16.
//  Copyright © 2016 MadAppGang. All rights reserved.
//

import Foundation

struct AccelerometerData {
    let sessionID: Int
    let x: Int
    let y: Int
    let z: Int
    let dateTaken: NSDate
    
//    init(bytes: [UInt8], length: Int) {
//        let data = NSMutableData(bytes: bytes, length: length)
//        var range = NSRange(location: 0, length: 0)
//        
//        var inoutX: Int16 = 0
//        range.location += range.length
//        range.length = 2
//        data.subdataWithRange(range).getBytes(&inoutX, length: sizeof(Int16))
//        x = Int(inoutX)
//        
//        var inoutY: Int16 = 0
//        range.location += range.length
//        range.length = 2
//        data.subdataWithRange(range).getBytes(&inoutY, length: sizeof(Int16))
//        y = Int(inoutY)
//
//        var inoutZ: Int16 = 0
//        range.location += range.length
//        range.length = 2
//        data.subdataWithRange(range).getBytes(&inoutZ, length: sizeof(Int16))
//        z = Int(inoutZ)
//
//        var inoutTimestamp: UInt32 = 0
//        range.location += range.length
//        range.length = 4
//        data.subdataWithRange(range).getBytes(&inoutTimestamp, length: sizeof(UInt32))
//        timestamp = NSTimeInterval(inoutTimestamp) * 1000
//    }
}