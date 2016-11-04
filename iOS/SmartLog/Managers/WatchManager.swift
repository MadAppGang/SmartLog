//
//  WatchManager.swift
//  SmartLog
//
//  Created by Dmytro Lisitsyn on 10/25/16.
//  Copyright © 2016 MadAppGang. All rights reserved.
//

import Foundation
import WatchConnectivity

enum WatchManagerError: Error {
    case connectivityIsNotSupported
}

final class WatchManager: NSObject {
    
    fileprivate let watchDataSaver: WatchDataSaver
    fileprivate let loggingService: LoggingService?
    
    fileprivate var session: WCSession?
    
    init(watchDataSaver: WatchDataSaver, loggingService: LoggingService? = nil) {
        self.watchDataSaver = watchDataSaver
        self.loggingService = loggingService
        
        super.init()
        
        guard WCSession.isSupported() else {
            return
        }
        
        let session = WCSession.default()
        session.delegate = self
        session.activate()
        
        self.session = session
    }    
}

extension WatchManager: WearableService {
    
    var deviceAvailable: Bool {
        return session?.activationState == .activated
    }
}

extension WatchManager: WCSessionDelegate {
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        
    }
    
    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String : Any] = [:]) {
        debugPrint(userInfo)
        watchDataSaver.handle(userInfo)
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        
    }
}
