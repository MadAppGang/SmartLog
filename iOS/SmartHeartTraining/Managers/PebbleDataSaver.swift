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
    
    private var dataSavingCompletionBlocks: [Int: () -> Void] = [:]
    
    init(storageService: StorageService) {
        self.storageService = storageService
        
        storageService.fetchPebbleDataIDs() { pebbleDataToHandleIDs in
            self.pebbleDataToHandleIDs = pebbleDataToHandleIDs
            
            self.handlePebbleData()
        }
    }
    
    func save(accelerometerDataBytes bytes: [UInt8], sessionTimestamp: UInt32, completion: (() -> Void)? = nil) {
        DispatchQueue.global(qos: .utility).async {
            let binaryData = Data(bytes: bytes, count: bytes.count * MemoryLayout<UInt8>.size)
            self.save(binaryData, pebbleDataType: .accelerometerData, sessionTimestamp: sessionTimestamp, completion: completion)
        }
    }
    
    func save(markersData data: [UInt32], sessionTimestamp: UInt32, completion: (() -> Void)? = nil) {
        DispatchQueue.global(qos: .utility).async {
            let binaryData = Data(bytes: data, count: data.count * MemoryLayout<UInt32>.size)
            self.save(binaryData, pebbleDataType: .marker, sessionTimestamp: sessionTimestamp, completion: completion)
        }
    }
    
    func save(activityTypeData data: [UInt8], sessionTimestamp: UInt32, completion: (() -> Void)? = nil) {
        DispatchQueue.global(qos: .utility).async {
            let binaryData = Data(bytes: data, count: data.count * MemoryLayout<UInt8>.size)
            self.save(binaryData, pebbleDataType: .activityType, sessionTimestamp: sessionTimestamp, completion: completion)
        }
    }
    
    /// Completion fires in main thread.
    private func save(_ binaryData: Data, pebbleDataType: PebbleData.DataType, sessionTimestamp: UInt32, completion: (() -> Void)? = nil) {
        let id = UUID().hashValue
        let sessionID = Int(sessionTimestamp)
        let pebbleData = PebbleData(id: id, sessionID: sessionID, dataType: pebbleDataType, binaryData: binaryData)
        
        self.storageService.create(pebbleData, completionQueue: .main) {
            self.pebbleDataToHandleIDs.insert(id)
            if let completion = completion {
                self.dataSavingCompletionBlocks[id] = completion
            }
            
            if !self.pebbleDataHandlingRunning {
                self.handlePebbleData()
            }
        }
    }
    
    private func handlePebbleData() {
        pebbleDataHandlingRunning = pebbleDataToHandleIDs.first != nil
        guard let pebbleDataID = pebbleDataToHandleIDs.first else { return }
        
        let utilityQueue: DispatchQueue = .global(qos: .utility)
        utilityQueue.async {
            self.storageService.fetchPebbleData(pebbleDataID: pebbleDataID, completionQueue: utilityQueue) { pebbleData in
                guard let pebbleData = pebbleData else { return }
                
                let completion: () -> Void = {
                    self.pebbleDataToHandleIDs.remove(pebbleDataID)
                    if let completionBlock = self.dataSavingCompletionBlocks[pebbleDataID] {
                        self.dataSavingCompletionBlocks.removeValue(forKey: pebbleDataID)
                        
                        completionBlock()
                    }
                    
                    self.handlePebbleData()
                }
                
                switch pebbleData.dataType {
                case .accelerometerData:
                    self.createAccelerometerData(from: pebbleData, completionQueue: .main, completion: completion)
                case .marker:
                    self.createMarkers(from: pebbleData, completionQueue: .main, completion: completion)
                case .activityType:
                    self.handleActivityType(from: pebbleData, completionQueue: .main, completion: completion)
                }
            }
        }
    }
    
    private func createAccelerometerData(from pebbleData: PebbleData, completionQueue: DispatchQueue, completion: @escaping () -> Void) {
        var accelerometerData: [AccelerometerData] = []
        
        var bytes = [UInt8](repeating: 0, count: pebbleData.binaryData.count)
        pebbleData.binaryData.copyBytes(to: &bytes, count: bytes.count)
        
        let batchSize = 10 // Batch size in bytes (configured in pebble app).
        let bytesBatchesToConvert = bytes.count / batchSize - 1
        
        for index in 0...bytesBatchesToConvert {
            let batchFirstByteIndex = index * batchSize
            let batchLastByteIndex = batchFirstByteIndex + batchSize
            
            let accelerometerDataBytes = Array(bytes[batchFirstByteIndex..<batchLastByteIndex])
            let tenthOfTimestamp = TimeInterval(index % 10) / 10
            let accelerometerDataSample = convertToAccelerometerData(bytes: accelerometerDataBytes, sessionID: pebbleData.sessionID, tenthOfTimestamp: tenthOfTimestamp)
            
            accelerometerData.append(accelerometerDataSample)
        }
        
        getOrCreateSession(sessionID: pebbleData.sessionID, completionQueue: completionQueue) { session in
            var session = session
            session.samplesCount = session.samplesCountValue + accelerometerData.count
            
            let batchesPerSecond = 10 // Based on 10Hz frequency presetted in Pebble app
            session.duration = Double(session.samplesCountValue) / Double(batchesPerSecond)
            
            self.storageService.createOrUpdate(session, completionQueue: completionQueue) {
                self.storageService.create(accelerometerData, completionQueue: completionQueue) {
                    self.storageService.deletePebbleData(pebbleDataID: pebbleData.id, completionQueue: completionQueue) {
                        completion()
                    }
                }
            }
        }
    }
    
    private func convertToAccelerometerData(bytes: [UInt8], sessionID: Int, tenthOfTimestamp: TimeInterval) -> AccelerometerData {
        var range = 0..<MemoryLayout<Int16>.size
        let x = Int(UnsafePointer(Array(bytes[range])).withMemoryRebound(to: Int16.self, capacity: 1, { $0.pointee }))
        
        range = range.upperBound..<(range.upperBound + MemoryLayout<Int16>.size)
        let y = Int(UnsafePointer(Array(bytes[range])).withMemoryRebound(to: Int16.self, capacity: 1, { $0.pointee }))
        
        range = range.upperBound..<(range.upperBound + MemoryLayout<Int16>.size)
        let z = Int(UnsafePointer(Array(bytes[range])).withMemoryRebound(to: Int16.self, capacity: 1, { $0.pointee }))
        
        range = range.upperBound..<(range.upperBound + MemoryLayout<UInt32>.size)
        let timestamp = TimeInterval(UnsafePointer(Array(bytes[range])).withMemoryRebound(to: UInt32.self, capacity: 1, { $0.pointee }))

        let accelerometerData = AccelerometerData(sessionID: sessionID, x: x, y: y, z: z, dateTaken: Date(timeIntervalSince1970: timestamp + tenthOfTimestamp))
        return accelerometerData
    }
    
    private func createMarkers(from pebbleData: PebbleData, completionQueue: DispatchQueue, completion: @escaping () -> Void) {
        var bytes = [UInt8](repeating: 0, count: pebbleData.binaryData.count)
        pebbleData.binaryData.copyBytes(to: &bytes, count: bytes.count)
        
        let markersData = pebbleData.binaryData.withUnsafeBytes { pointer -> [UInt32] in
            return Array(UnsafeBufferPointer<UInt32>(start: pointer, count: pebbleData.binaryData.count / MemoryLayout<UInt32>.size))
        }
        
        let markers = markersData
            .map({ Marker(sessionID: pebbleData.sessionID, dateAdded: Date(timeIntervalSince1970: TimeInterval($0))) })
            .filter({ $0.dateAdded.timeIntervalSince1970 != 0 })
        
        getOrCreateSession(sessionID: pebbleData.sessionID, completionQueue: completionQueue) { session in
            var session = session
            session.markersCount = session.markersCountValue + markers.count
            
            self.storageService.createOrUpdate(session, completionQueue: completionQueue) {
                self.storageService.create(markers, completionQueue: completionQueue) {
                    self.storageService.deletePebbleData(pebbleDataID: pebbleData.id, completionQueue: completionQueue) {
                        completion()
                    }
                }
            }
        }
    }
    
    private func handleActivityType(from pebbleData: PebbleData, completionQueue: DispatchQueue, completion: @escaping () -> Void) {
        var activityTypeData = [UInt8](repeating: 0, count: pebbleData.binaryData.count)
        pebbleData.binaryData.copyBytes(to: &activityTypeData, count: activityTypeData.count)
        
        getOrCreateSession(sessionID: pebbleData.sessionID, completionQueue: completionQueue) { session in
            var session = session
            if let rawValue = activityTypeData.first, let activityType = ActivityType(rawValue: Int(rawValue)) {
                session.activityType = activityType
            }
            
            self.storageService.createOrUpdate(session, completionQueue: completionQueue) {
                self.storageService.deletePebbleData(pebbleDataID: pebbleData.id, completionQueue: completionQueue) {
                    completion()
                }
            }
        }
    }
    
    private func getOrCreateSession(sessionID: Int, completionQueue: DispatchQueue, completion: @escaping (_ session: Session) -> Void) {
        storageService.fetchSession(sessionID: sessionID, completionQueue: completionQueue) { existingSession in
            if let existingSession = existingSession {
                completion(existingSession)
            } else {
                let session = Session(id: sessionID, dateStarted: Date(timeIntervalSince1970: TimeInterval(sessionID)))
                completion(session)
            }
        }
    }
}
