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
    
    private let appUUIDString = "b03b0098-9fa6-4653-848e-ad280b4881bf"
    
    private let storageService: StorageService
    private let loggingService: LoggingService?
    
    private var watch: PBWatch?

    init(storageService: StorageService, loggingService: LoggingService? = nil) {
        self.storageService = storageService
        self.loggingService = loggingService
        
        super.init()
        
        configurePebbleCentral()
    }
    
    deinit {
        watch?.releaseSharedSession()
    }
    
    private func configurePebbleCentral() {
        guard let appUUID = NSUUID(UUIDString: appUUIDString) else { return }
        PBPebbleCentral.defaultCentral().appUUID = appUUID
        
        PBPebbleCentral.defaultCentral().delegate = self
        PBPebbleCentral.defaultCentral().dataLoggingServiceForAppUUID(appUUID)?.delegate = self
        
        PBPebbleCentral.defaultCentral().run()
    }
    
    private func convertToAccelerometerData(bytes bytes: [UInt8], length: UInt16, sessionID: Int, tenthOfTimestamp: NSTimeInterval) -> AccelerometerData {
        let data = NSMutableData(bytes: bytes, length: Int(length))
        var range = NSRange(location: 0, length: 0)
        
        var inoutX: Int16 = 0
        range.location += range.length
        range.length = 2
        data.subdataWithRange(range).getBytes(&inoutX, length: sizeof(Int16))
        let x = Int(inoutX)
        
        var inoutY: Int16 = 0
        range.location += range.length
        range.length = 2
        data.subdataWithRange(range).getBytes(&inoutY, length: sizeof(Int16))
        let y = Int(inoutY)
        
        var inoutZ: Int16 = 0
        range.location += range.length
        range.length = 2
        data.subdataWithRange(range).getBytes(&inoutZ, length: sizeof(Int16))
        let z = Int(inoutZ)
        
        var inoutTimestamp: UInt32 = 0
        range.location += range.length
        range.length = 4
        data.subdataWithRange(range).getBytes(&inoutTimestamp, length: sizeof(UInt32))
        let timestamp = NSTimeInterval(inoutTimestamp)
        
        let accelerometerData = AccelerometerData(sessionID: sessionID, x: x, y: y, z: z, dateTaken: NSDate(timeIntervalSince1970: timestamp + tenthOfTimestamp))
        return accelerometerData
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

        let sessionID = Int(session.timestamp)
        let sessionData = SessionData(id: sessionID, dateStarted: NSDate(timeIntervalSince1970: NSTimeInterval(session.timestamp)))
        storageService.createOrUpdate(sessionData)
        
        for index in 0...Int(numberOfItems) {
            let markerData = MarkerData(sessionID: sessionID, dateAdded: NSDate(timeIntervalSince1970: NSTimeInterval(data[index])))
            storageService.create(markerData)
            
            loggingService?.log("Marker: \(markerData.sessionID) \(markerData.dateAdded)")
        }
        
        return true
    }
    
    func dataLoggingService(service: PBDataLoggingService, hasByteArrays bytes: UnsafePointer<UInt8>, numberOfItems: UInt16, forDataLoggingSession session: PBDataLoggingSessionMetadata) -> Bool {
        guard session.tag == DataLoggingSessionType.accelerometerData.rawValue else { return true }

        let bytesCount = Int(numberOfItems) * Int(session.itemSize)
        guard bytesCount > 0 else { return true }

        let sessionID = Int(session.timestamp)
        let sessionData = SessionData(id: sessionID, dateStarted: NSDate(timeIntervalSince1970: NSTimeInterval(session.timestamp)))
        storageService.createOrUpdate(sessionData)
        
        let bytes = Array(UnsafeBufferPointer(start: UnsafePointer(bytes), count: bytesCount)) as [UInt8]
        let bytesBatchesToConvert = bytes.count / Int(session.itemSize) - 1
        
        for index in 0...bytesBatchesToConvert {
            let batchFirstByteIndex = index * Int(session.itemSize)
            let batchLastByteIndex = batchFirstByteIndex + Int(session.itemSize)

            let accelerometerDataBytes = Array(bytes[batchFirstByteIndex..<batchLastByteIndex])
            let tenthOfTimestamp = NSTimeInterval(index % 10) / 10
            let accelerometerData = convertToAccelerometerData(bytes: accelerometerDataBytes, length: session.itemSize, sessionID: sessionID, tenthOfTimestamp: tenthOfTimestamp)
            
            storageService.create(accelerometerData)
            
            loggingService?.log("Accel: \(accelerometerData.sessionID) \(accelerometerData.x) \(accelerometerData.y) \(accelerometerData.z) \(accelerometerData.dateTaken.timeIntervalSince1970)")
        }
        
        NSNotificationCenter.defaultCenter().postNotificationName(WearableServiceNotificationType.NewDataReceived.rawValue, object: self)
        
        return true
    }
    
    func dataLoggingService(service: PBDataLoggingService, sessionDidFinish session: PBDataLoggingSessionMetadata) {
        loggingService?.log("Session finished: \(session)")
    }
}