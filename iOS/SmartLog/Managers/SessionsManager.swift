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
    
    init(storageService: StorageService, hrMonitor: HRMonitor) {
        self.storageService = storageService
        self.hrMonitor = hrMonitor
        
        recording = false
        
        hrMonitor.add(observer: self)
    }
    
    deinit {
        hrMonitor.remove(observer: self)
    }
}

extension SessionsManager: SessionsService {
 
    func startRecording() {
        guard !recording else { return }
        
        startRecordingDate = Date()
        
        if session == nil {
            let sessionID = Int(startRecordingDate.timeIntervalSince1970)
            let session = Session(id: sessionID, dateStarted: startRecordingDate)
            
            self.session = session
        }
        
        recording = true
    }
    
    func stopRecording(finish: Bool) {
        guard let _ = session else { return }
        
        let duration = session!.durationValue + (Date().timeIntervalSince1970 - startRecordingDate.timeIntervalSince1970)
        session?.duration = duration
        
        recording = false
        
        guard finish else { return }
        
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
