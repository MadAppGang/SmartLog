//
//  SessionsService.swift
//  SmartLog
//
//  Created by Dmytro Lisitsyn on 11/10/16.
//  Copyright © 2016 MadAppGang. All rights reserved.
//

import Foundation

protocol SessionsService {
    
    func startRecording(activityType: ActivityType)
    func resumeRecording()
    func pauseRecording()
    func finishRecording()
    
    func addMarker()
    
}
