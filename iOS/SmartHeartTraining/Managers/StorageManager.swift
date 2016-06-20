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
    
    init() {
        do {
            try CoreStore.addSQLiteStoreAndWait()
        } catch(let errorType) {
            debugPrint(errorType)
        }
    }
}

extension StorageManager: StorageService {
    
    func create(accelerometerData: AccelerometerData) {
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
            
            transaction.commit()
        }
    }
    
    func create(markerData: MarkerData) {
        CoreStore.beginAsynchronous { transaction in
            let cdMarker = transaction.create(Into(CDMarker))
            
            cdMarker.dateAdded = markerData.dateAdded
            
            let cdSession: CDSession
            if let existingCDSession = transaction.fetchOne(From(CDSession), Where("id", isEqualTo: markerData.sessionID)) {
                cdSession = existingCDSession
            } else {
                cdSession = transaction.create(Into(CDSession))
                cdSession.id = markerData.sessionID
            }
            cdSession.addMarkersObject(cdMarker)
            
            transaction.commit()
        }
    }
    
    func createOrUpdate(sessionData: SessionData) {
        CoreStore.beginAsynchronous { transaction in
            let cdSession: CDSession
            if let existingCDSession = transaction.fetchOne(From(CDSession), Where("id", isEqualTo: sessionData.id)) {
                cdSession = existingCDSession
            } else {
                cdSession = transaction.create(Into(CDSession))
                cdSession.id = sessionData.id
            }
            
            cdSession.dateStarted = sessionData.dateStarted
            
            transaction.commit()
        }
    }
    
    func fetchSessionData() -> [SessionData] {
        guard let cdSessions = CoreStore.fetchAll(From(CDSession)) else { return [] }
        
        var sessions: [SessionData] = []
        for cdSession in cdSessions {
            let id = cdSession.id?.integerValue ?? 0
            let dateStarted = cdSession.dateStarted ?? NSDate(timeIntervalSince1970: 0)
            let session = SessionData(id: id, dateStarted: dateStarted)
            
            sessions.append(session)
        }
        
        return sessions
    }
    
    func fetchAccelerometerData(sessionID sessionID: Int) -> [AccelerometerData] {
        guard let cdSession = CoreStore.fetchOne(From(CDSession), Where("id", isEqualTo: sessionID)) else { return [] }

        var accelerometerDataItems: [AccelerometerData] = []
        let cdAccelerometerDataItems = cdSession.accelerometerData?.allObjects as? [CDAccelerometerData] ?? []
        for cdAccelerometerDataItem in cdAccelerometerDataItems {
            let sessionID = cdSession.id?.integerValue ?? 0
            let x = cdAccelerometerDataItem.x?.integerValue ?? 0
            let y = cdAccelerometerDataItem.y?.integerValue ?? 0
            let z = cdAccelerometerDataItem.z?.integerValue ?? 0
            let dateTaken = cdAccelerometerDataItem.dateTaken ?? NSDate()

            let accelerometerDataItem = AccelerometerData(sessionID: sessionID, x: x, y: y, z: z, dateTaken: dateTaken)
            accelerometerDataItems.append(accelerometerDataItem)
        }
        
        return accelerometerDataItems
    }
    
    func fetchMarkerData(sessionID sessionID: Int) -> [MarkerData] {
        guard let cdSession = CoreStore.fetchOne(From(CDSession), Where("id", isEqualTo: sessionID)) else { return [] }
        
        var markerDataItems: [MarkerData] = []
        let cdMarkers = cdSession.markers?.allObjects as? [CDMarker] ?? []
        for cdMarker in cdMarkers {
            let sessionID = cdSession.id?.integerValue ?? 0
            let dateAdded = cdMarker.dateAdded ?? NSDate()
            
            let marker = MarkerData(sessionID: sessionID, dateAdded: dateAdded)
            markerDataItems.append(marker)
        }
        
        return markerDataItems
    }
    
    func delete(sessionDataID: Int) {
        CoreStore.beginAsynchronous { transaction in
            if let existingCDSession = transaction.fetchOne(From(CDSession), Where("id", isEqualTo: sessionDataID)) {
                transaction.delete(existingCDSession)
            }
            
            transaction.commit()
        }
    }
}