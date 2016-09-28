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
    
    func configure(progressHandler: @escaping (_ progress: Float) -> (), completion: @escaping (_ result: ConfigurationCompletion) -> ()) {
//        do {
//            let progress = try CoreStore.addSQLiteStore(fileName: storageFileName) { result in
//                switch result {
//                case .Success:
//                    completion(result: .successful)
//                case .Failure(let error):
//                    completion(result: .failed(error: error))
//                }
//            }
//            
//            progress?.setProgressHandler { progress in
//                progressHandler(progress: Float(progress.fractionCompleted))
//            }
//        } catch(let error as NSError) {
//            completion(.failed(error: error))
//        }
    }
    
    func deleteStorage() throws {
        let fileManager = FileManager.default
        
        let appFolderURL = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let appFolderContentURLs = try fileManager.contentsOfDirectory(at: appFolderURL, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
        let storageFilesURLs = appFolderContentURLs.filter({ $0.absoluteString.contains(storageFileName) })
        
        for storageFileURL in storageFilesURLs {
            try fileManager.removeItem(at: storageFileURL)
        }
    }
    
    private func notifyObserversAbout(session: Session, _ changing: StorageChangeType) {
        observers.forEach { container in
            DispatchQueue.main.async {
                container.observer?.storageService(self, didChange: session, changeType: changing)
            }
        }
    }
}

extension StorageManager: StorageService {
    
    // MARK: - Changes observing
    
    func add(changesObserver: StorageChangesObserver) {
//        let container = StorageChangesObserverContainer(id: ObjectIdentifier(changesObserver).hashValue, observer: changesObserver)
//        observers.insert(container)
    }
    
    func remove(changesObserver: StorageChangesObserver) {
//        if let container = observers.filter({ $0.id == ObjectIdentifier(changesObserver).hashValue }).first {
//            observers.remove(container)
//        }
    }

    // MARK: - Sessions
    
    func createOrUpdate(_ session: Session, completion: (() -> ())?) {
        CoreStore.beginAsynchronous { transaction in
            let cdSession: CDSession
//            let changing: StorageChangeType
            if let existingCDSession = transaction.fetchOne(From(CDSession.self), Where("id", isEqualTo: session.id)) {
                cdSession = existingCDSession
                
//                changing = .updating
            } else {
                cdSession = transaction.create(Into(CDSession.self))
                cdSession.id = session.id as NSNumber?
                
//                changing = .inserting
            }
            
            cdSession.dateStarted = session.dateStarted
            cdSession.activityType = session.activityType.rawValue as NSNumber?
            cdSession.sent = session.sent as NSNumber?

            if let duration = session.duration {
                cdSession.duration = duration as NSNumber?
            }
            
            if let samplesCount = session.samplesCount {
                cdSession.samplesCount = samplesCount as NSNumber?
            }
            
            if let markersCount = session.markersCount {
                cdSession.markersCount = markersCount as NSNumber?
            }
            
            if let notes = session.notes {
                cdSession.notes = notes
            }
            
//            let session = SessionMapper.toSession(cdSession: cdSession)
            
            transaction.commit { _ in
                completion?()
                
//                self.notifyObserversAbout(session, changing)
            }
        }
    }
    
    func fetchSessions() -> [Session] {
        guard let cdSessions = CoreStore.fetchAll(From(CDSession.self), OrderBy(.descending("dateStarted"))) else { return [] }
        
        let sessions = cdSessions.map({ SessionMapper.toSession(cdSession: $0) })
        return sessions
    }
    
    func fetchSession(sessionID: Int) -> Session? {
        guard let cdSession = CoreStore.fetchOne(From(CDSession.self), Where("id", isEqualTo: sessionID)) else { return nil }
        
        let session = SessionMapper.toSession(cdSession: cdSession)
        return session
    }
    
    func deleteSession(sessionID: Int, completion: (() -> ())?) {
        CoreStore.beginAsynchronous { transaction in
//            var session: Session?
            if let existingCDSession = transaction.fetchOne(From(CDSession.self), Where("id", isEqualTo: sessionID)) {
//                session = SessionMapper.toSession(cdSession: existingCDSession)
                transaction.delete(existingCDSession)
            }
            
            transaction.commit { _ in
                completion?()
                
//                guard let session = session else { return }
//                self.notifyObserversAbout(session, .deleting)
            }
        }
    }
    
    // MARK: - Accelerometer data
    
    func create(_ accelerometerData: [AccelerometerData], completion: (() -> ())?) {
        guard accelerometerData.count > 0 else {
            completion?()
            return
        }
        
        CoreStore.beginAsynchronous { transaction in
            let cdSession: CDSession
//            let changing: StorageChangeType
            if let existingCDSession = transaction.fetchOne(From(CDSession.self), Where("id", isEqualTo: accelerometerData.first!.sessionID)) {
                cdSession = existingCDSession
                
//                changing = .updating
            } else {
                cdSession = transaction.create(Into(CDSession.self))
                cdSession.id = accelerometerData.first!.sessionID as NSNumber?
                
//                changing = .inserting
            }

            let _ = accelerometerData.map({ AccelerometerDataMapper.map(cdAccelerometerData: transaction.create(Into(CDAccelerometerData.self)), with: $0, and: cdSession) })
//            let session = SessionMapper.toSession(cdSession: cdSession)

            transaction.commit { _ in
                completion?()
                
//                self.notifyObserversAbout(session, changing)
            }
        }
    }
    
    func fetchAccelerometerData(sessionID: Int) -> [AccelerometerData] {
        guard let cdAccelerometerData = CoreStore.fetchAll(From(CDAccelerometerData.self), Where("session.id", isEqualTo: sessionID), OrderBy(.ascending("dateTaken"))) else { return [] }
        
        let accelerometerData = cdAccelerometerData.map({ AccelerometerDataMapper.toAccelerometerData(cdAccelerometerData: $0) })
        return accelerometerData
    }
    
    // MARK: - Markers
    
    func create(_ markers: [Marker], completion: (() -> ())?) {
        guard markers.count > 0 else {
            completion?()
            return
        }

        CoreStore.beginAsynchronous { transaction in
            let cdSession: CDSession
//            let changing: StorageChangeType
            if let existingCDSession = transaction.fetchOne(From(CDSession.self), Where("id", isEqualTo: markers.first!.sessionID)) {
                cdSession = existingCDSession
                
//                changing = .updating
            } else {
                cdSession = transaction.create(Into(CDSession.self))
                cdSession.id = markers.first!.sessionID as NSNumber?
                
//                changing = .inserting
            }
            
            let _ = markers.map({ MarkerMapper.map(cdMarker: transaction.create(Into(CDMarker.self)), with: $0, and: cdSession) })
//            let session = SessionMapper.toSession(cdSession: cdSession)
            
            transaction.commit { _ in
                completion?()
                
//                self.notifyObserversAbout(session, changing)
            }
        }
    }
    
    func fetchMarkers(sessionID: Int) -> [Marker] {
        guard let cdMarkers = CoreStore.fetchAll(From(CDMarker.self), Where("session.id", isEqualTo: sessionID), OrderBy(.ascending("dateAdded"))) else { return [] }
        
        let markers = cdMarkers.map({ MarkerMapper.toMarker(cdMarker: $0) })
        return markers
    }

    // MARK: - Pebble data
    
    func create(_ pebbleData: PebbleData, completion: (() -> ())?) {
        CoreStore.beginAsynchronous { transaction in
            let cdPebbleData = transaction.create(Into(CDPebbleData.self))
            cdPebbleData.id = pebbleData.id as NSNumber
            cdPebbleData.sessionID = pebbleData.sessionID as NSNumber
            cdPebbleData.dataType = pebbleData.dataType.rawValue as NSNumber
            cdPebbleData.binaryData = pebbleData.binaryData
            
            transaction.commit { _ in
                completion?()
            }
        }
    }
    
    func fetchPebbleDataIDs() -> Set<Int> {
        guard let cdPebbleData = CoreStore.fetchAll(From(CDPebbleData.self)) else { return [] }
        
        let pebbleDataIDs = Set(cdPebbleData.map({ $0.id?.intValue ?? 0 }))
        return pebbleDataIDs
    }
    
    func fetchPebbleData(pebbleDataID: Int) -> PebbleData? {
        guard let cdPebbleData = CoreStore.fetchOne(From(CDPebbleData.self), Where("id", isEqualTo: pebbleDataID)) else { return nil }

        let id = cdPebbleData.id?.intValue ?? 0
        let sessionID = cdPebbleData.sessionID?.intValue ?? 0
        let dataType = PebbleData.DataType(rawValue: cdPebbleData.dataType?.intValue ?? 0)
        let binaryData = cdPebbleData.binaryData ?? Data(bytes: [], count: 0)

        let pebbleData = PebbleData(id: id, sessionID: sessionID, dataType: dataType ?? .accelerometerData, binaryData: binaryData)
        return pebbleData
    }
    
    func deletePebbleData(pebbleDataID: Int, completion: (() -> ())?) {
        CoreStore.beginAsynchronous { transaction in
            if let existingCDPebbleData = transaction.fetchOne(From(CDPebbleData.self), Where("id", isEqualTo: pebbleDataID)) {
                transaction.delete(existingCDPebbleData)
            }
            
            transaction.commit { _ in
                completion?()
            }
        }
    }
}
