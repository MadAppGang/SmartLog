//
//  StorageManager.swift
//  SmartHeartTraining
//
//  Created by Dmytro Lisitsyn on 6/17/16.
//  Copyright © 2016 MadAppGang. All rights reserved.
//

import Foundation
import CoreStore

private func == (lhs: StorageChangesObserverContainer, rhs: StorageChangesObserverContainer) -> Bool {
    return lhs.hashValue == rhs.hashValue
}

private struct StorageChangesObserverContainer: Equatable, Hashable {
    
    let id: Int
    
    weak var observer: StorageChangesObserver?
    
    var hashValue: Int {
        return id.hashValue
    }
}

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
    
    private var observers: Set<StorageChangesObserverContainer> = []
    
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
    
    private func notifyObserversAbout(session: Session, _ changing: StorageChangeType) {
        observers.forEach { container in
            dispatch_async(dispatch_get_main_queue()) {
                container.observer?.storageService(self, didChange: session, changeType: changing)
            }
        }
    }
}

extension StorageManager: StorageService {
    
    // MARK: - Changes observing
    
    func add(changesObserver changesObserver: StorageChangesObserver) {
        let container = StorageChangesObserverContainer(id: ObjectIdentifier(changesObserver).hashValue, observer: changesObserver)
        observers.insert(container)
    }
    
    func remove(changesObserver changesObserver: StorageChangesObserver) {
        if let container = observers.filter({ $0.id == ObjectIdentifier(changesObserver).hashValue }).first {
            observers.remove(container)
        }
    }

    // MARK: - Sessions
    
    func createOrUpdate(session: Session, completion: (() -> ())?) {
        CoreStore.beginAsynchronous { transaction in
            let cdSession: CDSession
            let changing: StorageChangeType
            if let existingCDSession = transaction.fetchOne(From(CDSession), Where("id", isEqualTo: session.id)) {
                cdSession = existingCDSession
                
                changing = .updating
            } else {
                cdSession = transaction.create(Into(CDSession))
                cdSession.id = session.id
                
                changing = .inserting
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
            
            let session = SessionMapper.toSession(cdSession: cdSession)
            
            transaction.commit { _ in
                completion?()
                
                self.notifyObserversAbout(session, changing)
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
            var session: Session?
            if let existingCDSession = transaction.fetchOne(From(CDSession), Where("id", isEqualTo: sessionID)) {
                session = SessionMapper.toSession(cdSession: existingCDSession)
                transaction.delete(existingCDSession)
            }
            
            transaction.commit { _ in
                completion?()
                
                guard let session = session else { return }
                self.notifyObserversAbout(session, .deleting)
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
            let changing: StorageChangeType
            if let existingCDSession = transaction.fetchOne(From(CDSession), Where("id", isEqualTo: accelerometerData.first!.sessionID)) {
                cdSession = existingCDSession
                
                changing = .updating
            } else {
                cdSession = transaction.create(Into(CDSession))
                cdSession.id = accelerometerData.first!.sessionID
                
                changing = .inserting
            }

            let _ = accelerometerData.map({ AccelerometerDataMapper.map(cdAccelerometerData: transaction.create(Into(CDAccelerometerData)), with: $0, and: cdSession) })
            let session = SessionMapper.toSession(cdSession: cdSession)

            transaction.commit { _ in
                completion?()
                
                self.notifyObserversAbout(session, changing)
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
            let changing: StorageChangeType
            if let existingCDSession = transaction.fetchOne(From(CDSession), Where("id", isEqualTo: markers.first!.sessionID)) {
                cdSession = existingCDSession
                
                changing = .updating
            } else {
                cdSession = transaction.create(Into(CDSession))
                cdSession.id = markers.first!.sessionID
                
                changing = .inserting
            }
            
            let _ = markers.map({ MarkerMapper.map(cdMarker: transaction.create(Into(CDMarker)), with: $0, and: cdSession) })
            let session = SessionMapper.toSession(cdSession: cdSession)
            
            transaction.commit { _ in
                completion?()
                
                self.notifyObserversAbout(session, changing)
            }
        }
    }
    
    func fetchMarkers(sessionID sessionID: Int) -> [Marker] {
        guard let cdMarkers = CoreStore.fetchAll(From(CDMarker), Where("session.id", isEqualTo: sessionID), OrderBy(.Ascending("dateAdded"))) else { return [] }
        
        let markers = cdMarkers.map({ MarkerMapper.toMarker(cdMarker: $0) })
        return markers
    }

    // MARK: - Pebble data
    
    func create(pebbleData: PebbleData, completion: (() -> ())?) {
        CoreStore.beginAsynchronous { transaction in
            let cdPebbleData = transaction.create(Into(CDPebbleData))
            cdPebbleData.id = pebbleData.id
            cdPebbleData.sessionID = pebbleData.sessionID
            cdPebbleData.dataType = pebbleData.dataType.rawValue
            cdPebbleData.binaryData = pebbleData.binaryData
            
            transaction.commit { _ in
                completion?()
            }
        }
    }
    
    func fetchPebbleDataIDs() -> Set<Int> {
        guard let cdPebbleData = CoreStore.fetchAll(From(CDPebbleData)) else { return [] }
        
        let pebbleDataIDs = Set(cdPebbleData.map({ $0.id?.integerValue ?? 0 }))
        return pebbleDataIDs
    }
    
    func fetchPebbleData(pebbleDataID pebbleDataID: Int) -> PebbleData? {
        guard let cdPebbleData = CoreStore.fetchOne(From(CDPebbleData), Where("id", isEqualTo: pebbleDataID)) else { return nil }

        let id = cdPebbleData.id?.integerValue ?? 0
        let sessionID = cdPebbleData.sessionID?.integerValue ?? 0
        let dataType = PebbleData.DataType(rawValue: cdPebbleData.dataType?.integerValue ?? 0)
        let binaryData = cdPebbleData.binaryData ?? NSData(bytes: [], length: 0)
        
        let pebbleData = PebbleData(id: id, sessionID: sessionID, dataType: dataType ?? .accelerometerData, binaryData: binaryData)
        return pebbleData
    }
    
    func deletePebbleData(pebbleDataID pebbleDataID: Int, completion: (() -> ())?) {
        CoreStore.beginAsynchronous { transaction in
            if let existingCDPebbleData = transaction.fetchOne(From(CDPebbleData), Where("id", isEqualTo: pebbleDataID)) {
                transaction.delete(existingCDPebbleData)
            }
            
            transaction.commit { _ in
                completion?()
            }
        }
    }
}
