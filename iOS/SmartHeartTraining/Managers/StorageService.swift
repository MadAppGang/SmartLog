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
    
    func createOrUpdate(_ session: Session, completion: (() -> Void)?)
    func fetchSessions() -> [Session]
    func fetchSession(sessionID: Int) -> Session?
    func deleteSession(sessionID: Int, completion: (() -> Void)?)
    
    // MARK: Accelerometer data
    
    func create(_ accelerometerData: [AccelerometerData], completion: (() -> Void)?)
    func fetchAccelerometerData(sessionID: Int) -> [AccelerometerData]
    
    // MARK: Markers
    
    func create(_ markers: [Marker], completion: (() -> Void)?)
    func fetchMarkers(sessionID: Int) -> [Marker]
    
    // MARK: Pebble data
    
    func create(_ pebbleData: PebbleData, completion: (() -> Void)?)
    func fetchPebbleDataIDs() -> Set<Int>
    func fetchPebbleData(pebbleDataID: Int) -> PebbleData?
    func deletePebbleData(pebbleDataID: Int, completion: (() -> Void)?)
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
