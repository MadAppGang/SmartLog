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

    private var keysForPebbleDataToHandle: Set<PebbleDataKey> = []
    
    init(storageService: StorageService) {
        self.storageService = storageService
    }
    
    func save(accelerometerDataBytes bytes: [UInt8], sessionTimestamp: UInt32, completion: (() -> ())? = nil) {
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_UTILITY, 0)) {
            let data = NSData(bytes: bytes, length: bytes.count * sizeof(UInt8))
            let pebbleDataKey = PebbleDataKey(sessionID: Int(sessionTimestamp), dataType: .accelerometerData)
            
            self.storageService.createOrUpdate(pebbleBinaryData: data, for: pebbleDataKey) {
                dispatch_async(dispatch_get_main_queue()) {
                    completion?()
                }
            }
        }
    }
    
    func save(markersData data: [UInt32], sessionTimestamp: UInt32, completion: (() -> ())? = nil) {
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_UTILITY, 0)) {
            let data = NSData(bytes: data, length: data.count * sizeof(UInt32))
            let pebbleDataKey = PebbleDataKey(sessionID: Int(sessionTimestamp), dataType: .marker)
            
            self.storageService.createOrUpdate(pebbleBinaryData: data, for: pebbleDataKey) {
                dispatch_async(dispatch_get_main_queue()) {
                    completion?()
                }
            }
        }
    }
    
    func handlePebbleData() {
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_UTILITY, 0)) {
//            let pebbleDataKey = self.keysForPebbleDataToHandle.first
            
        }
    }
    
//    sessionData.samplesCount = (sessionData.samplesCount ?? 0) + Int(numberOfItems)
//    
//    let batchesPerSecond = 10 // Based on 10Hz frequency presetted in Pebble app
//    sessionData.duration = Double((sessionData.samplesCount ?? 0) / batchesPerSecond)
//    
//    storageService.createOrUpdate(sessionData)
//    
//    let bytes = Array(UnsafeBufferPointer(start: UnsafePointer(bytes), count: bytesCount)) as [UInt8]
//    let bytesBatchesToConvert = bytes.count / Int(session.itemSize) - 1
//    
//    for index in 0...bytesBatchesToConvert {
//    let batchFirstByteIndex = index * Int(session.itemSize)
//    let batchLastByteIndex = batchFirstByteIndex + Int(session.itemSize)
//    
//    let accelerometerDataBytes = Array(bytes[batchFirstByteIndex..<batchLastByteIndex])
//    let tenthOfTimestamp = NSTimeInterval(index % 10) / 10
//    let accelerometerData = convertToAccelerometerData(bytes: accelerometerDataBytes, length: session.itemSize, sessionID: sessionID, tenthOfTimestamp: tenthOfTimestamp)
//    
//    storageService.create(accelerometerData)
//    }
    
    //        let sessionID = Int(session.timestamp)
    //        var sessionData = getOrCreateSession(sessionID: sessionID)
    //
    //        sessionData.markersCount = (sessionData.markersCount ?? 0) + Int(numberOfItems)
    //
    //        storageService.createOrUpdate(sessionData)
    //
    //        for index in 0...Int(numberOfItems) where data[index] > 0 {
    //            let marker = Marker(sessionID: sessionID, dateAdded: NSDate(timeIntervalSince1970: NSTimeInterval(data[index])))
    //            storageService.create(marker)
    //        }
    //
    
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