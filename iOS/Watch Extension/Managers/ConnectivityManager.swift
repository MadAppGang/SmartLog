//
//  ConnectivityManager.swift
//  SmartLog
//
//  Created by Dmytro Lisitsyn on 10/11/16.
//  Copyright © 2016 MadAppGang. All rights reserved.
//

import Foundation
import WatchConnectivity

final class ConnectivityManager: NSObject {
    
    fileprivate var session: WCSession?
    
}

extension ConnectivityManager: ConnectivityService {
    
    var connectionActivated: Bool {
        return session?.activationState == .activated
    }
    
    func activateConnection() throws {
        guard WCSession.isSupported() else {
            throw ConnectivityServiceError.connectivityIsNotSupported
        }
        
        let session = WCSession.default()
        session.delegate = self
        session.activate()
        
        self.session = session
    }   
}

extension ConnectivityManager: WCSessionDelegate {
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        
    }
}
