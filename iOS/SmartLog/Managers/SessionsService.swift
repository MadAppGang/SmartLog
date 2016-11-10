//
//  SessionsService.swift
//  SmartLog
//
//  Created by Dmytro Lisitsyn on 11/10/16.
//  Copyright © 2016 MadAppGang. All rights reserved.
//

import Foundation

protocol SessionsService {
    
    func startRecording()
    func stopRecording(finish: Bool)
    
    func addMarker()
    
}
