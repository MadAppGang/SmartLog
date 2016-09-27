//
//  StorageService.swift
//  SmartHeartTraining
//
//  Created by Dmytro Lisitsyn on 6/17/16.
//  Copyright © 2016 MadAppGang. All rights reserved.
//

import Foundation

// MARK: - StorageService

protocol StorageService {
    
    // MARK: Changes observing
    
    func add(changesObserver: StorageChangesObserver)
    func remove(changesObserver: StorageChangesObserver)
    
    // MARK: Sessions
    
    func createOrUpdate(_ session: Session, completion: (() -> ())?)
    func fetchSessions() -> [Session]
    func fetchSession(sessionID: Int) -> Session?
    func deleteSession(sessionID: Int, completion: (() -> ())?)
    
    // MARK: Accelerometer data
    
    func create(_ accelerometerData: [AccelerometerData], completion: (() -> ())?)
    func fetchAccelerometerData(sessionID: Int) -> [AccelerometerData]
    
    // MARK: Markers
    
    func create(_ markers: [Marker], completion: (() -> ())?)
    func fetchMarkers(sessionID: Int) -> [Marker]
    
    // MARK: Pebble data
    
    func create(_ pebbleData: PebbleData, completion: (() -> ())?)
    func fetchPebbleDataIDs() -> Set<Int>
    func fetchPebbleData(pebbleDataID: Int) -> PebbleData?
    func deletePebbleData(pebbleDataID: Int, completion: (() -> ())?)
}

// MARK: - Storage changes observing

enum StorageChangeType {
    case inserting
    case updating
    case deleting
}

protocol StorageChangesObserver: class {
    
    func storageService(_ storageService: StorageService, didChange session: Session, changeType: StorageChangeType)
    
}

extension StorageChangesObserver {
    
    func storageService(_ storageService: StorageService, didChange session: Session, changeType: StorageChangeType) { }
    
}
