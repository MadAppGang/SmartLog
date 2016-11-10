//
//  Session.swift
//  SmartLog
//
//  Created by Dmytro Lisitsyn on 6/16/16.
//  Copyright © 2016 MadAppGang. All rights reserved.
//

import Foundation

func == (lhs: Session, rhs: Session) -> Bool {
    return lhs.hashValue == rhs.hashValue
}

struct Session: Equatable, Hashable {
    
    let id: Int
    let dateStarted: Date
    
    var activityType: ActivityType = .any
    var sent = false

    var duration: TimeInterval?
    var samplesCount: (accelerometerData: Int?, hrData: Int?)
    var markersCount: Int?
    var notes: String?
    
    var hashValue: Int {
        return id.hashValue
    }
    
    init(id: Int, dateStarted: Date) {
        self.id = id
        self.dateStarted = dateStarted
    }
}

extension Session {
    
    var durationValue: TimeInterval {
        return duration ?? 0
    }
    
    var samplesCountValue: (accelerometerData: Int, hrData: Int) {
        return (accelerometerData: samplesCount.accelerometerData ?? 0, hrData: samplesCount.hrData ?? 0)
    }
    
    var markersCountValue: Int {
        return markersCount ?? 0
    }
    
}
