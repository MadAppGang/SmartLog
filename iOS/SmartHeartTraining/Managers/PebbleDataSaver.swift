//
//  PebbleDataSaver.swift
//  SmartHeartTraining
//
//  Created by Dmytro Lisitsyn on 7/7/16.
//  Copyright © 2016 MadAppGang. All rights reserved.
//

import Foundation

final class PebbleDataSaver {
    
    enum Purpose {
        case using
        case testing
    }
    
    private let purpose: Purpose
    
    private let storageService: StorageService

    private var pebbleDataHandlingRunning = false
    private var pebbleDataToHandleIDs: Set<Int> = []
    
    init(purpose: Purpose, storageService: StorageService) {
        self.storageService = storageService
        self.purpose = purpose
        
        pebbleDataToHandleIDs = storageService.fetchPebbleDataIDs()
        
        if case .using = purpose {
            handlePebbleData()
        }
    }
    
    func save(accelerometerDataBytes bytes: [UInt8], sessionTimestamp: UInt32, completion: ((pebbleDataID: Int) -> ())? = nil) {
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_UTILITY, 0)) {
            let id = NSUUID().hashValue
            let sessionID = Int(sessionTimestamp)
            let data = NSData(bytes: bytes, length: bytes.count * sizeof(UInt8))
            let pebbleData = PebbleData(id: id, sessionID: sessionID, dataType: .accelerometerData, binaryData: data)
            
            self.storageService.create(pebbleData) {
                dispatch_async(dispatch_get_main_queue()) {
                    completion?(pebbleDataID: id)
                    
                    guard case .using = self.purpose else { return }
                    
                    self.pebbleDataToHandleIDs.insert(id)
                    if !(self.pebbleDataHandlingRunning) {
                        self.handlePebbleData()
                    }
                }
            }
        }
    }
    
    func save(markersData data: [UInt32], sessionTimestamp: UInt32, completion: ((pebbleDataID: Int) -> ())? = nil) {
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_UTILITY, 0)) {
            let id = NSUUID().hashValue
            let sessionID = Int(sessionTimestamp)
            let data = NSData(bytes: data, length: data.count * sizeof(UInt32))
            let pebbleData = PebbleData(id: id, sessionID: sessionID, dataType: .marker, binaryData: data)
            
            self.storageService.create(pebbleData) {
                dispatch_async(dispatch_get_main_queue()) {
                    completion?(pebbleDataID: id)
                                        
                    guard case .using = self.purpose else { return }

                    self.pebbleDataToHandleIDs.insert(id)
                    if !(self.pebbleDataHandlingRunning) {
                        self.handlePebbleData()
                    }
                }
            }
        }
    }
    
    private func handlePebbleData() {
        pebbleDataHandlingRunning = pebbleDataToHandleIDs.first != nil
        guard let pebbleDataID = pebbleDataToHandleIDs.first else { return }
        
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_UTILITY, 0)) {
            if let pebbleData = self.storageService.fetchPebbleData(pebbleDataID: pebbleDataID) {
                switch pebbleData.dataType {
                case .accelerometerData:
                    var accelerometerData: [AccelerometerData] = []
                    
                    let count = pebbleData.binaryData.length / sizeof(UInt8)
                    var bytes = [UInt8](count: count, repeatedValue: 0)
                    pebbleData.binaryData.getBytes(&bytes, length: pebbleData.binaryData.length)
                    
                    let batchSize = 10 // Batch size in bytes (configured in pebble app).
                    let bytesBatchesToConvert = count / batchSize - 1
                    
                    for index in 0...bytesBatchesToConvert {
                        let batchFirstByteIndex = index * batchSize
                        let batchLastByteIndex = batchFirstByteIndex + batchSize
                        
                        let accelerometerDataBytes = Array(bytes[batchFirstByteIndex..<batchLastByteIndex])
                        let tenthOfTimestamp = NSTimeInterval(index % 10) / 10
                        let accelerometerDataSample = self.convertToAccelerometerData(bytes: accelerometerDataBytes, length: batchSize, sessionID: pebbleData.sessionID, tenthOfTimestamp: tenthOfTimestamp)
                        accelerometerData.append(accelerometerDataSample)
                    }
                    
                    var session = self.getOrCreateSession(sessionID: pebbleData.sessionID)
                    
                    session.samplesCount = session.samplesCountValue + accelerometerData.count
                    
                    let batchesPerSecond = 10 // Based on 10Hz frequency presetted in Pebble app
                    session.duration = Double(session.samplesCountValue) / Double(batchesPerSecond)
                    
                    self.storageService.createOrUpdate(session) {
                        self.storageService.create(accelerometerData) {
                            self.storageService.deletePebbleData(pebbleDataID: pebbleDataID) {
                                dispatch_async(dispatch_get_main_queue()) {
                                    self.pebbleDataToHandleIDs.remove(pebbleDataID)
                                    self.handlePebbleData()
                                }
                            }
                        }
                    }
                    
                case .marker:
                    var markersData = [UInt32](count: pebbleData.binaryData.length / sizeof(UInt32), repeatedValue: 0)
                    pebbleData.binaryData.getBytes(&markersData, length: pebbleData.binaryData.length)
                    
                    let markers = markersData.map({ Marker(sessionID: pebbleData.sessionID, dateAdded: NSDate(timeIntervalSince1970: NSTimeInterval($0))) })
                    
                    var session = self.getOrCreateSession(sessionID: pebbleData.sessionID)
                    session.markersCount = session.markersCountValue + markers.count
                    
                    self.storageService.createOrUpdate(session) {
                        self.storageService.create(markers) {
                            self.storageService.deletePebbleData(pebbleDataID: pebbleDataID) {
                                dispatch_async(dispatch_get_main_queue()) {
                                    self.pebbleDataToHandleIDs.remove(pebbleDataID)
                                    self.handlePebbleData()
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func convertToAccelerometerData(bytes bytes: [UInt8], length: Int, sessionID: Int, tenthOfTimestamp: NSTimeInterval) -> AccelerometerData {
        let data = NSMutableData(bytes: bytes, length: length)
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
    
    private func getOrCreateSession(sessionID sessionID: Int) -> Session {
        let session: Session
        if let existingSession = storageService.fetchSession(sessionID: sessionID) {
            session = existingSession
        } else {
            session = Session(id: sessionID, dateStarted: NSDate(timeIntervalSince1970: NSTimeInterval(sessionID)))
        }
        
        return session
    }
}