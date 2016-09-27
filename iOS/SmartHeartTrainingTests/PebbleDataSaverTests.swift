//
//  PebbleDataSaverTests.swift
//  SmartHeartTraining
//
//  Created by Dmytro Lisitsyn on 7/8/16.
//  Copyright © 2016 MadAppGang. All rights reserved.
//

import XCTest
@testable import SmartHeartTraining

class PebbleDataSaverTests: XCTestCase {

    var pebbleDataSaver: PebbleDataSaver!
    var storageManager: StorageManager!
    
    override func setUp() {
        super.setUp()
        
        let expectation = self.expectation(description: "PebbleDataSaverTests.StorageManagerConfigurationExpectation")
        
        storageManager = StorageManager(purpose: .testing)
        storageManager.configure(
            progressHandler: { _ in
                
            },
            completion: { result in
                switch result {
                case .successful:
                    self.pebbleDataSaver = PebbleDataSaver(storageService: self.storageManager)
                    expectation.fulfill()
                case .failed(let error):
                    XCTFail("\(error)")
                }
            }
        )
        
        waitForExpectations(timeout: 60) { error in
            guard let error = error else { return }
            
            XCTFail("\(error)")
        }
    }
    
    override func tearDown() {
        do {
            try storageManager.deleteStorage()
        } catch(let error) {
            XCTFail("\(error)")
        }
        
        super.tearDown()
    }

    func testAccelerometerDataSaving() {
        let sessionTimestamp: UInt32 = 0
        
        var accelerometerData: [AccelerometerData] = []
        var bytes: [UInt8] = []
        
        for index in 0...1000 {
            let tenthOfTimestamp = TimeInterval(index % 10) / 10
            let sample = AccelerometerData(sessionID: Int(sessionTimestamp), x: index, y: index, z: index, dateTaken: Date(timeIntervalSince1970: TimeInterval(index) + tenthOfTimestamp))
            accelerometerData.append(sample)
            
            bytes.appendContentsOf(Array(UnsafeBufferPointer(start: UnsafePointer([sample.x]), count: sizeof(Int16))) as [UInt8])
            bytes.appendContentsOf(Array(UnsafeBufferPointer(start: UnsafePointer([sample.y]), count: sizeof(Int16))) as [UInt8])
            bytes.appendContentsOf(Array(UnsafeBufferPointer(start: UnsafePointer([sample.z]), count: sizeof(Int16))) as [UInt8])
            bytes.appendContentsOf(Array(UnsafeBufferPointer(start: UnsafePointer([UInt32(sample.dateTaken.timeIntervalSince1970)]), count: sizeof(UInt32))) as [UInt8])
        }
        
        let expectation = self.expectation(description: "PebbleDataSaverTests.AccelerometerDataBytesSavingExpectation")
        
        pebbleDataSaver.save(accelerometerDataBytes: bytes, sessionTimestamp: sessionTimestamp) {
            let savedAccelerometerData = self.storageManager.fetchAccelerometerData(sessionID: Int(sessionTimestamp))
            
            XCTAssertEqual(accelerometerData, savedAccelerometerData)
            
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 0.5) { error in
            guard let error = error else { return }
            
            XCTFail("\(error)")
        }
    }
    
    func testMarkersDataSaving() {
        let sessionTimestamp: UInt32 = 0

        var markers: [Marker] = []
        var data: [UInt32] = []
        
        for index in 1...1000 {
            let marker = Marker(sessionID: Int(sessionTimestamp), dateAdded: Date(timeIntervalSince1970: TimeInterval(index)))
            markers.append(marker)
            
            data.append(UInt32(marker.dateAdded.timeIntervalSince1970))
        }
        
        let expectation = self.expectation(description: "PebbleDataSaverTests.MarkersDataSavingExpectation")
        
        pebbleDataSaver.save(markersData: data, sessionTimestamp: sessionTimestamp) {
            let savedMarkers = self.storageManager.fetchMarkers(sessionID: Int(sessionTimestamp))
            
            XCTAssertEqual(markers, savedMarkers)
            
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 0.5) { error in
            guard let error = error else { return }
            
            XCTFail("\(error)")
        }
    }
}
