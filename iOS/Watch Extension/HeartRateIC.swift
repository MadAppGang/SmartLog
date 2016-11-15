//
//  HeartRateIC.swift
//  SmartLog
//
//  Created by Dmytro Lisitsyn on 11/15/16.
//  Copyright © 2016 MadAppGang. All rights reserved.
//

import WatchKit
import WatchConnectivity
import Foundation


final class HeartRateIC: WKInterfaceController {
    
    @IBOutlet fileprivate var heartRateLabel: WKInterfaceLabel!

    fileprivate var session: WCSession?
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        let session = WCSession.default()
        session.delegate = self
        session.activate()
        
        self.session = session
    }
}

extension HeartRateIC: WCSessionDelegate {
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        if let heartRate = message["hr"] as? Int {
            heartRateLabel.setText("\(heartRate)")
        }
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        if let heartRate = message["hr"] as? Int {
            heartRateLabel.setText("\(heartRate)")
        }
    }
    
    func session(_ session: WCSession, didFinish userInfoTransfer: WCSessionUserInfoTransfer, error: Error?) {
        
    }
}
