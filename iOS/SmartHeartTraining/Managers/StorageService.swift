//
//  StorageService.swift
//  SmartHeartTraining
//
//  Created by Dmytro Lisitsyn on 6/17/16.
//  Copyright © 2016 MadAppGang. All rights reserved.
//

import Foundation

protocol StorageService {
    
    // MARK: - Changes observing
    
    func add(changesObserver changesObserver: StorageChangesObserver)
    func remove(changesObserver changesObserver: StorageChangesObserver)
    
    // MARK: - Sessions
    
    func createOrUpdate(session: Session, completion: (() -> ())?)
    func fetchSessions() -> [Session]
    func fetchSession(sessionID sessionID: Int) -> Session?
    func deleteSession(sessionID sessionID: Int, completion: (() -> ())?)
    
    // MARK: - Accelerometer data
    
    func create(accelerometerData: [AccelerometerData], completion: (() -> ())?)
    func fetchAccelerometerData(sessionID sessionID: Int) -> [AccelerometerData]
    
    // MARK: - Markers
    
    func create(markers: [Marker], completion: (() -> ())?)
    func fetchMarkers(sessionID sessionID: Int) -> [Marker]
    
    // MARK: - Pebble data
    
    func create(pebbleData: PebbleData, completion: (() -> ())?)
    func fetchPebbleDataIDs() -> Set<Int>
    func fetchPebbleData(pebbleDataID pebbleDataID: Int) -> PebbleData?
    func deletePebbleData(pebbleDataID pebbleDataID: Int, completion: (() -> ())?)
}

enum StorageChangeType {
    case inserting
    case updating
    case deleting
}

protocol StorageChangesObserver: class {
    
    func storageService(storageService: StorageService, didChange session: Session, changeType: StorageChangeType)
    
}

extension StorageChangesObserver {
    
    func storageService(storageService: StorageService, didChange session: Session, changeType: StorageChangeType) { }
    
}