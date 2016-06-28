//
//  EntitiesSortExtension.swift
//  SmartHeartTraining
//
//  Created by Dmytro Lisitsyn on 6/28/16.
//  Copyright © 2016 MadAppGang. All rights reserved.
//

import Foundation

extension SequenceType where Generator.Element == AccelerometerData {
    
    func sortByDateTaken(comparisonResult: NSComparisonResult) -> [AccelerometerData] {
        return sort({ $0.dateTaken.compare($1.dateTaken) == comparisonResult })
    }
}

extension SequenceType where Generator.Element == Marker {
    
    func sortByDateAdded(comparisonResult: NSComparisonResult) -> [Marker] {
        return sort({ $0.dateAdded.compare($1.dateAdded) == comparisonResult })
    }
}

extension SequenceType where Generator.Element == Session {
    
    func sortByDateStarted(comparisonResult: NSComparisonResult) -> [Session] {
        return sort({ $0.dateStarted.compare($1.dateStarted) == comparisonResult })
    }
}