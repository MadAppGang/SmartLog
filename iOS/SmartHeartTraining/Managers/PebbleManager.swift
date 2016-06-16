//
//  PebbleManager.swift
//  SmartHeartTraining
//
//  Created by Dmytro Lisitsyn on 5/30/16.
//  Copyright © 2016 MadAppGang. All rights reserved.
//

import Foundation
import PebbleKit

final class PebbleManager: NSObject {
    
    var watch: PBWatch?
    
    override init() {
        super.init()
        
        guard let appUUID = NSUUID(UUIDString: "b03b0098-9fa6-4653-848e-ad280b4881bf") else { return }
        PBPebbleCentral.defaultCentral().appUUID = appUUID
        
        PBPebbleCentral.defaultCentral().delegate = self
        PBPebbleCentral.defaultCentral().dataLoggingServiceForAppUUID(appUUID)?.delegate = self
        
        PBPebbleCentral.defaultCentral().run()
    }
    
    deinit {
        watch?.releaseSharedSession()
    }
}

extension PebbleManager: PBPebbleCentralDelegate {
    
    func pebbleCentral(central: PBPebbleCentral, watchDidConnect watch: PBWatch, isNew: Bool) {
        if let _ = self.watch {
            return
        }
        
        self.watch = watch
        
        watch.appMessagesAddReceiveUpdateHandler { [weak self] _, info -> Bool in
            guard let weakSelf = self else { return false }
            
            return true
        }
        
        watch.appMessagesPushUpdate([:]) { [weak self] _, _, error in
            guard let weakSelf = self else { return }
            
            
        }
    }
    
    func pebbleCentral(central: PBPebbleCentral, watchDidDisconnect watch: PBWatch) {
        if watch == self.watch {
            self.watch = nil
        }
    }
}

extension PebbleManager: PBDataLoggingServiceDelegate {
    
    func dataLoggingService(service: PBDataLoggingService, hasUInt32s data: UnsafePointer<UInt32>, numberOfItems: UInt16, forDataLoggingSession session: PBDataLoggingSessionMetadata) -> Bool {
        for index in 0...Int(numberOfItems) where numberOfItems > 0 {
            if session.tag == 100 {
                
            } else {
                
            }
        }
        
        return true
    }
    
    func dataLoggingService(service: PBDataLoggingService, hasByteArrays bytes: UnsafePointer<UInt8>, numberOfItems: UInt16, forDataLoggingSession session: PBDataLoggingSessionMetadata) -> Bool {
        let count = Int(numberOfItems) * Int(session.itemSize)
        guard count > 0 else { return true }

        let bytes = Array(UnsafeBufferPointer(start: UnsafePointer(bytes), count: count)) as [UInt8]
        let limit = bytes.count / Int(session.itemSize) - 1
        
        for index in 0...limit where numberOfItems > 0 {
            let begin = index * Int(session.itemSize)
            let end = begin + Int(session.itemSize)
            
            let accelerometerDataBytes = Array(bytes[begin..<end])
            let accelData = AccelerometerData(bytes: accelerometerDataBytes, length: Int(session.itemSize))
            
        }
        
        return true
    }
}