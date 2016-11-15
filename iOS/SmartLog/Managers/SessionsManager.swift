//
//  SessionsManager.swift
//  SmartLog
//
//  Created by Dmytro Lisitsyn on 11/10/16.
//  Copyright © 2016 MadAppGang. All rights reserved.
//

import Foundation

final class SessionsManager {
        
    fileprivate var storageService: StorageService
    fileprivate var hrMonitor: HRMonitor
    
    fileprivate var session: Session?
    fileprivate var recording: Bool
    fileprivate var startRecordingDate = Date()

    fileprivate var hrData: [HRData] = []
    fileprivate var markers: [Marker] = []
    
    fileprivate var wearables: [WearableService] = []
    
    init(storageService: StorageService, hrMonitor: HRMonitor, wearables: [WearableService]? = nil) {
        self.storageService = storageService
        self.hrMonitor = hrMonitor
        
        if let wearables = wearables {
            self.wearables = wearables
        }
        
        recording = false
        
        hrMonitor.add(observer: self)
    }
    
    deinit {
        hrMonitor.remove(observer: self)
    }
}

extension SessionsManager: SessionsService {
 
    func startRecording(activityType: ActivityType) {
        guard !recording else { return }
        
        if session == nil {
            let dateStarted = Date()
            let sessionID = Int(dateStarted.timeIntervalSince1970)
            var session = Session(id: sessionID, dateStarted: dateStarted)
            
            session.activityType = activityType
            
            self.session = session
        }
        
        resumeRecording()
    }
    
    func resumeRecording() {
        guard let _ = session, !recording else { return }

        startRecordingDate = Date()
        recording = true
    }
    
    func pauseRecording() {
        guard let _ = session else { return }

        let duration = session!.durationValue + (Date().timeIntervalSince1970 - startRecordingDate.timeIntervalSince1970)
        session?.duration = duration
        
        recording = false
    }
    
    func finishRecording() {
        guard let _ = session else { return }
        
        if recording {
            pauseRecording()
        }
        
        storageService.createOrUpdate(session!, completion: nil)
        storageService.create(hrData, completion: nil)
        storageService.create(markers, completion: nil)
        
        session = nil
        hrData.removeAll()
        markers.removeAll()
    }
    
    func addMarker() {
        guard let _ = session else { return }

        session?.markersCount = session!.markersCountValue + 1
        
        let marker = Marker(sessionID: session!.id, dateAdded: Date())
        markers.append(marker)
    }
}

extension SessionsManager: HRObserver {
    
    func monitor(monitor: HRMonitor, didReceiveHeartRate heartRate: Int, dateTaken: Date) {
        for wearable in wearables {
            wearable.displayHeartRate(heartRate)
        }
        
        guard let _ = session, recording else { return }
        
        session?.samplesCount.hrData = session!.samplesCountValue.hrData + 1
        
        let hrDataSample = HRData(sessionID: session!.id, heartRate: heartRate, dateTaken: dateTaken)
        hrData.append(hrDataSample)
        
        if hrData.count > 200 {
            storageService.create(hrData, completion: nil)
            hrData.removeAll()
        }
    }
}
