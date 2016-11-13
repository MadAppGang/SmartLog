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
    
    @IBOutlet private weak var stopwatchLabel: UILabel!
    @IBOutlet private weak var markersCountLabel: UILabel!
    @IBOutlet private weak var hrMonitorNameLabel: UILabel!
    
    @IBOutlet private weak var activityTypeLabel: UILabel!
    @IBOutlet private weak var activityTypePicker: UIPickerView!

    @IBOutlet private weak var startButton: UIButton!
    @IBOutlet private weak var pauseButton: UIButton!
    @IBOutlet private weak var resumeButton: UIButton!
    @IBOutlet private weak var stopButton: UIButton!
    @IBOutlet private weak var addMarkerButton: UIButton!

    var hrMonitor: HRMonitor!
    var sessionsService: SessionsService!
    
    fileprivate var activityType: ActivityType = .any
    
    private var timer: Timer?
    private var duration: TimeInterval = 0
    private var markersCount = 0
    
    private var state: State = .stopped { didSet { stateDidChange(state) } }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        hrMonitor.add(observer: self)
    }
    
    deinit {
        hrMonitor.remove(observer: self)
    }

    @IBAction func startButtonPressed(_ sender: UIButton) {
        state = .recording
        
        sessionsService.startRecording(activityType: activityType)
        
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(durationWillChange), userInfo: nil, repeats: true)
    }
    
    @IBAction func pauseButtonPressed(_ sender: UIButton) {
        state = .paused
        
        sessionsService.pauseRecording()
    }

    @IBAction func resumeButtonPressed(_ sender: UIButton) {
        state = .recording
        
        sessionsService.resumeRecording()
    }
    
    @IBAction func stopButtonPressed(_ sender: UIButton) {
        state = .stopped
        
        sessionsService.finishRecording()
        
        timer?.invalidate()
        timer = nil
    }

    @IBAction func addMarkerButtonPressed(_ sender: UIButton) {
        markersCount += 1
        markersCountLabel.text = "\(markersCount)"

        sessionsService.addMarker()
    }
    
    func durationWillChange() {
        guard case .recording = state else { return }
        
        duration += 1
        updateStopwatchLabel(duration: duration)
    }

    private func stateDidChange(_ state: State) {
        startButton.isHidden = state != .stopped
        pauseButton.isHidden = state != .recording
        addMarkerButton.isHidden = state != .recording
        resumeButton.isHidden = state != .paused
        stopButton.isHidden = state != .paused
        
        activityTypeLabel.textColor = state == .stopped ? .white : .lightGray
        activityTypePicker.isUserInteractionEnabled = state == .stopped
        
        if case .stopped = state {
            markersCount = 0
            markersCountLabel.text = "\(markersCount)"
            
            duration = 0
            updateStopwatchLabel(duration: duration)
        }
    }
    
    private func updateStopwatchLabel(duration: TimeInterval) {
        let seconds = Int(duration) % 60
        let minutes = (Int(duration) / 60) % 60
        let hours = Int(duration) / 60 / 60
        
        stopwatchLabel.text = String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
}

extension RecordVC: HRObserver {
    
    func monitor(monitor: HRMonitor, didReceiveHeartRate heartRate: Int, dateTaken: Date) {
        heartRateLabel.text = "\(heartRate)"
    }
}

extension RecordVC: UIPickerViewDataSource {
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return ActivityType.all.count
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let string = ActivityType.all[row].string
        let attributes = [NSForegroundColorAttributeName: UIColor.white]
        
        return NSAttributedString(string: string, attributes: attributes)
    }
}

extension RecordVC: UIPickerViewDelegate {
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        activityType = ActivityType.all[row]
    }
}
