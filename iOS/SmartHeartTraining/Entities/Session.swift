//
//  Session.swift
//  SmartHeartTraining
//
//  Created by Dmytro Lisitsyn on 6/16/16.
//  Copyright © 2016 MadAppGang. All rights reserved.
//

import Foundation

enum ActivityType: Int {
    case any = 0
    case butterfly = 1
    case backstroke = 2
    case breaststroke = 3
    case freestyle = 4
}

func == (lhs: Session, rhs: Session) -> Bool {
    return lhs.hashValue == rhs.hashValue
}

struct Session: Equatable, Hashable {
    
    let id: Int
    let dateStarted: NSDate
    
    var activityType: ActivityType = .any
    var sent = false

    var duration: NSTimeInterval?
    var samplesCount: Int?
    var markersCount: Int?
    var notes: String?
    
    var hashValue: Int {
        return id.hashValue
    }
    
    var durationValue: NSTimeInterval {
        return duration ?? 0
    }
    
    var samplesCountValue: Int {
        return samplesCount ?? 0
    }
    
    var markersCountValue: Int {
        return markersCount ?? 0
    }
    
    init(id: Int, dateStarted: NSDate) {
        self.id = id
        self.dateStarted = dateStarted
    }
}