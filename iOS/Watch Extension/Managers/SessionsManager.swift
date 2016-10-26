//
//  SessionsManager.swift
//  SmartLog
//
//  Created by Dmytro Lisitsyn on 10/10/16.
//  Copyright © 2016 MadAppGang. All rights reserved.
//

import Foundation
import CoreMotion

final class SessionsManager {
    
    fileprivate let motionManager: CMMotionManager
    fileprivate let connectivityService: ConnectivityService
    
    fileprivate var currentSessionID = 0
    fileprivate var acceleromterDataSamplesCount = 0
    fileprivate var markersCount = 0
    
    private let accelerometerUpdateInterval: TimeInterval = 0.1
    
    init(connectivityService: ConnectivityService) {
        self.connectivityService = connectivityService
        
        motionManager = CMMotionManager()
        motionManager.accelerometerUpdateInterval = accelerometerUpdateInterval
    }
}

extension SessionsManager: SessionsService {

    func beginSession(activityType: ActivityType) throws {
        guard motionManager.isAccelerometerAvailable else {
            throw SessionsServiceError.accelerometerIsUnavailable
        }
        
        currentSessionID = Int(Date().timeIntervalSince1970)
        connectivityService.sendActivityType(sessionID: currentSessionID, activityType: activityType.rawValue)
        
        let operationQueue = OperationQueue()
        operationQueue.qualityOfService = .utility
        
        motionManager.startAccelerometerUpdates(to: operationQueue) { accelerometerData, error in
            guard let accelerometerData = accelerometerData else { return }
            
            self.acceleromterDataSamplesCount += 1
            self.connectivityService.sendAcceleromterData(sessionID: self.currentSessionID, x: accelerometerData.acceleration.x, y: accelerometerData.acceleration.y, z: accelerometerData.acceleration.z, dateTaken: Date(timeIntervalSince1970: accelerometerData.timestamp))
        }
    }
    
    func endSession() {
        guard motionManager.isAccelerometerActive else { return }
        
        motionManager.stopAccelerometerUpdates()
        
        connectivityService.sendSessionFinished(sessionID: currentSessionID, accelerometerDataSamplesCount: acceleromterDataSamplesCount, markersCount: markersCount)
        
        currentSessionID = 0
        acceleromterDataSamplesCount = 0
        markersCount = 0
    }
    
    func addMarker() {
        markersCount += 1
        connectivityService.sendMarker(sessionID: currentSessionID, dateAdded: Date())
    }
}
