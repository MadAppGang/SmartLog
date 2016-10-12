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
    
    @IBOutlet var timer: WKInterfaceTimer!
    @IBOutlet var markersCountLabel: WKInterfaceLabel!

    @IBOutlet var activityTypePicker: WKInterfacePicker!
    
    @IBOutlet var startButton: WKInterfaceButton!
    @IBOutlet var stopButton: WKInterfaceButton!
    
    private var sessionsService: SessionsService!
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        let pickerItems = ActivityType.all.map { activityType -> WKPickerItem in
            let pickerItem = WKPickerItem()
            pickerItem.title = activityType.string
            
            return pickerItem
        }
        activityTypePicker.setItems(pickerItems)
        activityTypePicker.setSelectedItemIndex(0)
                
        let connectivityService: ConnectivityService = ConnectivityManager()
        try? connectivityService.activateConnection()
        sessionsService = SessionsManager(connectivityService: connectivityService)
    }

    override func willActivate() {
        super.willActivate()
        
    }

    override func didDeactivate() {
        super.didDeactivate()
        
    }
    
    @IBAction func startButtonDidPress() {
        try? sessionsService.beginSession()
        
        startButton.setHidden(true)
        stopButton.setHidden(false)
        
        activityTypePicker.resignFocus()
        activityTypePicker.setEnabled(false)
    }

    @IBAction func stopButtonDidPress() {
        sessionsService.endSession()
        
        startButton.setHidden(false)
        stopButton.setHidden(true)
        
        activityTypePicker.focus()
        activityTypePicker.setEnabled(true)
    }
    
    @IBAction func activityTypePickerValueDidChange(_ value: Int) {
        
    }
}
