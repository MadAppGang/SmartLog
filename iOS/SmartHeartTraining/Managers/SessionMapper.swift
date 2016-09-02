//
//  SessionMapper.swift
//  SmartHeartTraining
//
//  Created by Dmytro Lisitsyn on 6/28/16.
//  Copyright © 2016 MadAppGang. All rights reserved.
//

import Foundation

final class SessionMapper {
    
    static func toSession(cdSession cdSession: CDSession) -> Session {
        let id = cdSession.id?.integerValue ?? 0
        let dateStarted = cdSession.dateStarted ?? NSDate(timeIntervalSince1970: 0)
        var session = Session(id: id, dateStarted: dateStarted)
        
        session.duration = cdSession.duration?.doubleValue
        session.samplesCount = cdSession.samplesCount?.integerValue
        session.markersCount = cdSession.markersCount?.integerValue
        session.notes = cdSession.notes
        session.sent = cdSession.sent?.boolValue ?? false

        if let rawValue = cdSession.activityType?.integerValue, let activityType = ActivityType(rawValue: rawValue) {
            session.activityType = activityType
        }

        return session
    }
}