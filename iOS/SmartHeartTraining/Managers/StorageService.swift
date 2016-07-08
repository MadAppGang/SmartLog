//
//  StorageService.swift
//  SmartHeartTraining
//
//  Created by Dmytro Lisitsyn on 6/17/16.
//  Copyright © 2016 MadAppGang. All rights reserved.
//

import Foundation

enum StorageServiceInitializationCompletion {
    case successful
    case failed(error: NSError)
}

protocol StorageService {
        
    func create(accelerometerData: AccelerometerData, completion: (() -> ())?)
    func create(marker: Marker, completion: (() -> ())?)
    
    func createOrUpdate(session: Session, completion: (() -> ())?)
    func createOrUpdate(pebbleData: PebbleData, completion: (() -> ())?)
    
    func fetchSessions() -> [Session]
    func fetchSession(sessionID sessionID: Int) -> Session?
    
    func fetchAccelerometerData(sessionID sessionID: Int) -> [AccelerometerData]
    func fetchMarkers(sessionID sessionID: Int) -> [Marker]

    func deleteSession(sessionID sessionID: Int, completion: (() -> ())?)

}
