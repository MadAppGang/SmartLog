//
//  RecordVC.swift
//  SmartLog
//
//  Created by Dmytro Lisitsyn on 11/7/16.
//  Copyright © 2016 MadAppGang. All rights reserved.
//

import UIKit

final class RecordVC: UIViewController {

    private enum State {
        case recording
        case paused
        case stopped
    }
    
    @IBOutlet fileprivate weak var heartRateLabel: UILabel!
    
    @IBOutlet private weak var startButton: UIButton!
    @IBOutlet private weak var pauseButton: UIButton!
    @IBOutlet private weak var resumeButton: UIButton!
    @IBOutlet private weak var stopButton: UIButton!
    @IBOutlet private weak var addMarkerButton: UIButton!

    var hrMonitor: HRMonitor!
    var sessionsService: SessionsService!
    
    private var state: State = .stopped {
        didSet {
            updateInterface(state: state)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        hrMonitor.add(observer: self)
    }
    
    deinit {
        hrMonitor.remove(observer: self)
    }

    @IBAction func startButtonPressed(_ sender: UIButton) {
        state = .recording
        
        sessionsService.startRecording()
    }
    
    @IBAction func pauseButtonPressed(_ sender: UIButton) {
        state = .paused
        
        sessionsService.stopRecording(finish: false)
    }

    @IBAction func resumeButtonPressed(_ sender: UIButton) {
        state = .recording

        sessionsService.startRecording()
    }
    
    @IBAction func stopButtonPressed(_ sender: UIButton) {
        state = .stopped

        sessionsService.stopRecording(finish: true)
    }

    @IBAction func addMarkerButtonPressed(_ sender: UIButton) {
        sessionsService.addMarker()
    }
    
    private func updateInterface(state: State) {
        startButton.isHidden = state != .stopped
        pauseButton.isHidden = state != .recording
        addMarkerButton.isHidden = state != .recording
        resumeButton.isHidden = state != .paused
        stopButton.isHidden = state != .paused
    }
}

extension RecordVC: HRObserver {
    
    func monitor(monitor: HRMonitor, didReceiveHeartRate heartRate: Int, dateTaken: Date) {
        heartRateLabel.text = "\(heartRate)"
    }
    
    func monitor(monitor: HRMonitor, batteryLevelDidChange batteryLevel: Int) {
        
    }
}
