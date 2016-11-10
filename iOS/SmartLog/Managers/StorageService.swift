//
//  StorageService.swift
//  SmartLog
//
//  Created by Dmytro Lisitsyn on 6/17/16.
//  Copyright © 2016 MadAppGang. All rights reserved.
//

import Foundation

enum StorageServiceConfigurationCompletion {
    case successful
    case failed(error: NSError)
}

// MARK: - StorageService

protocol StorageService {
    
    // MARK: Configuration
    
    func configure(progressHandler: @escaping (_ progress: Float) -> Void, completion: @escaping (_ result: StorageServiceConfigurationCompletion) -> Void)
    
    // MARK: Changes observing
    
    func add(changesObserver: StorageChangesObserver)
    func remove(changesObserver: StorageChangesObserver)
    
    // MARK: Sessions
    
    func createOrUpdate(_ session: Session, completion: (() -> Void)?)
    func createOrUpdate(_ session: Session, completionQueue: DispatchQueue, completion: (() -> Void)?)
    func fetchSessions(completion: @escaping (_ sessions: [Session]) -> Void)
    func fetchSessions(completionQueue: DispatchQueue, completion: @escaping (_ sessions: [Session]) -> Void)
    func fetchSession(sessionID: Int, completion: @escaping (_ session: Session?) -> Void)
    func fetchSession(sessionID: Int, completionQueue: DispatchQueue, completion: @escaping (_ session: Session?) -> Void)
    func deleteSession(sessionID: Int, completion: (() -> Void)?)
    func deleteSession(sessionID: Int, completionQueue: DispatchQueue, completion: (() -> Void)?)
    
    // MARK: Accelerometer data
    
    func create(_ accelerometerData: [AccelerometerData], completion: (() -> Void)?)
    func create(_ accelerometerData: [AccelerometerData], completionQueue: DispatchQueue, completion: (() -> Void)?)
    func fetchAccelerometerData(sessionID: Int, completion: @escaping (_ accelerometerData: [AccelerometerData]) -> Void)
    func fetchAccelerometerData(sessionID: Int, completionQueue: DispatchQueue, completion: @escaping (_ accelerometerData: [AccelerometerData]) -> Void)
    
    // MARK: Markers
    
    func create(_ markers: [Marker], completion: (() -> Void)?)
    func create(_ markers: [Marker], completionQueue: DispatchQueue, completion: (() -> Void)?)
    func fetchMarkers(sessionID: Int, completion: @escaping (_ markers: [Marker]) -> Void)
    func fetchMarkers(sessionID: Int, completionQueue: DispatchQueue, completion: @escaping (_ markers: [Marker]) -> Void)
    
    // MARK: Pebble data
    
    func create(_ pebbleData: PebbleData, completion: (() -> Void)?)
    func create(_ pebbleData: PebbleData, completionQueue: DispatchQueue, completion: (() -> Void)?)
    func fetchPebbleDataIDs(completion: @escaping (_ pebbleDataIDs: Set<Int>) -> Void)
    func fetchPebbleDataIDs(completionQueue: DispatchQueue, completion: @escaping (_ pebbleDataIDs: Set<Int>) -> Void)
    func fetchPebbleData(pebbleDataID: Int, completion: @escaping (_ pebbleData: PebbleData?) -> Void)
    func fetchPebbleData(pebbleDataID: Int, completionQueue: DispatchQueue, completion: @escaping (_ pebbleData: PebbleData?) -> Void)
    func deletePebbleData(pebbleDataID: Int, completion: (() -> Void)?)
    func deletePebbleData(pebbleDataID: Int, completionQueue: DispatchQueue, completion: (() -> Void)?)
    
    // MARK: Heart rate data
    
    func create(_ hrData: [HRData], completion: (() -> Void)?)
    func create(_ hrData: [HRData], completionQueue: DispatchQueue, completion: (() -> Void)?)
    func fetchHRData(sessionID: Int, completion: @escaping (_ hrData: [HRData]) -> Void)
    func fetchHRData(sessionID: Int, completionQueue: DispatchQueue, completion: @escaping (_ hrData: [HRData]) -> Void)
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
