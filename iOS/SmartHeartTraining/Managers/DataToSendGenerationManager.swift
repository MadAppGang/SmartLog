//
//  DataToSendGenerationManager.swift
//  SmartHeartTraining
//
//  Created by Dmytro Lisitsyn on 6/20/16.
//  Copyright © 2016 MadAppGang. All rights reserved.
//

import Foundation

final class DataToSendGenerationManager {

}

extension DataToSendGenerationManager: DataToSendGenerationService {
    
    func convertToData(accelerometerData: [AccelerometerData]) throws -> NSData {
        guard let sessionID = accelerometerData.first?.sessionID else { throw DataToSendGenerationErrorType.noDataToWrite }
        
        var text = ""
        for dataItem in accelerometerData {
            text.appendContentsOf("\(sessionID) \(dataItem.x) \(dataItem.y) \(dataItem.z) \(dataItem.dateTaken.timeIntervalSince1970)\n")
        }

        if let data = text.dataUsingEncoding(NSUTF8StringEncoding) {
            return data
        } else {
            throw DataToSendGenerationErrorType.couldNotConvertToNSData
        }
    }
    
    func convertToData(markers: [Marker]) throws -> NSData {
        guard let sessionID = markers.first?.sessionID else { throw DataToSendGenerationErrorType.noDataToWrite }
        
        var text = ""
        for marker in markers {
            text.appendContentsOf("\(sessionID) \(marker.dateAdded.timeIntervalSince1970)\n")
        }
        
        if let data = text.dataUsingEncoding(NSUTF8StringEncoding) {
            return data
        } else {
            throw DataToSendGenerationErrorType.couldNotConvertToNSData
        }
    }
}