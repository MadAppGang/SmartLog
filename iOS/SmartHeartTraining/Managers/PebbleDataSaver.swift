//
//  PebbleDataSaver.swift
//  SmartHeartTraining
//
//  Created by Dmytro Lisitsyn on 7/7/16.
//  Copyright © 2016 MadAppGang. All rights reserved.
//

import Foundation

final class PebbleDataSaver {
    
    private let storageService: StorageService

    private var pebbleDataHandlingRunning = false
    private var pebbleDataToHandleIDs: Set<Int> = []
    
    private var dataSavingCompletionBlocks: [Int: () -> ()] = [:]
    
    init(storageService: StorageService) {
        self.storageService = storageService
        
        pebbleDataToHandleIDs = storageService.fetchPebbleDataIDs()
        
        handlePebbleData()
    }
    
    func save(accelerometerDataBytes bytes: [UInt8], sessionTimestamp: UInt32, completion: (() -> ())? = nil) {
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_UTILITY, 0)) {
            let id = NSUUID().hashValue
            let sessionID = Int(sessionTimestamp)
            let data = NSData(bytes: bytes, length: bytes.count * sizeof(UInt8))
            let pebbleData = PebbleData(id: id, sessionID: sessionID, dataType: .accelerometerData, binaryData: data)
            
            self.storageService.create(pebbleData) {
                dispatch_async(dispatch_get_main_queue()) {
                    self.pebbleDataToHandleIDs.insert(id)
                    if let completion = completion {
                        self.dataSavingCompletionBlocks[id] = completion
                    }
                    
                    if !(self.pebbleDataHandlingRunning) {
                        self.handlePebbleData()
                    }
                }
            }
        }
    }
    
    func save(markersData data: [UInt32], sessionTimestamp: UInt32, completion: (() -> ())? = nil) {
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_UTILITY, 0)) {
            let id = NSUUID().hashValue
            let sessionID = Int(sessionTimestamp)
            let data = NSData(bytes: data, length: data.count * sizeof(UInt32))
            let pebbleData = PebbleData(id: id, sessionID: sessionID, dataType: .marker, binaryData: data)
            
            self.storageService.create(pebbleData) {
                dispatch_async(dispatch_get_main_queue()) {
                    self.pebbleDataToHandleIDs.insert(id)
                    if let completion = completion {
                        self.dataSavingCompletionBlocks[id] = completion
                    }
                    
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
            guard let pebbleData = self.storageService.fetchPebbleData(pebbleDataID: pebbleDataID) else { return }
            
            let creatingCompletion: () -> () = {
                dispatch_async(dispatch_get_main_queue()) {
                    self.pebbleDataToHandleIDs.remove(pebbleDataID)
                    if let completionBlock = self.dataSavingCompletionBlocks[pebbleDataID] {
                        self.dataSavingCompletionBlocks.removeValueForKey(pebbleDataID)

                        completionBlock()
                    }
                    
                    self.handlePebbleData()
                }
            }
            
            switch pebbleData.dataType {
            case .accelerometerData:
                self.createAccelerometerData(from: pebbleData, completion: creatingCompletion)
            case .marker:
                self.createMarkers(from: pebbleData, completion: creatingCompletion)
            }
        }
    }
    
    private func createAccelerometerData(from pebbleData: PebbleData, completion: () -> ()) {
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
            let accelerometerDataSample = convertToAccelerometerData(bytes: accelerometerDataBytes, sessionID: pebbleData.sessionID, tenthOfTimestamp: tenthOfTimestamp)
            
            accelerometerData.append(accelerometerDataSample)
        }
        
        var session = getOrCreateSession(sessionID: pebbleData.sessionID)
        
        session.samplesCount = session.samplesCountValue + accelerometerData.count
        
        let batchesPerSecond = 10 // Based on 10Hz frequency presetted in Pebble app
        session.duration = Double(session.samplesCountValue) / Double(batchesPerSecond)
        
        storageService.createOrUpdate(session) {
            self.storageService.create(accelerometerData) {
                self.storageService.deletePebbleData(pebbleDataID: pebbleData.id) {
                    completion()
                }
            }
        }
    }
    
    private func convertToAccelerometerData(bytes bytes: [UInt8], sessionID: Int, tenthOfTimestamp: NSTimeInterval) -> AccelerometerData {
        var range = 0..<sizeof(Int16)
        let x = Int(UnsafePointer<Int16>(Array(bytes[range])).memory)
        
        range = range.endIndex..<(range.endIndex + sizeof(Int16))
        let y = Int(UnsafePointer<Int16>(Array(bytes[range])).memory)
        
        range = range.endIndex..<(range.endIndex + sizeof(Int16))
        let z = Int(UnsafePointer<Int16>(Array(bytes[range])).memory)
        
        range = range.endIndex..<(range.endIndex + sizeof(UInt32))
        let timestamp = NSTimeInterval(UnsafePointer<UInt32>(Array(bytes[range])).memory)
        
        let accelerometerData = AccelerometerData(sessionID: sessionID, x: x, y: y, z: z, dateTaken: NSDate(timeIntervalSince1970: timestamp + tenthOfTimestamp))
        return accelerometerData
    }
    
    private func createMarkers(from pebbleData: PebbleData, completion: () -> ()) {
        var markersData = [UInt32](count: pebbleData.binaryData.length / sizeof(UInt32), repeatedValue: 0)
        pebbleData.binaryData.getBytes(&markersData, length: pebbleData.binaryData.length)
        
        let markers = markersData.map({ Marker(sessionID: pebbleData.sessionID, dateAdded: NSDate(timeIntervalSince1970: NSTimeInterval($0))) })
        
        var session = getOrCreateSession(sessionID: pebbleData.sessionID)
        session.markersCount = session.markersCountValue + markers.count
        
        storageService.createOrUpdate(session) {
            self.storageService.create(markers) {
                self.storageService.deletePebbleData(pebbleDataID: pebbleData.id) {
                    completion()
                }
            }
        }
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