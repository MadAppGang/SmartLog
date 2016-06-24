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
    
    private var sessionsMonitor: ListMonitor<CDSession>
        
    init() {
        do {
            try CoreStore.addSQLiteStore { result in
                
                switch result {
                case .Success(let persistentStore):
                    debugPrint("Successfully added sqlite store: \(persistentStore)")
                case .Failure(let error):
                    debugPrint("Failed adding sqlite store with error: \(error)")
                }
                
            }
        } catch(let errorType) {
            debugPrint("Failed adding sqlite store with error: \(errorType)")
        }
        
        sessionsMonitor = CoreStore.monitorList(From(CDSession), OrderBy(.Descending("dateStarted")))
        sessionsMonitor.addObserver(self)
    }
    
    deinit {
        sessionsMonitor.removeObserver(self)
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
    
    func create(marker: Marker) {
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
            
            transaction.commit()
        }
    }
    
    func createOrUpdate(session: Session) {
        CoreStore.beginAsynchronous { transaction in
            let cdSession: CDSession
            if let existingCDSession = transaction.fetchOne(From(CDSession), Where("id", isEqualTo: session.id)) {
                cdSession = existingCDSession
            } else {
                cdSession = transaction.create(Into(CDSession))
                cdSession.id = session.id
            }
            
            cdSession.dateStarted = session.dateStarted
            
            transaction.commit()
        }
    }
    
    func fetchSessions() -> [Session] {
        guard let cdSessions = CoreStore.fetchAll(From(CDSession), OrderBy(.Descending("dateStarted"))) else { return [] }
        
        var sessions: [Session] = []
        for cdSession in cdSessions {
            let id = cdSession.id?.integerValue ?? 0
            let dateStarted = cdSession.dateStarted ?? NSDate(timeIntervalSince1970: 0)
            var session = Session(id: id, dateStarted: dateStarted)
            
            let firstSample = CoreStore.fetchOne(From(CDAccelerometerData), Where("session", isEqualTo: cdSession), OrderBy(.Ascending("dateTaken")))
            let lastSample = CoreStore.fetchOne(From(CDAccelerometerData), Where("session", isEqualTo: cdSession), OrderBy(.Descending("dateTaken")))
            if let firstSampleDateTaken = firstSample?.dateTaken, lastSampleDateTaken = lastSample?.dateTaken {
                session.duration = lastSampleDateTaken.timeIntervalSinceDate(firstSampleDateTaken)
            }
            
            session.samplesCount = cdSession.accelerometerData?.count
            session.markersCount = cdSession.markers?.count
            
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
    
    func fetchMarkers(sessionID sessionID: Int) -> [Marker] {
        guard let cdSession = CoreStore.fetchOne(From(CDSession), Where("id", isEqualTo: sessionID)) else { return [] }
        
        var markers: [Marker] = []
        let cdMarkers = cdSession.markers?.allObjects as? [CDMarker] ?? []
        for cdMarker in cdMarkers {
            let sessionID = cdSession.id?.integerValue ?? 0
            let dateAdded = cdMarker.dateAdded ?? NSDate()
            
            let marker = Marker(sessionID: sessionID, dateAdded: dateAdded)
            markers.append(marker)
        }
        
        return markers
    }
    
    func deleteSession(sessionID sessionID: Int) {
        CoreStore.beginAsynchronous { transaction in
            if let existingCDSession = transaction.fetchOne(From(CDSession), Where("id", isEqualTo: sessionID)) {
                transaction.delete(existingCDSession)
            }
            
            transaction.commit()
        }
    }
}

extension StorageManager: ListObjectObserver {
    
    func listMonitorWillChange(monitor: ListMonitor<CDSession>) {
        
    }
    
    func listMonitorDidChange(monitor: ListMonitor<CDSession>) {
        
    }
    
    func listMonitor(monitor: ListMonitor<CDSession>, didInsertObject object: CDSession, toIndexPath indexPath: NSIndexPath) {
        NSNotificationCenter.defaultCenter().postNotificationName(StorageServiceNotification.sessionInserted.rawValue, object: self)
    }
    
    func listMonitor(monitor: ListMonitor<CDSession>, didUpdateObject object: CDSession, atIndexPath indexPath: NSIndexPath) {
        
    }

    func listMonitor(monitor: ListMonitor<CDSession>, didDeleteObject object: CDSession, fromIndexPath indexPath: NSIndexPath) {
        
    }
}
