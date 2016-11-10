//
//  HRMonitor.swift
//  SmartLog
//
//  Created by Dmytro Lisitsyn on 11/9/16.
//  Copyright © 2016 MadAppGang. All rights reserved.
//

import Foundation

protocol HRMonitor {
    
    func add(observer: HRObserver)
    func remove(observer: HRObserver)

}

protocol HRObserver: class {
    
    func monitor(monitor: HRMonitor, didReceiveHeartRate heartRate: Int, dateTaken: Date)
    func monitor(monitor: HRMonitor, batteryLevelDidChange batteryLevel: Int)
    
}

extension HRObserver {
    
    func monitor(monitor: HRMonitor, batteryLevelDidChange batteryLevel: Int) { }
    
}
