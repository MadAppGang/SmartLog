//
//  ActivityType.swift
//  SmartLog
//
//  Created by Dmytro Lisitsyn on 10/11/16.
//  Copyright © 2016 MadAppGang. All rights reserved.
//

import Foundation

enum ActivityType: Int {
    case any = 0
    case butterfly = 1
    case backstroke = 2
    case breaststroke = 3
    case freestyle = 4
    case conconi = 5
    
    static var all: [ActivityType] {
        return [.any, .butterfly, .backstroke, .breaststroke, .freestyle, .conconi]
    }
    
    var string: String {
        switch self {
        case .any:
            return "Not selected"
        case .butterfly:
            return "Butterfly"
        case .backstroke:
            return "Backstroke"
        case .breaststroke:
            return "Breaststroke"
        case .freestyle:
            return "Freestyle"
        case .conconi:
            return "Conconi"
        }
    }
}
