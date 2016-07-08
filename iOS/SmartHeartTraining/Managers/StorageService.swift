//
//  StorageService.swift
//  SmartHeartTraining
//
//  Created by Dmytro Lisitsyn on 6/17/16.
//  Copyright © 2016 MadAppGang. All rights reserved.
//

import Foundation

protocol StorageService {
        
    // MARK: - Sessions
    
    func createOrUpdate(session: Session, completion: (() -> ())?)
    func fetchSessions() -> [Session]
    func fetchSession(sessionID sessionID: Int) -> Session?
    func deleteSession(sessionID sessionID: Int, completion: (() -> ())?)
    
    // MARK: - Accelerometer data
    
    func create(accelerometerData: [AccelerometerData], completion: (() -> ())?)
    func fetchAccelerometerData(sessionID sessionID: Int) -> [AccelerometerData]
    
    // MARK: - Markers
    
    func create(marker: Marker, completion: (() -> ())?)
    func fetchMarkers(sessionID sessionID: Int) -> [Marker]
    
    // MARK: - Pebble data
    
    func createOrUpdate(pebbleBinaryData pebbleBinaryData: NSData, for key: PebbleDataKey, completion: (() -> ())?)
    func fetchPebbleDataKeys() -> [PebbleDataKey]
    func fetchPebbleBinaryData(for key: PebbleDataKey) -> NSData?
}
