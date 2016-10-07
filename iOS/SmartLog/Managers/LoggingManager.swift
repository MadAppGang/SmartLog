//
//  LoggingManager.swift
//  SmartLog
//
//  Created by Dmytro Lisitsyn on 6/17/16.
//  Copyright © 2016 MadAppGang. All rights reserved.
//

import Foundation

final class LoggingManager {
    
    weak var delegate: LoggingServiceDelegate?

    var logString = ""
    
}

extension LoggingManager: LoggingService {
    
    func log(_ string: String) {
        if logString.characters.count > 500000 {
            logString = ""
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss.SSS"

        logString = "\(logString)\n\(formatter.string(from: Date())): \(string)"
        
        delegate?.logDidChange(logString)
    }
    
    func clear() {
        logString = ""
        
        delegate?.logDidChange(logString)
    }
    
}
