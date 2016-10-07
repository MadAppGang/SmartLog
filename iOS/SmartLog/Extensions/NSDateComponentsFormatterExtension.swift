//
//  NSDateComponentsFormatterExtension.swift
//  SmartLog
//
//  Created by Ievgen Rudenko on 4/1/16.
//  Copyright © 2016 MadAppGang. All rights reserved.
//

import Foundation

extension DateComponentsFormatter {
    
    static var durationInMinutesAndSecondsFormatter: DateComponentsFormatter {
        let formatter = DateComponentsFormatter()
        
        formatter.allowedUnits = [.minute, .second]
        formatter.maximumUnitCount = 2
        formatter.unitsStyle = .short
        
        return formatter
    }
    
}
