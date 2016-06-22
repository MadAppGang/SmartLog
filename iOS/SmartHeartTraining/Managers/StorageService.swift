//
//  StorageService.swift
//  SmartHeartTraining
//
//  Created by Dmytro Lisitsyn on 6/17/16.
//  Copyright © 2016 MadAppGang. All rights reserved.
//

import Foundation

protocol StorageService {
    
    func create(accelerometerData: AccelerometerData)
    func create(marker: Marker)
    
    func createOrUpdate(session: Session)

    func fetchSessions() -> [Session]
    func fetchAccelerometerData(sessionID sessionID: Int) -> [AccelerometerData]
    func fetchMarkers(sessionID sessionID: Int) -> [Marker]

    func deleteSession(sessionID sessionID: Int)
    
}