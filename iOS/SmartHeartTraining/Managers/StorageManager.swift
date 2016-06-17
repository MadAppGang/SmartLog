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
}