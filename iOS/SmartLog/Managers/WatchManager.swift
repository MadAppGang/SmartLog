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

    fileprivate enum DataType: Int {
        case accelerometerData = 101
        case markers = 102
        case activityType = 103
    }

    fileprivate var session: WCSession?
    
    func activateConnection() throws {
        guard WCSession.isSupported() else {
            throw WatchManagerError.connectivityIsNotSupported
        }
        
        let session = WCSession.default()
        session.delegate = self
        session.activate()
        
        self.session = session
    }
}

extension WatchManager: WearableService {
    
    var deviceConnected: Bool {
        return session?.activationState == .activated
    }
}

extension WatchManager: WCSessionDelegate {
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        
    }
    
    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String : Any] = [:]) {
        guard let typeValue = userInfo["type"] as? Int, let type = DataType(rawValue: typeValue) else { return }
        
        let sessionID = userInfo["sessionID"] as! Int
        
        switch type {
        case .accelerometerData:
            break
        case .markers:
            break
        case .activityType:
            break
        }
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        
    }
}
