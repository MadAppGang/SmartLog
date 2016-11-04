//
//  WearableService.swift
//  SmartLog
//
//  Created by Dmytro Lisitsyn on 6/16/16.
//  Copyright © 2016 MadAppGang. All rights reserved.
//

import Foundation

enum WearableRealization: Int, DependencyTag {
    case pebble
    case watch
}

protocol WearableService {
    
    var deviceAvailable: Bool { get }
    
}
