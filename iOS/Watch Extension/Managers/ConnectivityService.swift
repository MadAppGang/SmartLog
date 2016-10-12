//
//  ConnectivityService.swift
//  SmartLog
//
//  Created by Dmytro Lisitsyn on 10/11/16.
//  Copyright © 2016 MadAppGang. All rights reserved.
//

import Foundation

enum ConnectivityServiceError: Error {
    case connectivityIsNotSupported
}

protocol ConnectivityService {
    
    var connectionActivated: Bool { get }
    
    func activateConnection() throws
    
}
