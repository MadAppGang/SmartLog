//
//  MarkerMapper.swift
//  SmartLog
//
//  Created by Dmytro Lisitsyn on 7/8/16.
//  Copyright © 2016 MadAppGang. All rights reserved.
//

import Foundation

final class MarkerMapper {
    
    static func toMarker(cdMarker: CDMarker) -> Marker {
        let sessionID = cdMarker.session?.id?.intValue ?? 0
        let dateAdded = cdMarker.dateAdded ?? Date()
        
        let marker = Marker(sessionID: sessionID, dateAdded: dateAdded)
        return marker
    }
    
    static func map(cdMarker: CDMarker, with marker: Marker, and cdSession: CDSession) -> CDMarker {
        cdMarker.dateAdded = marker.dateAdded
        cdSession.addMarkersObject(cdMarker)
        
        return cdMarker
    }

}
