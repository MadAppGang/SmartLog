//
//  SessionsService.swift
//  SmartLog
//
//  Created by Dmytro Lisitsyn on 10/11/16.
//  Copyright © 2016 MadAppGang. All rights reserved.
//

import Foundation

enum SessionsServiceError: Error {
    case accelerometerIsUnavailable
}

protocol SessionsService {
    
    func beginSession(activityType: ActivityType) throws
    func endSession()
    func addMarker()
    
}
