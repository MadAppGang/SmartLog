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
    
    enum DataLoggingSessionType: UInt32 {
        case accelerometerData = 101
        case marker = 102
    }
    
    private let appUUID = NSUUID(UUIDString: "b03b0098-9fa6-4653-848e-ad280b4881bf")!
    
    private let pebbleDataSaver: PebbleDataSaver
    private let loggingService: LoggingService?
    
    private var watch: PBWatch?

    init(pebbleDataSaver: PebbleDataSaver, loggingService: LoggingService? = nil) {
        self.pebbleDataSaver = pebbleDataSaver
        self.loggingService = loggingService
        
        super.init()
        
        PBPebbleCentral.defaultCentral().appUUID = appUUID
        PBPebbleCentral.defaultCentral().delegate = self
        PBPebbleCentral.defaultCentral().dataLoggingServiceForAppUUID(appUUID)?.delegate = self
        PBPebbleCentral.defaultCentral().run()
    }
    
    deinit {
        watch?.releaseSharedSession()
    }
}

extension PebbleManager: WearableService {
    
}

extension PebbleManager: PBPebbleCentralDelegate {
    
    func pebbleCentral(central: PBPebbleCentral, watchDidConnect watch: PBWatch, isNew: Bool) {
        if let _ = self.watch { return }
        self.watch = watch
        
        loggingService?.log("Pebble connected: \(watch.name)")

        watch.appMessagesAddReceiveUpdateHandler { [weak self] _, info -> Bool in
            guard let weakSelf = self else { return false }
            
            weakSelf.loggingService?.log("Received message:\n\(info)")
            
            return true
        }
        
        watch.appMessagesPushUpdate([:]) { [weak self] _, _, error in
            guard let weakSelf = self else { return }

            if let error = error {
                weakSelf.loggingService?.log("Initial message sending error: \(error.localizedDescription)")
            } else {
                weakSelf.loggingService?.log("Initial message successfully sent")
            }
        }
    }
    
    func pebbleCentral(central: PBPebbleCentral, watchDidDisconnect watch: PBWatch) {
        if watch == self.watch {
            self.watch = nil
            
            loggingService?.log("Pebble disconnected: \(watch.name)")
        }
    }
}

extension PebbleManager: PBDataLoggingServiceDelegate {
    
    func dataLoggingService(service: PBDataLoggingService, hasUInt32s data: UnsafePointer<UInt32>, numberOfItems: UInt16, forDataLoggingSession session: PBDataLoggingSessionMetadata) -> Bool {
        guard session.tag == DataLoggingSessionType.marker.rawValue else { return true }
        guard numberOfItems > 0 else { return true }
        
        let data = Array(UnsafeBufferPointer(start: UnsafePointer(data), count: Int(numberOfItems))) as [UInt32]
        pebbleDataSaver.save(markersData: data, sessionTimestamp: session.timestamp)
        
        loggingService?.log("🚩: \(numberOfItems) 🕰: \(session.timestamp)")
        
        return true
    }
    
    func dataLoggingService(service: PBDataLoggingService, hasByteArrays bytes: UnsafePointer<UInt8>, numberOfItems: UInt16, forDataLoggingSession session: PBDataLoggingSessionMetadata) -> Bool {
        guard session.tag == DataLoggingSessionType.accelerometerData.rawValue else { return true }

        let bytesCount = Int(numberOfItems) * Int(session.itemSize)
        guard bytesCount > 0 else { return true }
        
        let bytes = Array(UnsafeBufferPointer(start: UnsafePointer(bytes), count: bytesCount)) as [UInt8]
        pebbleDataSaver.save(accelerometerDataBytes: bytes, sessionTimestamp: session.timestamp)
        
        loggingService?.log("📈: \(bytes.count / Int(session.itemSize)) 🕰: \(session.timestamp)")
        
        return true
    }
    
    func dataLoggingService(service: PBDataLoggingService, sessionDidFinish session: PBDataLoggingSessionMetadata) {
        guard let type = DataLoggingSessionType(rawValue: session.tag) else { return }
        
        switch type {
        case .accelerometerData:
            loggingService?.log("📈: Finished 🕰: \(session.timestamp)")
        case .marker:
            loggingService?.log("🚩: Finished 🕰: \(session.timestamp)")
        }
    }
}