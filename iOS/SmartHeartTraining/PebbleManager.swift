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
    func handleOutputStirng(string: String)
}

final class PebbleManager: NSObject {
    
    weak var delegate: PebbleManagerDelegate?

    var watch: PBWatch?
    
    override init() {
        super.init()
        
        let appUUID = NSUUID(UUIDString: "b03b0098-9fa6-4653-848e-ad280b4881bf")
        PBPebbleCentral.defaultCentral().appUUID = appUUID
        PBPebbleCentral.defaultCentral().run()
        
        PBPebbleCentral.defaultCentral().delegate = self
    }
    
    deinit {
        watch?.releaseSharedSession()
    }
}

extension PebbleManager: PBPebbleCentralDelegate {
    
    func pebbleCentral(central: PBPebbleCentral, watchDidConnect watch: PBWatch, isNew: Bool) {
        delegate?.handleOutputStirng("Pebble connected: \(watch.name)")
        print("Pebble connected: \(watch.name)")
        
        self.watch = watch
        
        watch.appMessagesAddReceiveUpdateHandler { _, info -> Bool in
            self.delegate?.handleOutputStirng("\(info)")
            print(info)
            
            return true
        }
    }
    
    func pebbleCentral(central: PBPebbleCentral, watchDidDisconnect watch: PBWatch) {
        delegate?.handleOutputStirng("Pebble disconnected: \(watch.name)")
        print("Pebble disconnected: \(watch.name)")

        if watch == self.watch {
            self.watch = nil
        }
    }
}