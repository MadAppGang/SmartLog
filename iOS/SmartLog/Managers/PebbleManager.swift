//
//  PebbleManager.swift
//  SmartLog
//
//  Created by Dmytro Lisitsyn on 5/30/16.
//  Copyright © 2016 MadAppGang. All rights reserved.
//

import Foundation
import PebbleKit

final class PebbleManager: NSObject {
    
    fileprivate enum SessionType: UInt32 {
        case accelerometerData = 101
        case markers = 102
        case activityType = 103
    }
    
    private let appUUID = UUID(uuidString: "b03b0098-9fa6-4653-848e-ad280b4881bf")!
    
    fileprivate let pebbleDataSaver: PebbleDataSaver
    fileprivate let loggingService: LoggingService?
    
    fileprivate var watch: PBWatch?

    init(pebbleDataSaver: PebbleDataSaver, loggingService: LoggingService? = nil) {
        self.pebbleDataSaver = pebbleDataSaver
        self.loggingService = loggingService
        
        super.init()
        
        PBPebbleCentral.default().appUUID = appUUID
        PBPebbleCentral.default().delegate = self
        PBPebbleCentral.default().dataLoggingService(forAppUUID: appUUID)?.delegate = self
        PBPebbleCentral.default().run()
    }
    
    deinit {
        watch?.releaseSharedSession()
    }
}

extension PebbleManager: WearableService {
    
}

extension PebbleManager: PBPebbleCentralDelegate {
    
    func pebbleCentral(_ central: PBPebbleCentral, watchDidConnect watch: PBWatch, isNew: Bool) {
        if let _ = self.watch { return }
        self.watch = watch
        
        loggingService?.log("Pebble connected: \(watch.name)")

        watch.appMessagesAddReceiveUpdateHandler { [weak self] _, info -> Bool in
            guard let weakSelf = self else { return false }
            
            weakSelf.loggingService?.log("✉️: \(info)")
            
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
    
    func pebbleCentral(_ central: PBPebbleCentral, watchDidDisconnect watch: PBWatch) {
        if watch == self.watch {
            self.watch = nil
            
            loggingService?.log("Pebble disconnected: \(watch.name)")
        }
    }
}

extension PebbleManager: PBDataLoggingServiceDelegate {
    
    func dataLoggingService(_ service: PBDataLoggingService, hasByteArrays bytes: UnsafePointer<UInt8>, numberOfItems: UInt16, forDataLoggingSession session: PBDataLoggingSessionMetadata) -> Bool {
        guard numberOfItems > 0 else { return true }
        guard let sessionType = SessionType(rawValue: session.tag) else { return true }

        let dataType: PebbleData.DataType
        let dataTypeIcon: String

        switch sessionType {
        case .accelerometerData:
            dataType = .accelerometerData
            dataTypeIcon = "📈"
        case .markers:
            dataType = .markers
            dataTypeIcon = "🚩"
        case .activityType:
            dataType = .activityType
            dataTypeIcon = "🏊🏼"
        }
        
        loggingService?.log("\(dataTypeIcon): \(numberOfItems) 🕰: \(session.timestamp)")
        
        let bytesCount = Int(numberOfItems) * Int(session.itemSize)
        let bytesArray = Array(UnsafeBufferPointer(start: bytes, count: bytesCount)) as [UInt8]
        pebbleDataSaver.save(bytes: bytesArray, of: dataType, sessionTimestamp: session.timestamp)
        
        return true
    }
    
    func dataLoggingService(_ service: PBDataLoggingService, sessionDidFinish session: PBDataLoggingSessionMetadata) {
        guard let sessionType = SessionType(rawValue: session.tag) else { return }
        
        switch sessionType {
        case .accelerometerData:
            loggingService?.log("📈: Finished 🕰: \(session.timestamp)")
        case .markers:
            loggingService?.log("🚩: Finished 🕰: \(session.timestamp)")
        case .activityType:
            loggingService?.log("🏊🏼: Finished 🕰: \(session.timestamp)")
        }
    }
}
