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
        DispatchQueue.main.async {
            if self.logString.characters.count > 500000 {
                self.logString = ""
            }
            
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm:ss.SSS"
            
            self.logString = "\(self.logString)\n\(formatter.string(from: Date())): \(string)"
            
            self.delegate?.logDidChange(self.logString)
        }
    }
    
    func clear() {
        DispatchQueue.main.async {
            self.logString = ""
        
            self.delegate?.logDidChange(self.logString)
        }
    }
    
}
