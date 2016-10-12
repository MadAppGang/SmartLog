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
    
    private let accelerometerUpdateInterval: TimeInterval = 0.1
    
    init(connectivityService: ConnectivityService) {
        self.connectivityService = connectivityService
        
        motionManager = CMMotionManager()
        motionManager.accelerometerUpdateInterval = accelerometerUpdateInterval
    }
    
}

extension SessionsManager: SessionsService {

    func beginSession() throws {
        guard motionManager.isAccelerometerAvailable else {
            throw SessionsServiceError.accelerometerIsUnavailable
        }
        
        let operationQueue = OperationQueue()
        operationQueue.qualityOfService = .utility
        
        motionManager.startAccelerometerUpdates(to: operationQueue) { accelerometerData, error in
            if let accelerometerData = accelerometerData {
                print("\(accelerometerData.acceleration.x) \(accelerometerData.acceleration.y) \(accelerometerData.acceleration.z) \(accelerometerData.timestamp)")
            }
        }
    }
    
    func endSession() {
        guard motionManager.isAccelerometerActive else { return }
        
        motionManager.stopAccelerometerUpdates()
    }
    
    func addMarker() {
        
    }
}
