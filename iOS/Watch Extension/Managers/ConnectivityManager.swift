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
    
    fileprivate enum DataType: Int {
        case accelerometerData = 101
        case markers = 102
        case activityType = 103
        case sessionFinished = 104
    }
    
    fileprivate var session: WCSession?
    
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

extension ConnectivityManager: ConnectivityService {
    
    var connectionActivated: Bool {
        return session?.activationState == .activated
    }
    
    func sendAcceleromterData(sessionID: Int, x: Double, y: Double, z: Double, dateTaken: Date) {
        guard let session = session else { return }
        
        let userInfo: [String: Any] = ["sessionID": sessionID, "type": DataType.accelerometerData.rawValue, "x": x, "y": y, "z": z, "dateTaken": dateTaken]
        session.transferUserInfo(userInfo)
    }
    
    func sendMarker(sessionID: Int, dateAdded: Date) {
        guard let session = session else { return }

        let userInfo: [String: Any] = ["sessionID": sessionID, "type": DataType.markers.rawValue, "dateAdded": dateAdded]
        session.transferUserInfo(userInfo)
    }
    
    func sendActivityType(sessionID: Int, activityType: Int) {
        guard let session = session else { return }

        let userInfo: [String: Any] = ["sessionID": sessionID, "type": DataType.activityType.rawValue, "activityType": activityType]
        session.transferUserInfo(userInfo)
    }
    
    func sendSessionFinished(sessionID: Int, accelerometerDataSamplesCount: Int, markersCount: Int) {
        guard let session = session else { return }
        
        let userInfo: [String: Any] = ["sessionID": sessionID, "type": DataType.sessionFinished.rawValue, "accelerometerDataSamplesCount": accelerometerDataSamplesCount, "markersCount": markersCount]
        session.transferUserInfo(userInfo)
    }
}

extension ConnectivityManager: WCSessionDelegate {
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        
    }
    
    func session(_ session: WCSession, didFinish userInfoTransfer: WCSessionUserInfoTransfer, error: Error?) {
        
    }
}
