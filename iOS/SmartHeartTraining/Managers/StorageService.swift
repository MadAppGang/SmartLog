//
//  StorageService.swift
//  SmartHeartTraining
//
//  Created by Dmytro Lisitsyn on 6/17/16.
//  Copyright © 2016 MadAppGang. All rights reserved.
//

import Foundation

enum StorageServiceNotification: String {
    case sessionsWereUpdated = "StorageServiceNotificationSessionsWereUpdated"
}

enum StorageServiceInitializationCompletion {
    case successful
    case failed(error: NSError)
}

protocol StorageService {
    
    func initializeStorage(progressHandler progressHandler: (progress: Float) -> (), completion: (result: StorageServiceInitializationCompletion) -> ())
    
    func create(accelerometerData: AccelerometerData)
    func create(marker: Marker)
    
    func createOrUpdate(session: Session)

    func fetchSessions() -> [Session]
    func fetchAccelerometerData(sessionID sessionID: Int) -> [AccelerometerData]
    func fetchMarkers(sessionID sessionID: Int) -> [Marker]

    func deleteSession(sessionID sessionID: Int)

}
