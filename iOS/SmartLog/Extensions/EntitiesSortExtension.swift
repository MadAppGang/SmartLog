//
//  EntitiesSortExtension.swift
//  SmartLog
//
//  Created by Dmytro Lisitsyn on 6/28/16.
//  Copyright © 2016 MadAppGang. All rights reserved.
//

import Foundation

extension Sequence where Iterator.Element == AccelerometerData {
    
    func sortByDateTaken(_ comparisonResult: ComparisonResult) -> [AccelerometerData] {
        return sorted(by: { $0.dateTaken.compare($1.dateTaken) == comparisonResult })
    }
}

extension Sequence where Iterator.Element == Marker {
    
    func sortByDateAdded(_ comparisonResult: ComparisonResult) -> [Marker] {
        return sorted(by: { $0.dateAdded.compare($1.dateAdded) == comparisonResult })
    }
}

extension Sequence where Iterator.Element == Session {
    
    func sortByDateStarted(_ comparisonResult: ComparisonResult) -> [Session] {
        return sorted(by: { $0.dateStarted.compare($1.dateStarted) == comparisonResult })
    }
}

extension Sequence where Iterator.Element == HRData {
    
    func sortByDateTaken(_ comparisonResult: ComparisonResult) -> [HRData] {
        return sorted(by: { $0.dateTaken.compare($1.dateTaken) == comparisonResult })
    }
}
