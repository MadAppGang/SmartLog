//
//  StorageManager.swift
//  SmartHeartTraining
//
//  Created by Dmytro Lisitsyn on 6/17/16.
//  Copyright © 2016 MadAppGang. All rights reserved.
//

import Foundation
import CoreStore

final class StorageManager {
    
    enum Purpose {
        case using
        case testing
    }
    
    enum ConfigurationCompletion {
        case successful
        case failed(error: NSError)
    }
    
    private let storageFileName: String
    
    init(purpose: Purpose) {
        switch purpose {
        case .using:
            storageFileName = "Model"
        case .testing:
            storageFileName = "Testable"
        }
    }
    
    func configure(progressHandler progressHandler: (progress: Float) -> (), completion: (result: ConfigurationCompletion) -> ()) {
        do {
            let progress = try CoreStore.addSQLiteStore(fileName: storageFileName) { result in
                switch result {
                case .Success:
                    completion(result: .successful)
                case .Failure(let error):
                    completion(result: .failed(error: error))
                }
            }
            
            progress?.setProgressHandler { progress in
                progressHandler(progress: Float(progress.fractionCompleted))
            }
        } catch(let error as NSError) {
            completion(result: .failed(error: error))
        }
    }
    
    func deleteStorage() throws {
        let fileManager = NSFileManager.defaultManager()
        
        let appFolderURL = fileManager.URLsForDirectory(.ApplicationSupportDirectory, inDomains: .UserDomainMask).first!
        let appFolderContentURLs = try fileManager.contentsOfDirectoryAtURL(appFolderURL, includingPropertiesForKeys: nil, options: .SkipsHiddenFiles)
        let storageFilesURLs = appFolderContentURLs.filter({ $0.absoluteString.containsString(storageFileName) })
        
        for storageFileURL in storageFilesURLs {
            try fileManager.removeItemAtURL(storageFileURL)
        }
    }
}

extension StorageManager: StorageService {
    
    // MARK: - Sessions
    
    func createOrUpdate(session: Session, completion: (() -> ())?) {
        CoreStore.beginAsynchronous { transaction in
            let cdSession: CDSession
            if let existingCDSession = transaction.fetchOne(From(CDSession), Where("id", isEqualTo: session.id)) {
                cdSession = existingCDSession
            } else {
                cdSession = transaction.create(Into(CDSession))
                cdSession.id = session.id
            }
            
            cdSession.dateStarted = session.dateStarted
            
            if let duration = session.duration {
                cdSession.duration = duration
            }
            
            if let samplesCount = session.samplesCount {
                cdSession.samplesCount = samplesCount
            }
            
            if let markersCount = session.markersCount {
                cdSession.markersCount = markersCount
            }
            
            if let notes = session.notes {
                cdSession.notes = notes
            }
            
            transaction.commit { _ in
                completion?()
            }
        }
    }
    
    func fetchSessions() -> [Session] {
        guard let cdSessions = CoreStore.fetchAll(From(CDSession), OrderBy(.Descending("dateStarted"))) else { return [] }
        
        let sessions = cdSessions.map({ SessionMapper.toSession(cdSession: $0) })
        return sessions
    }
    
    func fetchSession(sessionID sessionID: Int) -> Session? {
        guard let cdSession = CoreStore.fetchOne(From(CDSession), Where("id", isEqualTo: sessionID)) else { return nil }
        
        let session = SessionMapper.toSession(cdSession: cdSession)
        return session
    }
    
    func deleteSession(sessionID sessionID: Int, completion: (() -> ())?) {
        CoreStore.beginAsynchronous { transaction in
            if let existingCDSession = transaction.fetchOne(From(CDSession), Where("id", isEqualTo: sessionID)) {
                transaction.delete(existingCDSession)
            }
            
            transaction.commit { _ in
                completion?()
            }
        }
    }
    
    // MARK: - Accelerometer data
    
    func create(accelerometerData: [AccelerometerData], completion: (() -> ())?) {
        guard accelerometerData.count > 0 else {
            completion?()
            return
        }
        
        CoreStore.beginAsynchronous { transaction in
            let cdSession: CDSession
            if let existingCDSession = transaction.fetchOne(From(CDSession), Where("id", isEqualTo: accelerometerData.first!.sessionID)) {
                cdSession = existingCDSession
            } else {
                cdSession = transaction.create(Into(CDSession))
                cdSession.id = accelerometerData.first!.sessionID
            }

            let _ = accelerometerData.map({ AccelerometerDataMapper.map(cdAccelerometerData: transaction.create(Into(CDAccelerometerData)), with: $0, and: cdSession) })
            
            transaction.commit { _ in
                completion?()
            }
        }
    }
    
    func fetchAccelerometerData(sessionID sessionID: Int) -> [AccelerometerData] {
        guard let cdAccelerometerData = CoreStore.fetchAll(From(CDAccelerometerData), Where("session.id", isEqualTo: sessionID), OrderBy(.Ascending("dateTaken"))) else { return [] }
        
        let accelerometerData = cdAccelerometerData.map({ AccelerometerDataMapper.toAccelerometerData(cdAccelerometerData: $0) })        
        return accelerometerData
    }
    
    // MARK: - Markers
    
    func create(markers: [Marker], completion: (() -> ())?) {
        guard markers.count > 0 else {
            completion?()
            return
        }

        CoreStore.beginAsynchronous { transaction in
            let cdSession: CDSession
            if let existingCDSession = transaction.fetchOne(From(CDSession), Where("id", isEqualTo: markers.first!.sessionID)) {
                cdSession = existingCDSession
            } else {
                cdSession = transaction.create(Into(CDSession))
                cdSession.id = markers.first!.sessionID
            }
            
            let _ = markers.map({ MarkerMapper.map(cdMarker: transaction.create(Into(CDMarker)), with: $0, and: cdSession) })
            
            transaction.commit { _ in
                completion?()
            }
        }
    }
    
    func fetchMarkers(sessionID sessionID: Int) -> [Marker] {
        guard let cdMarkers = CoreStore.fetchAll(From(CDMarker), Where("session.id", isEqualTo: sessionID), OrderBy(.Ascending("dateAdded"))) else { return [] }
        
        let markers = cdMarkers.map({ MarkerMapper.toMarker(cdMarker: $0) })
        return markers
    }

    // MARK: - Pebble data
    
    func createOrUpdate(pebbleBinaryData pebbleBinaryData: NSData, for key: PebbleDataKey, completion: (() -> ())?) {
        CoreStore.beginAsynchronous { transaction in
            let cdPebbleData: CDPebbleData
            if let existingCDPebbleData = transaction.fetchOne(From(CDPebbleData), Where("sessionID", isEqualTo: key.sessionID) && Where("type", isEqualTo: key.dataType.rawValue)) {
                cdPebbleData = existingCDPebbleData
            } else {
                cdPebbleData = transaction.create(Into(CDPebbleData))
                cdPebbleData.sessionID = key.sessionID
                cdPebbleData.type = key.dataType.rawValue
            }
            
            let mutableBinaryData: NSMutableData
            if let existingBinaryData = cdPebbleData.binaryData {
                mutableBinaryData = NSMutableData(data: existingBinaryData)
            } else {
                mutableBinaryData = NSMutableData()
            }

            mutableBinaryData.appendData(pebbleBinaryData)
            cdPebbleData.binaryData = mutableBinaryData
            
            transaction.commit { _ in
                completion?()
            }
        }
    }
    
    func fetchPebbleDataKeys() -> Set<PebbleDataKey> {
        guard let cdPebbleData = CoreStore.fetchAll(From(CDPebbleData)) else { return [] }
        
        var pebbleDataKeys: Set<PebbleDataKey> = []
        for cdPebbleDataSample in cdPebbleData {
            let sessionID = cdPebbleDataSample.sessionID?.integerValue ?? 0
            let dataType = PebbleDataKey.DataType(rawValue: cdPebbleDataSample.type?.integerValue ?? 0)
            
            let pebbleDataKey = PebbleDataKey(sessionID: sessionID, dataType: dataType ?? .accelerometerData)
            pebbleDataKeys.insert(pebbleDataKey)
        }
        
        return pebbleDataKeys
    }
    
    func fetchPebbleBinaryData(for key: PebbleDataKey) -> NSData? {
        guard let cdPebbleData = CoreStore.fetchOne(From(CDPebbleData), Where("sessionID", isEqualTo: key.sessionID) && Where("type", isEqualTo: key.dataType.rawValue)) else { return nil }

        return cdPebbleData.binaryData
    }
    
    func deletePebbleBinaryData(for key: PebbleDataKey, completion: (() -> ())?) {
        CoreStore.beginAsynchronous { transaction in
            if let existingCDPebbleData = transaction.fetchOne(From(CDPebbleData), Where("sessionID", isEqualTo: key.sessionID) && Where("type", isEqualTo: key.dataType.rawValue)) {
                transaction.delete(existingCDPebbleData)
            }
            
            transaction.commit { _ in
                completion?()
            }
        }
    }
}
