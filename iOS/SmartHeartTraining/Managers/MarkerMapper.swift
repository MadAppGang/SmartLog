//
//  MarkerMapper.swift
//  SmartHeartTraining
//
//  Created by Dmytro Lisitsyn on 7/8/16.
//  Copyright © 2016 MadAppGang. All rights reserved.
//

import Foundation

final class MarkerMapper {
    
    static func toMarker(cdMarker cdMarker: CDMarker) -> Marker {
        let sessionID = cdMarker.session?.id?.integerValue ?? 0
        let dateAdded = cdMarker.dateAdded ?? NSDate()
        
        let marker = Marker(sessionID: sessionID, dateAdded: dateAdded)
        return marker
    }
    
    static func map(cdMarker cdMarker: CDMarker, with marker: Marker, and cdSession: CDSession) -> CDMarker {
        cdMarker.dateAdded = marker.dateAdded
        cdSession.addMarkersObject(cdMarker)
        
        return cdMarker
    }

}