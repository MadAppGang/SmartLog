//
//  NSDateComponentsFormatterExtension.swift
//  SmartHeartTraining
//
//  Created by Ievgen Rudenko on 4/1/16.
//  Copyright © 2016 MadAppGang. All rights reserved.
//

import Foundation

extension NSDateComponentsFormatter {
    
    static var durationInMinutesAndSecondsFormatter: NSDateComponentsFormatter {
        let formatter = NSDateComponentsFormatter()
        
        formatter.allowedUnits = [.Minute, .Second]
        formatter.maximumUnitCount = 2
        formatter.unitsStyle = .Short
        
        return formatter
    }
    
}
