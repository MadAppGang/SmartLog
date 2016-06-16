//
//  PebbleManager.swift
//  SmartHeartTraining
//
//  Created by Dmytro Lisitsyn on 5/30/16.
//  Copyright © 2016 MadAppGang. All rights reserved.
//

import Foundation
import PebbleKit

protocol PebbleManagerDelegate: class {
    func handleOutputString(string: String)
}

final class PebbleManager: NSObject {
    
    weak var delegate: PebbleManagerDelegate?

    var watch: PBWatch?
    
    override init() {
        super.init()
        
        guard let appUUID = NSUUID(UUIDString: "b03b0098-9fa6-4653-848e-ad280b4881bf") else { return }
        PBPebbleCentral.defaultCentral().appUUID = appUUID
        PBPebbleCentral.defaultCentral().delegate = self
        PBPebbleCentral.defaultCentral().dataLoggingServiceForAppUUID(appUUID)?.delegate = self
        PBPebbleCentral.defaultCentral().run()
        
        let _ = CoreDataManager()
    }
    
    deinit {
        watch?.releaseSharedSession()
    }
    
    private func fetchSession(sessionId sessionId: Int) -> CDSession {
        let sessionToReturn: CDSession
        
        if let savedSession = CDSession.first("id", value: sessionId, inContext: CoreDataManager.context) as? CDSession {
            sessionToReturn = savedSession
        } else {
            sessionToReturn = CDSession.create()
            sessionToReturn.id = sessionId
            
            let _ = try? CoreDataManager.save()
        }
        
        return sessionToReturn
    }
    
    func readFromFile() -> String {
        guard let directory = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true).first else { return "" }
        let filePath = directory.stringByAppendingString("/output.txt")
        
        let string = (try? String(contentsOfFile: filePath, encoding: NSUTF8StringEncoding)) ?? ""
        return string
    }
    
    func addStringToFile(string string: String) {
        guard let directory = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true).first else { return }
        let filePath = directory.stringByAppendingString("/output.txt")
        
        var text = (try? String(contentsOfFile: filePath, encoding: NSUTF8StringEncoding)) ?? ""
        text.appendContentsOf("\(string)\n")
        
        do {
            try text.writeToFile(filePath, atomically: true, encoding: NSUTF8StringEncoding)
        } catch (let error) {
            print(error)
        }
    }
    
    func removeFile() {
        guard let directory = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true).first else { return }
        let filePath = directory.stringByAppendingString("/output.txt")
        
        do {
            try NSFileManager.defaultManager().removeItemAtPath(filePath)
        } catch (let error) {
            print(error)
        }

    }
    
    func optimizeData() {
        guard let directory = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true).first else { return }
        let filePath = directory.stringByAppendingString("/output.txt")
        let optimizedFilePath = directory.stringByAppendingString("/output2.txt")
        
        do {
            try NSFileManager.defaultManager().removeItemAtPath(optimizedFilePath)
        } catch (let error) {
            print(error)
        }
        
        let string = (try? String(contentsOfFile: filePath, encoding: NSUTF8StringEncoding)) ?? ""
        
        var lines: [[String]] = []
        string.enumerateLines { lines.append($0.line.componentsSeparatedByCharactersInSet(NSCharacterSet.whitespaceCharacterSet())) }
        
        var index = -1
        for (indexA, line) in lines.enumerate() where line.count == 5 {
            index += 1
            let add = index % 10 * 100
            
            var changed = line
            changed[4] = "\(Int(line[4])! + add)"
            lines[indexA] = changed
        }
        
        var optimizedString = ""
        for line in lines {
            if line.count == 5 {
                optimizedString.appendContentsOf("\(line[0]),\(line[1]),\(line[2]),\(line[3]),\(line[4])\n")
            } else if line.count == 2 {
                optimizedString.appendContentsOf("\(line[0]),\(line[1])\n")
            }
        }
        
        print(optimizedString)
    }
    
    func readOptimizedFile() -> String {
        guard let directory = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true).first else { return "" }
        let filePath = directory.stringByAppendingString("/output2.txt")
        
        let string = (try? String(contentsOfFile: filePath, encoding: NSUTF8StringEncoding)) ?? ""
        return string
    }
}

extension PebbleManager: PBPebbleCentralDelegate {
    
    func pebbleCentral(central: PBPebbleCentral, watchDidConnect watch: PBWatch, isNew: Bool) {
        if let _ = self.watch {
            return
        }
        
        delegate?.handleOutputString("Pebble connected: \(watch.name)")
        self.watch = watch
        
        watch.appMessagesAddReceiveUpdateHandler { [weak self] _, info -> Bool in
            guard let weakSelf = self else { return false }
            
            weakSelf.delegate?.handleOutputString("Received message:\n\(info)")
            
            return true
        }
        
        watch.appMessagesPushUpdate([:]) { [weak self] _, _, error in
            guard let weakSelf = self else { return }

            if let error = error {
                weakSelf.delegate?.handleOutputString("Initial message sending error: \(error.localizedDescription)")
            } else {
                weakSelf.delegate?.handleOutputString("Initial message successfully sent")
            }
        }
    }
    
    func pebbleCentral(central: PBPebbleCentral, watchDidDisconnect watch: PBWatch) {
        delegate?.handleOutputString("Pebble disconnected: \(watch.name)")

        if watch == self.watch {
            self.watch = nil
        }
    }
}

extension PebbleManager: PBDataLoggingServiceDelegate {
    
    func dataLoggingService(service: PBDataLoggingService, hasUInt32s data: UnsafePointer<UInt32>, numberOfItems: UInt16, forDataLoggingSession session: PBDataLoggingSessionMetadata) -> Bool {
        for index in 0...Int(numberOfItems) where numberOfItems > 0 {
            if session.tag == 100 {
                let session = fetchSession(sessionId: Int(session.timestamp))
                session.dateStarted = NSDate(timeIntervalSince1970: NSTimeInterval(data[index]) * 1000)

                delegate?.handleOutputString("Session start: \(data[index])")
            } else {
//                addStringToFile(string: "\(session.timestamp) \(Int(data[index]) * 1000)")
                
                let marker = CDMarker.create()
                marker.date = NSDate(timeIntervalSince1970: NSTimeInterval(data[index]) * 1000)
                
                let session = fetchSession(sessionId: Int(session.timestamp))
                session.addMarkersObject(marker)
                
                delegate?.handleOutputString("Marker: \(data[index])")
            }
            
            let _ = try? CoreDataManager.save()
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
            
//            addStringToFile(string: "\(session.timestamp) \(accelData.x) \(accelData.y) \(accelData.z) \(Int(accelData.timestamp))")
            
            delegate?.handleOutputString("AccelData: \(accelData.x) \(accelData.y) \(accelData.z) \(Int(accelData.timestamp + Double(index % 10 * 100)))")
            
            let accelerometerData = CDAccelerometerData.create()
            accelerometerData.x = accelData.x
            accelerometerData.y = accelData.y
            accelerometerData.z = accelData.z
            accelerometerData.date = NSDate(timeIntervalSince1970: accelData.timestamp + Double(index % 10 * 100))
            
            let session = fetchSession(sessionId: Int(session.timestamp))
            session.addAccelerometerDataObject(accelerometerData)
        }
        
        let _ = try? CoreDataManager.save()
    
        return true
    }
    
    func dataLoggingService(service: PBDataLoggingService, sessionDidFinish session: PBDataLoggingSessionMetadata) {
        delegate?.handleOutputString("Finished data log: \(session)")
    }
}