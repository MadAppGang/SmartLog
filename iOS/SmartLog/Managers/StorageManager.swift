//
//  StorageManager.swift
//  SmartLog
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
    
    fileprivate let storageFileName: String
    
    fileprivate var observers: Set<StorageChangesObserverContainer> = []
    
    // FIXME: Add in-memory storage for testing
    init(for purpose: Purpose) {
        switch purpose {
        case .using:
            storageFileName = "Model"
        case .testing:
            storageFileName = "Testable"
        }
    }
    
    func deleteStorage() throws {
        let fileManager: FileManager = .default
        
        let appFolderURL = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let appFolderContentURLs = try fileManager.contentsOfDirectory(at: appFolderURL, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
        let storageFilesURLs = appFolderContentURLs.filter({ $0.absoluteString.contains(storageFileName) })
        
        for storageFileURL in storageFilesURLs {
            try fileManager.removeItem(at: storageFileURL)
        }
    }
    
    fileprivate func notifyObserversAbout(_ session: Session, _ changing: StorageChangeType) {
        observers.forEach { container in
            DispatchQueue.main.async {
                container.observer?.storageService(self, didChange: session, changeType: changing)
            }
        }
    }
}

extension StorageManager: StorageService {
    
    // MARK: - Configuration
    
    func configure(progressHandler: @escaping (_ progress: Float) -> Void, completion: @escaping (_ result: StorageServiceConfigurationCompletion) -> Void) {
        let progress = CoreStore.addStorage(SQLiteStore(fileName: storageFileName)) { result in
            switch result {
            case .success:
                completion(.successful)
            case .failure(let error as NSError):
                completion(.failed(error: error))
            }
        }
        
        progress?.setProgressHandler { progress in
            progressHandler(Float(progress.fractionCompleted))
        }
    }
    
    // MARK: - Changes observing
    
    func add(changesObserver: StorageChangesObserver) {
        let container = StorageChangesObserverContainer(id: ObjectIdentifier(changesObserver).hashValue, observer: changesObserver)
        observers.insert(container)
    }
    
    func remove(changesObserver: StorageChangesObserver) {
        if let container = observers.filter({ $0.id == ObjectIdentifier(changesObserver).hashValue }).first {
            observers.remove(container)
        }
    }

    // MARK: - Sessions
    
    func createOrUpdate(_ session: Session, completion: (() -> Void)?) {
        createOrUpdate(session, completionQueue: .main, completion: completion)
    }
    
    func createOrUpdate(_ session: Session, completionQueue: DispatchQueue, completion: (() -> Void)?) {
        CoreStore.beginAsynchronous { transaction in
            let cdSession: CDSession
            let changing: StorageChangeType
            if let existingCDSession = transaction.fetchOne(From(CDSession.self), Where("id", isEqualTo: session.id)) {
                cdSession = existingCDSession
                
                changing = .updating
            } else {
                cdSession = transaction.create(Into(CDSession.self))
                cdSession.id = session.id as NSNumber?
                
                changing = .inserting
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
            
            let session = SessionMapper.toSession(cdSession: cdSession)
            
            transaction.commit { _ in
                completionQueue.async {
                    completion?()
                }
                
                self.notifyObserversAbout(session, changing)
            }
        }
    }
    
    func fetchSessions(completion: @escaping (_ sessions: [Session]) -> Void) {
        fetchSessions(completionQueue: .main, completion: completion)
    }
    
    func fetchSessions(completionQueue: DispatchQueue, completion: @escaping (_ sessions: [Session]) -> Void) {
        CoreStore.beginAsynchronous { transaction in
            guard let cdSessions = transaction.fetchAll(From(CDSession.self), OrderBy(.descending("dateStarted"))) else {
                completionQueue.async {
                    completion([])
                }
                
                return
            }
            
            let sessions = cdSessions.map({ SessionMapper.toSession(cdSession: $0) })
            
            completionQueue.async {
                completion(sessions)
            }
        }
    }
    
    func fetchSession(sessionID: Int, completion: @escaping (_ session: Session?) -> Void) {
        fetchSession(sessionID: sessionID, completionQueue: .main, completion: completion)
    }
    
    func fetchSession(sessionID: Int, completionQueue: DispatchQueue, completion: @escaping (_ session: Session?) -> Void) {
        CoreStore.beginAsynchronous { transaction in
            guard let cdSession = transaction.fetchOne(From(CDSession.self), Where("id", isEqualTo: sessionID)) else {
                completionQueue.async {
                    completion(nil)
                }
                
                return
            }
            
            let session = SessionMapper.toSession(cdSession: cdSession)
            completionQueue.async {
                completion(session)
            }
        }
    }
    
    func deleteSession(sessionID: Int, completion: (() -> Void)?) {
        deleteSession(sessionID: sessionID, completionQueue: .main, completion: completion)
    }
    
    func deleteSession(sessionID: Int, completionQueue: DispatchQueue, completion: (() -> Void)?) {
        CoreStore.beginAsynchronous { transaction in
            var session: Session?
            if let existingCDSession = transaction.fetchOne(From(CDSession.self), Where("id", isEqualTo: sessionID)) {
                session = SessionMapper.toSession(cdSession: existingCDSession)
                transaction.delete(existingCDSession)
            }
            
            transaction.commit { _ in
                completionQueue.async {
                    completion?()
                }
                
                guard let session = session else { return }
                self.notifyObserversAbout(session, .deleting)
            }
        }
    }
    
    // MARK: - Accelerometer data
    
    func create(_ accelerometerData: [AccelerometerData], completion: (() -> Void)?) {
        create(accelerometerData, completionQueue: .main, completion: completion)
    }
    
    func create(_ accelerometerData: [AccelerometerData], completionQueue: DispatchQueue, completion: (() -> Void)?) {
        guard accelerometerData.count > 0 else {
            completionQueue.async {
                completion?()
            }
            
            return
        }
        
        CoreStore.beginAsynchronous { transaction in
            let cdSession: CDSession
            let changing: StorageChangeType
            if let existingCDSession = transaction.fetchOne(From(CDSession.self), Where("id", isEqualTo: accelerometerData.first!.sessionID)) {
                cdSession = existingCDSession
                
                changing = .updating
            } else {
                cdSession = transaction.create(Into(CDSession.self))
                cdSession.id = accelerometerData.first?.sessionID as NSNumber?
                
                changing = .inserting
            }

            _ = accelerometerData.map({ AccelerometerDataMapper.map(cdAccelerometerData: transaction.create(Into(CDAccelerometerData.self)), with: $0, and: cdSession) })
            let session = SessionMapper.toSession(cdSession: cdSession)

            transaction.commit { _ in
                completionQueue.async {
                    completion?()
                }
                
                self.notifyObserversAbout(session, changing)
            }
        }
    }
    
    func fetchAccelerometerData(sessionID: Int, completion: @escaping (_ accelerometerData: [AccelerometerData]) -> Void) {
        fetchAccelerometerData(sessionID: sessionID, completionQueue: .main, completion: completion)
    }
    
    func fetchAccelerometerData(sessionID: Int, completionQueue: DispatchQueue, completion: @escaping (_ accelerometerData: [AccelerometerData]) -> Void) {
        CoreStore.beginAsynchronous { transaction in
            guard let cdAccelerometerData = transaction.fetchAll(From(CDAccelerometerData.self), Where("session.id", isEqualTo: sessionID), OrderBy(.ascending("dateTaken"))) else {
                completionQueue.async {
                    completion([])
                }
                
                return
            }
            
            let accelerometerData = cdAccelerometerData.map({ AccelerometerDataMapper.toAccelerometerData(cdAccelerometerData: $0) })
            completionQueue.async {
                completion(accelerometerData)
            }
        }
    }
    
    // MARK: - Markers
    
    func create(_ markers: [Marker], completion: (() -> Void)?) {
        create(markers, completionQueue: .main, completion: completion)
    }
    
    func create(_ markers: [Marker], completionQueue: DispatchQueue, completion: (() -> Void)?) {
        guard markers.count > 0 else {
            completionQueue.async {
                completion?()
            }
            
            return
        }

        CoreStore.beginAsynchronous { transaction in
            let cdSession: CDSession
            let changing: StorageChangeType
            if let existingCDSession = transaction.fetchOne(From(CDSession.self), Where("id", isEqualTo: markers.first!.sessionID)) {
                cdSession = existingCDSession
                
                changing = .updating
            } else {
                cdSession = transaction.create(Into(CDSession.self))
                cdSession.id = markers.first?.sessionID as NSNumber?
                
                changing = .inserting
            }
            
            _ = markers.map({ MarkerMapper.map(cdMarker: transaction.create(Into(CDMarker.self)), with: $0, and: cdSession) })
            let session = SessionMapper.toSession(cdSession: cdSession)
            
            transaction.commit { _ in
                completionQueue.async {
                    completion?()
                }
                
                self.notifyObserversAbout(session, changing)
            }
        }
    }
    
    func fetchMarkers(sessionID: Int, completion: @escaping (_ markers: [Marker]) -> Void) {
        fetchMarkers(sessionID: sessionID, completionQueue: .main, completion: completion)
    }
    
    func fetchMarkers(sessionID: Int, completionQueue: DispatchQueue, completion: @escaping (_ markers: [Marker]) -> Void) {
        CoreStore.beginAsynchronous { transaction in
            guard let cdMarkers = transaction.fetchAll(From(CDMarker.self), Where("session.id", isEqualTo: sessionID), OrderBy(.ascending("dateAdded"))) else {
                completionQueue.async {
                    completion([])
                }
                
                return
            }
            
            let markers = cdMarkers.map({ MarkerMapper.toMarker(cdMarker: $0) })
            completionQueue.async {
                completion(markers)
            }
        }
    }

    // MARK: - Pebble data
    
    func create(_ pebbleData: PebbleData, completion: (() -> Void)?) {
        create(pebbleData, completionQueue: .main, completion: completion)
    }
    
    func create(_ pebbleData: PebbleData, completionQueue: DispatchQueue, completion: (() -> Void)?) {
        CoreStore.beginAsynchronous { transaction in
            let cdPebbleData = transaction.create(Into(CDPebbleData.self))
            cdPebbleData.id = pebbleData.id as NSNumber
            cdPebbleData.sessionID = pebbleData.sessionID as NSNumber
            cdPebbleData.dataType = pebbleData.dataType.rawValue as NSNumber
            cdPebbleData.binaryData = pebbleData.binaryData
            
            transaction.commit { _ in
                completionQueue.async {
                    completion?()
                }
            }
        }
    }
    
    func fetchPebbleDataIDs(completion: @escaping (_ pebbleDataIDs: Set<Int>) -> Void) {
        fetchPebbleDataIDs(completionQueue: .main, completion: completion)
    }
    
    func fetchPebbleDataIDs(completionQueue: DispatchQueue, completion: @escaping (_ pebbleDataIDs: Set<Int>) -> Void) {
        CoreStore.beginAsynchronous { transaction in
            guard let cdPebbleData = transaction.fetchAll(From(CDPebbleData.self)) else {
                completionQueue.async {
                    completion([])
                }
                
                return
            }
            
            let pebbleDataIDs = Set(cdPebbleData.map({ $0.id?.intValue ?? 0 }))
            completionQueue.async {
                completion(pebbleDataIDs)
            }
        }
    }
    
    func fetchPebbleData(pebbleDataID: Int, completion: @escaping (_ pebbleData: PebbleData?) -> Void) {
        fetchPebbleData(pebbleDataID: pebbleDataID, completionQueue: .main, completion: completion)
    }
    
    func fetchPebbleData(pebbleDataID: Int, completionQueue: DispatchQueue, completion: @escaping (_ pebbleData: PebbleData?) -> Void) {
        CoreStore.beginAsynchronous { transaction in
            guard let cdPebbleData = transaction.fetchOne(From(CDPebbleData.self), Where("id", isEqualTo: pebbleDataID)) else {
                completionQueue.async {
                    completion(nil)
                }
                
                return
            }
            
            let id = cdPebbleData.id?.intValue ?? 0
            let sessionID = cdPebbleData.sessionID?.intValue ?? 0
            let dataType = PebbleData.DataType(rawValue: cdPebbleData.dataType?.intValue ?? 0)!
            let binaryData = cdPebbleData.binaryData ?? Data(bytes: [], count: 0)
            
            let pebbleData = PebbleData(id: id, sessionID: sessionID, dataType: dataType, binaryData: binaryData)
            completionQueue.async {
                completion(pebbleData)
            }
        }
    }
    
    func deletePebbleData(pebbleDataID: Int, completion: (() -> Void)?) {
        deletePebbleData(pebbleDataID: pebbleDataID, completionQueue: .main, completion: completion)
    }
    
    func deletePebbleData(pebbleDataID: Int, completionQueue: DispatchQueue, completion: (() -> Void)?) {
        CoreStore.beginAsynchronous { transaction in
            if let existingCDPebbleData = transaction.fetchOne(From(CDPebbleData.self), Where("id", isEqualTo: pebbleDataID)) {
                transaction.delete(existingCDPebbleData)
            }
            
            transaction.commit { _ in
                completionQueue.async {
                    completion?()
                }
            }
        }
    }
}
