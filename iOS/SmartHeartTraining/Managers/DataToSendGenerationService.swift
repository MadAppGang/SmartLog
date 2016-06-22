//
//  DataToSendGenerationService.swift
//  SmartHeartTraining
//
//  Created by Dmytro Lisitsyn on 6/20/16.
//  Copyright © 2016 MadAppGang. All rights reserved.
//

import Foundation

enum DataToSendGenerationErrorType: ErrorType {
    case couldNotConvertToNSData
    case noDataToWrite
}

protocol DataToSendGenerationService {
    
    /**
     Convers accelerometer data to `NSData` to send.
     
     - Parameter accelerometerData: The array of `AccelerometerData` objects to convert.
     - Returns: The data to send.
     */
    func convertToData(accelerometerData: [AccelerometerData]) throws -> NSData
    
    /**
     Convers markers to `NSData` to send.
     
     - Parameter markers: The array of `Marker` objects to convert.
     - Returns: The data to send.
     */
    func convertToData(markers: [Marker]) throws -> NSData
    
}