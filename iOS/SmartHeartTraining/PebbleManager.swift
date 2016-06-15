//
//  PebbleManager.swift
//  SmartHeartTraining
//
//  Created by Dmytro Lisitsyn on 5/30/16.
//  Copyright © 2016 MadAppGang. All rights reserved.
//

import Foundation
import PebbleKit

protocol PebbleManagerDelegate: class {
    func handleOutputString(string: String)
}

final class PebbleManager: NSObject {
    
    weak var delegate: PebbleManagerDelegate?

    var watch: PBWatch?
    
    override init() {
        super.init()
        
        let appUUID = NSUUID(UUIDString: "b03b0098-9fa6-4653-848e-ad280b4881bf")
        PBPebbleCentral.defaultCentral().appUUID = appUUID
        PBPebbleCentral.defaultCentral().delegate = self
        PBPebbleCentral.defaultCentral().run()
    }
    
    deinit {
        watch?.releaseSharedSession()
    }
}

extension PebbleManager: PBPebbleCentralDelegate {
    
    func pebbleCentral(central: PBPebbleCentral, watchDidConnect watch: PBWatch, isNew: Bool) {
        if let _ = self.watch {
            return
        }
        
        delegate?.handleOutputString("Pebble connected: \(watch.name)")
        self.watch = watch
        
        watch.appMessagesAddReceiveUpdateHandler { [weak self] _, info -> Bool in
            guard let weakSelf = self else { return false }
            
            weakSelf.delegate?.handleOutputString("Received message:\n\(info)")
            
            return true
        }
        
        watch.appMessagesPushUpdate([:]) { [weak self] _, _, error in
            guard let weakSelf = self else { return }

            if let error = error {
                weakSelf.delegate?.handleOutputString("Initial message sending error: \(error.localizedDescription)")
            } else {
                weakSelf.delegate?.handleOutputString("Initial message successfully sent")
            }
        }
    }
    
    func pebbleCentral(central: PBPebbleCentral, watchDidDisconnect watch: PBWatch) {
        delegate?.handleOutputString("Pebble disconnected: \(watch.name)")

        if watch == self.watch {
            self.watch = nil
        }
    }
}