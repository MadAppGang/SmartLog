//
//  AccelerometerDataMapper.swift
//  SmartHeartTraining
//
//  Created by Dmytro Lisitsyn on 7/8/16.
//  Copyright © 2016 MadAppGang. All rights reserved.
//

import Foundation

final class AccelerometerDataMapper {
    
    static func toAccelerometerData(cdAccelerometerData: CDAccelerometerData) -> AccelerometerData {
        let sessionID = cdAccelerometerData.session?.id?.intValue ?? 0
        let x = cdAccelerometerData.x?.intValue ?? 0
        let y = cdAccelerometerData.y?.intValue ?? 0
        let z = cdAccelerometerData.z?.intValue ?? 0
        let dateTaken = cdAccelerometerData.dateTaken ?? Date()
        
        let accelerometerDataItem = AccelerometerData(sessionID: sessionID, x: x, y: y, z: z, dateTaken: dateTaken)
        return accelerometerDataItem
    }
    
    static func map(cdAccelerometerData: CDAccelerometerData, with accelerometerData: AccelerometerData, and cdSession: CDSession) -> CDAccelerometerData {
        
        cdAccelerometerData.x = accelerometerData.x as NSNumber?
        cdAccelerometerData.y = accelerometerData.y as NSNumber?
        cdAccelerometerData.z = accelerometerData.z as NSNumber?
        cdAccelerometerData.dateTaken = accelerometerData.dateTaken
        cdSession.addAccelerometerDataObject(cdAccelerometerData)

        return cdAccelerometerData
    }

}
