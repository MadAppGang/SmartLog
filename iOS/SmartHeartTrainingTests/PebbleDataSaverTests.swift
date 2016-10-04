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
        
        storageManager = StorageManager(for: .testing)
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
        let int16Size = MemoryLayout<Int16>.size
        
        var accelerometerData: [AccelerometerData] = []
        var bytes: [UInt8] = []
        
        for index in 0...1000 {
            let tenthOfTimestamp = TimeInterval(index % 10) / 10
            let sample = AccelerometerData(sessionID: Int(sessionTimestamp), x: index, y: index, z: index, dateTaken: Date(timeIntervalSince1970: TimeInterval(index) + tenthOfTimestamp))
            accelerometerData.append(sample)
            
            var x = sample.x
            let xBytes = withUnsafePointer(to: &x) {
                $0.withMemoryRebound(to: UInt8.self, capacity: int16Size) {
                    Array(UnsafeBufferPointer(start: $0, count: int16Size))
                }
            }
            bytes.append(contentsOf: xBytes)
            
            var y = sample.y
            let yBytes = withUnsafePointer(to: &y) {
                $0.withMemoryRebound(to: UInt8.self, capacity: int16Size) {
                    Array(UnsafeBufferPointer(start: $0, count: int16Size))
                }
            }
            bytes.append(contentsOf: yBytes)
            
            var z = sample.z
            let zBytes = withUnsafePointer(to: &z) {
                $0.withMemoryRebound(to: UInt8.self, capacity: int16Size) {
                    Array(UnsafeBufferPointer(start: $0, count: int16Size))
                }
            }
            bytes.append(contentsOf: zBytes)
            
            var timeInterval = sample.dateTaken.timeIntervalSince1970
            let timeIntervalBytes = withUnsafePointer(to: &timeInterval) {
                $0.withMemoryRebound(to: UInt8.self, capacity: MemoryLayout<TimeInterval>.size) {
                    Array(UnsafeBufferPointer(start: $0, count: MemoryLayout<TimeInterval>.size))
                }
            }
            bytes.append(contentsOf: timeIntervalBytes)
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
