//
//  SessionMapper.swift
//  SmartLog
//
//  Created by Dmytro Lisitsyn on 6/28/16.
//  Copyright © 2016 MadAppGang. All rights reserved.
//

import Foundation

final class SessionMapper {
    
    static func toSession(cdSession: CDSession) -> Session {
        let id = cdSession.id?.intValue ?? 0
        let dateStarted = cdSession.dateStarted ?? NSDate(timeIntervalSince1970: 0)
        var session = Session(id: id, dateStarted: dateStarted as Date)
        
        session.duration = cdSession.duration?.doubleValue
        session.samplesCount.accelerometerData = cdSession.accelerometerDataSamplesCount?.intValue
        session.samplesCount.hrData = cdSession.hrDataSamplesCount?.intValue
        session.markersCount = cdSession.markersCount?.intValue
        session.notes = cdSession.notes
        session.sent = cdSession.sent?.boolValue ?? false

        if let rawValue = cdSession.activityType?.intValue, let activityType = ActivityType(rawValue: rawValue) {
            session.activityType = activityType
        }

        return session
    }
}
