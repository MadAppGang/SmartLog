//
//  SessionsChangesService.swift
//  SmartHeartTraining
//
//  Created by Dmytro Lisitsyn on 6/28/16.
//  Copyright © 2016 MadAppGang. All rights reserved.
//

import Foundation


protocol SessionsChangesObserver: class {
    
    func sessionsChangesMonitor(monitor: SessionsChangesMonitor, sessionsListDidChange sessions: [Session])
    
}


protocol SessionsChangesService {
    
    func addObserver(observer: SessionsChangesObserver)
    func removeObserver(observer: SessionsChangesObserver)
    
}