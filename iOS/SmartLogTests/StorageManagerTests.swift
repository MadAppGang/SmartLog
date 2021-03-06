//
//  StorageManagerTests.swift
//  SmartLog
//
//  Created by Dmytro Lisitsyn on 7/8/16.
//  Copyright © 2016 MadAppGang. All rights reserved.
//

import XCTest
@testable import SmartLog

class StorageManagerTests: XCTestCase {

    var storageManager: StorageManager!
    
    override func setUp() {
        super.setUp()
        
        let expectation = self.expectation(description: "StorageManagerTests.StorageManagerConfigurationExpectation")
        
        storageManager = StorageManager(for: .testing)
        storageManager.configure(
            progressHandler: { _ in
                
            },
            completion: { result in
                switch result {
                case .successful:
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
        } catch let error {
            XCTFail("\(error)")
        }
        
        super.tearDown()
    }
    
    func testAccelerometerDataCreatingAndFetching() {
        let sessionID = 20
        
        var accelerometerData: [AccelerometerData] = []
        for index in 0...1000 {
            let accelerometerDataSample = AccelerometerData(sessionID: sessionID, x: index, y: index, z: index, dateTaken: Date(timeIntervalSince1970: TimeInterval(index)))
            accelerometerData.append(accelerometerDataSample)
        }
        
        let expectation = self.expectation(description: "StorageManagerTests.AccelerometerDataCreatingAndFetchingExpectation")
        
        storageManager.create(accelerometerData) {
            self.storageManager.fetchAccelerometerData(sessionID: sessionID) { savedAccelerometerData in
                XCTAssertEqual(accelerometerData, savedAccelerometerData)                
                expectation.fulfill()
            }
        }
        
        waitForExpectations(timeout: 0.5) { error in
            guard let error = error else { return }
            
            XCTFail("\(error)")
        }
    }
    
    func testMarkersCreatingAndFetching() {
        let sessionID = 20
        
        var markers: [Marker] = []
        for index in 0...1000 {
            let marker = Marker(sessionID: sessionID, dateAdded: Date(timeIntervalSince1970: TimeInterval(index)))
            markers.append(marker)
        }
        
        let expectation = self.expectation(description: "StorageManagerTests.MarkersCreatingAndFetchingExpectation")
        
        storageManager.create(markers) {
            self.storageManager.fetchMarkers(sessionID: sessionID) { savedMarkers in
                XCTAssertEqual(markers, savedMarkers)
                expectation.fulfill()
            }
        }
        
        waitForExpectations(timeout: 0.5) { error in
            guard let error = error else { return }
            
            XCTFail("\(error)")
        }
    }
}
