//
//  HRDataMapper.swift
//  SmartLog
//
//  Created by Dmytro Lisitsyn on 11/9/16.
//  Copyright © 2016 MadAppGang. All rights reserved.
//

import Foundation

final class HRDataMapper {
    
    static func toHRData(cdHRData: CDHRData) -> HRData {
        let sessionID = cdHRData.session?.id?.intValue ?? 0
        let heartRate = cdHRData.heartRate?.intValue ?? 0
        let dateTaken = cdHRData.dateTaken ?? NSDate()

        let sensorContactStatus: HRSensorContactStatus
        if let rawValue = cdHRData.sensorContactStatusValue?.intValue, let contactStatus = HRSensorContactStatus(rawValue: rawValue) {
            sensorContactStatus = contactStatus
        } else {
            sensorContactStatus = .notSupported
        }
        
        let hrData = HRData(sessionID: sessionID, heartRate: heartRate, sensorContactStatus: sensorContactStatus, dateTaken: dateTaken as Date)
        return hrData
    }
    
    static func map(cdHRData: CDHRData, with hrData: HRData, and cdSession: CDSession) -> CDHRData {
        cdHRData.heartRate = hrData.heartRate as NSNumber?
        cdHRData.sensorContactStatusValue = hrData.sensorContactStatus.rawValue as NSNumber?
        cdHRData.dateTaken = hrData.dateTaken as NSDate?
        cdSession.addToHrData(cdHRData)
        
        return cdHRData
    }
    
}
