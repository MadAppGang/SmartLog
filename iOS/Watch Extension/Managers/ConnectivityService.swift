//
//  ConnectivityService.swift
//  SmartLog
//
//  Created by Dmytro Lisitsyn on 10/11/16.
//  Copyright © 2016 MadAppGang. All rights reserved.
//

import Foundation

enum ConnectivityServiceError: Error {
    case connectivityIsNotSupported
}

protocol ConnectivityService {
    
    var connectionActivated: Bool { get }
    
    func sendAccelerometerData(sessionID: Int, x: Double, y: Double, z: Double, dateTaken: Date)
    func sendMarker(sessionID: Int, dateAdded: Date)
    func sendActivityType(sessionID: Int, activityType: Int)
    func sendSessionFinished(sessionID: Int, accelerometerDataSamplesCount: Int, markersCount: Int)
}
