//
//  AccelerometerDataMapper.swift
//  SmartHeartTraining
//
//  Created by Dmytro Lisitsyn on 7/8/16.
//  Copyright © 2016 MadAppGang. All rights reserved.
//

import Foundation

final class AccelerometerDataMapper {
    
    static func toAccelerometerData(cdAccelerometerData cdAccelerometerData: CDAccelerometerData) -> AccelerometerData {
        let sessionID = cdAccelerometerData.session?.id?.integerValue ?? 0
        let x = cdAccelerometerData.x?.integerValue ?? 0
        let y = cdAccelerometerData.y?.integerValue ?? 0
        let z = cdAccelerometerData.z?.integerValue ?? 0
        let dateTaken = cdAccelerometerData.dateTaken ?? NSDate()
        
        let accelerometerDataItem = AccelerometerData(sessionID: sessionID, x: x, y: y, z: z, dateTaken: dateTaken)
        return accelerometerDataItem
    }
    
    static func map(cdAccelerometerData cdAccelerometerData: CDAccelerometerData, with accelerometerData: AccelerometerData, and cdSession: CDSession) -> CDAccelerometerData {
        
        cdAccelerometerData.x = accelerometerData.x
        cdAccelerometerData.y = accelerometerData.y
        cdAccelerometerData.z = accelerometerData.z
        cdAccelerometerData.dateTaken = accelerometerData.dateTaken
        cdSession.addAccelerometerDataObject(cdAccelerometerData)

        return cdAccelerometerData
    }

}