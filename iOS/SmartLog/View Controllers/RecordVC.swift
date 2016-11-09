//
//  RecordVC.swift
//  SmartLog
//
//  Created by Dmytro Lisitsyn on 11/7/16.
//  Copyright © 2016 MadAppGang. All rights reserved.
//

import UIKit

final class RecordVC: UIViewController {

    @IBOutlet fileprivate weak var heartRateLabel: UILabel!
    @IBOutlet fileprivate weak var startStopButton: UIButton!
    
    var hrMonitor: HRMonitor!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        hrMonitor.add(observer: self)
    }
    
    deinit {
        hrMonitor.remove(observer: self)
    }

    @IBAction func startStopButtonPressed(_ sender: UIButton) {
        
    }

}

extension RecordVC: HRObserver {
    
    func monitor(monitor: HRMonitor, didReceive hrData: HRData) {
        heartRateLabel.text = "\(hrData.heartRate)"
    }
    
    func monitor(monitor: HRMonitor, batteryLevelDidChange batteryLevel: Int) {
        
    }
}
