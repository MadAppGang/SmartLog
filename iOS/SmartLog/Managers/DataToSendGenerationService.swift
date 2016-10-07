//
//  DataToSendGenerationService.swift
//  SmartLog
//
//  Created by Dmytro Lisitsyn on 6/20/16.
//  Copyright © 2016 MadAppGang. All rights reserved.
//

import Foundation

enum DataToSendGenerationErrorType: Error {
    case couldNotConvertToNSData
    case noDataToWrite
}

protocol DataToSendGenerationService {
    
    /**
     Convers accelerometer data to `NSData` to send.
     
     - Parameter accelerometerData: The array of `AccelerometerData` objects to convert.
     - Returns: The data to send.
     */
    func convertToData(_ accelerometerData: [AccelerometerData]) throws -> Data
    
    /**
     Convers markers to `NSData` to send.
     
     - Parameter markers: The array of `Marker` objects to convert.
     - Returns: The data to send.
     */
    func convertToData(_ markers: [Marker]) throws -> Data
    
}
