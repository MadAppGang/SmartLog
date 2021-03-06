//
//  InterfaceController.swift
//  SmartLog
//
//  Created by Dmytro Lisitsyn on 10/7/16.
//  Copyright © 2016 MadAppGang. All rights reserved.
//

import WatchKit
import Foundation

final class InterfaceController: WKInterfaceController {
    
    @IBOutlet private var timer: WKInterfaceTimer!
    @IBOutlet private var markersCountLabel: WKInterfaceLabel!

    @IBOutlet private var activityTypePicker: WKInterfacePicker!
    
    @IBOutlet private var startButton: WKInterfaceButton!
    @IBOutlet private var stopButton: WKInterfaceButton!
    
    fileprivate var sessionsService: SessionsService!
    
    fileprivate var canAddMarker = true
    fileprivate var markersCount = 0

    private let activityTypes: [ActivityType] = ActivityType.all
    
    private var selectedActivityType: ActivityType = .any
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        crownSequencer.delegate = self
        
        let connectivityManager = ConnectivityManager()
        try? connectivityManager.activateConnection()
        sessionsService = SessionsManager(connectivityService: connectivityManager)

        let pickerItems = activityTypes.map { activityType -> WKPickerItem in
            let pickerItem = WKPickerItem()
            pickerItem.title = activityType.string
            
            return pickerItem
        }
        activityTypePicker.setItems(pickerItems)
        
        let index = ActivityType.all.index(of: .any) ?? 0
        activityTypePicker.setSelectedItemIndex(index)
        
        updateInterface(sessionStarted: false)
    }
    
    @IBAction func startButtonDidPress() {
        try? sessionsService.beginSession(activityType: selectedActivityType)
        
        updateInterface(sessionStarted: true)
    }

    @IBAction func stopButtonDidPress() {
        sessionsService.endSession()
     
        updateInterface(sessionStarted: false)
    }
    
    @IBAction func activityTypePickerValueDidChange(_ value: Int) {
        selectedActivityType = activityTypes[value]
    }
    
    fileprivate func updateMarkersCountLabel(markersCount: Int) {
        markersCountLabel.setText("\(markersCount)")
    }
    
    private func updateInterface(sessionStarted: Bool) {
        startButton.setHidden(sessionStarted)
        stopButton.setHidden(!sessionStarted)
        
        markersCount = 0
        updateMarkersCountLabel(markersCount: markersCount)

        activityTypePicker.setEnabled(!sessionStarted)
        
        if sessionStarted {
            crownSequencer.focus()
            
            timer.setDate(Date())
            timer.start()
        } else {
            activityTypePicker.focus()
            
            timer.stop()
            timer.setDate(Date())
        }
    }
}

extension InterfaceController: WKCrownDelegate {
    
    func crownDidRotate(_ crownSequencer: WKCrownSequencer?, rotationalDelta: Double) {
        guard canAddMarker && abs(rotationalDelta) > 0.12 else { return }

        canAddMarker = false
        
        sessionsService.addMarker()
        
        markersCount += 1;
        updateMarkersCountLabel(markersCount: markersCount)
    }
    
    func crownDidBecomeIdle(_ crownSequencer: WKCrownSequencer?) {
        canAddMarker = true
    }
}
