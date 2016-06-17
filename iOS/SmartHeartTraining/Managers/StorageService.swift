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
    func create(markerData: MarkerData)
    
    func createOrUpdate(sessionData: SessionData)

    func fetchSessionData() -> [SessionData]
    
    func delete(sessionDataID: Int)
    
}