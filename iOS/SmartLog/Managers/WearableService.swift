//
//  WearableService.swift
//  SmartLog
//
//  Created by Dmytro Lisitsyn on 6/16/16.
//  Copyright © 2016 MadAppGang. All rights reserved.
//

import Foundation

enum WearableImplementation {
    static let pebble = "Pebble"
    static let watch = "Watch"
    static let polar = "Polar"
}

protocol WearableService {
    
    var deviceAvailable: Bool { get }
    
    func displayHeartRate(_ heartRate: Int)
    
}

extension WearableService {
    
    func displayHeartRate(_ heartRate: Int) {
        
    }
    
}
