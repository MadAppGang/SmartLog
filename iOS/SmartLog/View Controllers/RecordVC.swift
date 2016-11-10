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
    @IBOutlet fileprivate weak var startButton: UIButton!
    @IBOutlet fileprivate weak var stopButton: UIButton!

    var hrMonitor: HRMonitor!
    var sessionsService: SessionsService!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        hrMonitor.add(observer: self)
    }
    
    deinit {
        hrMonitor.remove(observer: self)
    }

    @IBAction func startButtonPressed(_ sender: UIButton) {
        sessionsService.startRecording()
    }

    @IBAction func stopButtonPressed(_ sender: UIButton) {
        sessionsService.stopRecording(finish: true)
    }
}

extension RecordVC: HRObserver {
    
    func monitor(monitor: HRMonitor, didReceiveHeartRate heartRate: Int, dateTaken: Date) {
        heartRateLabel.text = "\(heartRate)"
    }
    
    func monitor(monitor: HRMonitor, batteryLevelDidChange batteryLevel: Int) {
        
    }
}
