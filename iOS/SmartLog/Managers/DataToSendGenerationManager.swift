//
//  DataToSendGenerationManager.swift
//  SmartLog
//
//  Created by Dmytro Lisitsyn on 6/20/16.
//  Copyright © 2016 MadAppGang. All rights reserved.
//

import Foundation

final class DataToSendGenerationManager {

}

extension DataToSendGenerationManager: DataToSendGenerationService {
    
    func convertToData(_ accelerometerData: [AccelerometerData]) throws -> Data {
        guard !accelerometerData.isEmpty else { throw DataToSendGenerationError.noDataToWrite }
        
        var text = ""
        for dataItem in accelerometerData {
            text.append("\(dataItem.x) \(dataItem.y) \(dataItem.z) \(dataItem.dateTaken.timeIntervalSince1970)\n")
        }

        if let data = text.data(using: String.Encoding.utf8) {
            return data
        } else {
            throw DataToSendGenerationError.couldNotConvertToNSData
        }
    }
    
    func convertToData(_ hrData: [HRData]) throws -> Data {
        guard !hrData.isEmpty else { throw DataToSendGenerationError.noDataToWrite }
        
        var text = ""
        for hrDataSample in hrData {
            text.append("\(hrDataSample.heartRate) \(hrDataSample.dateTaken.timeIntervalSince1970)\n")
        }
        
        if let data = text.data(using: String.Encoding.utf8) {
            return data
        } else {
            throw DataToSendGenerationError.couldNotConvertToNSData
        }
    }
    
    func convertToData(_ markers: [Marker]) throws -> Data {
        guard !markers.isEmpty else { throw DataToSendGenerationError.noDataToWrite }
        
        var text = ""
        for marker in markers {
            text.append("\(marker.dateAdded.timeIntervalSince1970)\n")
        }
        
        if let data = text.data(using: String.Encoding.utf8) {
            return data
        } else {
            throw DataToSendGenerationError.couldNotConvertToNSData
        }
    }
}
