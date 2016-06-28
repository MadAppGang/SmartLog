//
//  Session.swift
//  SmartHeartTraining
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
    let dateStarted: NSDate
    
    var duration: NSTimeInterval?
    var samplesCount: Int?
    var markersCount: Int?
    var notes: String?
    
    var hashValue: Int {
        return id.hashValue
    }
    
    init(id: Int, dateStarted: NSDate) {
        self.id = id
        self.dateStarted = dateStarted
    }
    
}