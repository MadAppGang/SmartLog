//
//  WatchDataSaver.swift
//  SmartLog
//
//  Created by Dmytro Lisitsyn on 10/26/16.
//  Copyright © 2016 MadAppGang. All rights reserved.
//

import Foundation

final class WatchDataSaver {
    
    fileprivate enum DataType: Int {
        case accelerometerData = 101
        case markers = 102
        case activityType = 103
        case sessionFinished = 104
    }
    
    private let storageService: StorageService
    
    private var accelerometerData: [AccelerometerData] = []
    private var markers: [Marker] = []
    
    init(storageService: StorageService) {
        self.storageService = storageService
    }
    
    func handle(_ info: [String: Any]) {
        let typeValue = info["type"] as! Int
        let type = DataType(rawValue: typeValue)!

        let sessionID = info["sessionID"] as! Int
        
        switch type {
        case .accelerometerData:
            let x = Int(info["x"] as! Double)
            let y = Int(info["y"] as! Double)
            let z = Int(info["z"] as! Double)
            let dateTaken = info["dateTaken"] as! Date
            let accelerometerDataSample = AccelerometerData(sessionID: sessionID, x: x, y: y, z: z, dateTaken: dateTaken)
            accelerometerData.append(accelerometerDataSample)
        case .markers:
            let dateAdded = info["dateAdded"] as! Date
            let marker = Marker(sessionID: sessionID, dateAdded: dateAdded)
            markers.append(marker)
        case .activityType:
            let activityTypeValue = info["activityType"] as! Int
            let activityType = ActivityType(rawValue: activityTypeValue)!
            
            getOrCreateSession(sessionID: sessionID, completionQueue: .main) { session in
                var session = session
                session.activityType = activityType
                
                self.storageService.createOrUpdate(session) {
                }
            }
        case .sessionFinished:
            let accelerometerDataSamplesCount = info["accelerometerDataSamplesCount"] as! Int
            let markersCount = info["markersCount"] as! Int
            let duration = TimeInterval(accelerometerDataSamplesCount / 10)
            
            getOrCreateSession(sessionID: sessionID, completionQueue: .main) { session in
                var session = session
                session.samplesCount = accelerometerDataSamplesCount
                session.markersCount = markersCount
                session.duration = duration

                self.storageService.createOrUpdate(session) {
                    self.storageService.create(self.markers, completion: {
                        self.markers.removeAll()
                        
                        self.storageService.create(self.accelerometerData, completion: {
                            self.accelerometerData.removeAll()
                        })
                    })
                }
            }
        }
    }
    
    private func getOrCreateSession(sessionID: Int, completionQueue: DispatchQueue, completion: @escaping (_ session: Session) -> Void) {
        storageService.fetchSession(sessionID: sessionID, completionQueue: completionQueue) { existingSession in
            if let existingSession = existingSession {
                completion(existingSession)
            } else {
                let session = Session(id: sessionID, dateStarted: Date(timeIntervalSince1970: TimeInterval(sessionID)))
                completion(session)
            }
        }
    }
}
