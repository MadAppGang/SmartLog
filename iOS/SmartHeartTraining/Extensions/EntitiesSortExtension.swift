//
//  EntitiesSortExtension.swift
//  SmartHeartTraining
//
//  Created by Dmytro Lisitsyn on 6/28/16.
//  Copyright © 2016 MadAppGang. All rights reserved.
//

import Foundation

extension Sequence where Iterator.Element == AccelerometerData {
    
    func sortByDateTaken(_ comparisonResult: ComparisonResult) -> [AccelerometerData] {
        return sorted(by: { $0.dateTaken.compare($1.dateTaken as Date) == comparisonResult })
    }
}

extension Sequence where Iterator.Element == Marker {
    
    func sortByDateAdded(_ comparisonResult: ComparisonResult) -> [Marker] {
        return sorted(by: { $0.dateAdded.compare($1.dateAdded as Date) == comparisonResult })
    }
}

extension Sequence where Iterator.Element == Session {
    
    func sortByDateStarted(_ comparisonResult: ComparisonResult) -> [Session] {
        return sorted(by: { $0.dateStarted.compare($1.dateStarted as Date) == comparisonResult })
    }
}
