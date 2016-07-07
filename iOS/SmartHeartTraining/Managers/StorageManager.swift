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
    
    enum StorageManagerPurpose {
        case using
        case testing
    }
    
    let storageFileName: String
    
    init(purpose: StorageManagerPurpose) {
        switch purpose {
        case .using:
            storageFileName = "Model"
        case .testing:
            storageFileName = "Testable"
        }
    }
    
}

extension StorageManager: StorageService {
    
    func initializeStorage(progressHandler progressHandler: (progress: Float) -> (), completion: (result: StorageServiceInitializationCompletion) -> ()) {
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

    func create(accelerometerData: AccelerometerData, completion: (() -> ())?) {
        CoreStore.beginAsynchronous { transaction in
            let cdAccelerometerData = transaction.create(Into(CDAccelerometerData))
            
            cdAccelerometerData.x = accelerometerData.x
            cdAccelerometerData.y = accelerometerData.y
            cdAccelerometerData.z = accelerometerData.z
            cdAccelerometerData.dateTaken = accelerometerData.dateTaken

            let cdSession: CDSession
            if let existingCDSession = transaction.fetchOne(From(CDSession), Where("id", isEqualTo: accelerometerData.sessionID)) {
                cdSession = existingCDSession
            } else {
                cdSession = transaction.create(Into(CDSession))
                cdSession.id = accelerometerData.sessionID
            }
            cdSession.addAccelerometerDataObject(cdAccelerometerData)
            
            transaction.commit { _ in
                completion?()
            }
        }
    }
    
    func create(marker: Marker, completion: (() -> ())?) {
        CoreStore.beginAsynchronous { transaction in
            let cdMarker = transaction.create(Into(CDMarker))
            
            cdMarker.dateAdded = marker.dateAdded
            
            let cdSession: CDSession
            if let existingCDSession = transaction.fetchOne(From(CDSession), Where("id", isEqualTo: marker.sessionID)) {
                cdSession = existingCDSession
            } else {
                cdSession = transaction.create(Into(CDSession))
                cdSession.id = marker.sessionID
            }
            cdSession.addMarkersObject(cdMarker)
            
            transaction.commit { _ in
                completion?()
            }
        }
    }
    
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
    
    func fetchAccelerometerData(sessionID sessionID: Int) -> [AccelerometerData] {
        guard let cdAccelerometerDataItems = CoreStore.fetchAll(From(CDAccelerometerData), Where("session.id", isEqualTo: sessionID), OrderBy(.Ascending("dateTaken"))) else { return [] }

        var accelerometerDataItems: [AccelerometerData] = []
        for cdAccelerometerDataItem in cdAccelerometerDataItems {
            let sessionID = cdAccelerometerDataItem.session?.id?.integerValue ?? 0
            let x = cdAccelerometerDataItem.x?.integerValue ?? 0
            let y = cdAccelerometerDataItem.y?.integerValue ?? 0
            let z = cdAccelerometerDataItem.z?.integerValue ?? 0
            let dateTaken = cdAccelerometerDataItem.dateTaken ?? NSDate()

            let accelerometerDataItem = AccelerometerData(sessionID: sessionID, x: x, y: y, z: z, dateTaken: dateTaken)
            accelerometerDataItems.append(accelerometerDataItem)
        }
        
        return accelerometerDataItems
    }
    
    func fetchMarkers(sessionID sessionID: Int) -> [Marker] {
        guard let cdMarkers = CoreStore.fetchAll(From(CDMarker), Where("session.id", isEqualTo: sessionID), OrderBy(.Ascending("dateAdded"))) else { return [] }
        
        var markers: [Marker] = []
        for cdMarker in cdMarkers {
            let sessionID = cdMarker.session?.id?.integerValue ?? 0
            let dateAdded = cdMarker.dateAdded ?? NSDate()
            
            let marker = Marker(sessionID: sessionID, dateAdded: dateAdded)
            markers.append(marker)
        }
        
        return markers
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
}
