//
//  SessionsChangesObserver.swift
//  SmartHeartTraining
//
//  Created by Dmytro Lisitsyn on 6/28/16.
//  Copyright © 2016 MadAppGang. All rights reserved.
//

import Foundation
import CoreStore

final class SessionsChangesMonitor {
    
    private let sessionsMonitor: ListMonitor<CDSession>
    
    private var observers: [Int: SessionsChangesObserver] = [:]

    init() {
        sessionsMonitor = CoreStore.monitorList(From(CDSession), OrderBy(.Descending("dateStarted")))
        sessionsMonitor.addObserver(self)
    }
    
    deinit {
        sessionsMonitor.removeObserver(self)
    }
}

extension SessionsChangesMonitor: SessionsChangesService {
    
    func addObserver(observer: SessionsChangesObserver) {
        observers[ObjectIdentifier(observer).hashValue] = observer
    }
    
    func removeObserver(observer: SessionsChangesObserver) {
        observers.removeValueForKey(ObjectIdentifier(observer).hashValue)
    }
}

extension SessionsChangesMonitor: ListObjectObserver {
    
    func listMonitorWillChange(monitor: ListMonitor<CDSession>) {
        
    }
    
    func listMonitorDidChange(monitor: ListMonitor<CDSession>) {
        
    }
    
    func listMonitor(monitor: ListMonitor<CDSession>, didInsertObject object: CDSession, toIndexPath indexPath: NSIndexPath) {
        for observer in observers.values {
            let sessions = monitor.objectsInAllSections().map({ SessionMapper.toSession(cdSession: $0) })
            observer.sessionsChangesMonitor(self, sessionsListDidChange: sessions)
        }
    }
    
    func listMonitor(monitor: ListMonitor<CDSession>, didUpdateObject object: CDSession, atIndexPath indexPath: NSIndexPath) {
        guard (object.markersCount?.integerValue > 0 && object.markersCount == object.markers?.count)
            || (object.samplesCount?.integerValue > 0 && object.samplesCount == object.accelerometerData?.count) else { return }
        
        for observer in observers.values {
            let sessions = monitor.objectsInAllSections().map({ SessionMapper.toSession(cdSession: $0) })
            observer.sessionsChangesMonitor(self, sessionsListDidChange: sessions)
        }
    }
    
    func listMonitor(monitor: ListMonitor<CDSession>, didDeleteObject object: CDSession, fromIndexPath indexPath: NSIndexPath) {
        for observer in observers.values {
            let sessions = monitor.objectsInAllSections().map({ SessionMapper.toSession(cdSession: $0) })
            observer.sessionsChangesMonitor(self, sessionsListDidChange: sessions)
        }
    }
}