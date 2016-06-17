//
//  LoggingService.swift
//  SmartHeartTraining
//
//  Created by Dmytro Lisitsyn on 6/17/16.
//  Copyright © 2016 MadAppGang. All rights reserved.
//

import Foundation

protocol LoggingServiceDelegate: class {
    func logDidChange(logString: String)
}

protocol LoggingService {
    
    weak var delegate: LoggingServiceDelegate? { get set }
    
    var logString: String { get }
    
    func log(string: String)
    func clear()
    
}