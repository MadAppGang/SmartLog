//
//  StorageManagerTests.swift
//  SmartHeartTraining
//
//  Created by Dmytro Lisitsyn on 7/8/16.
//  Copyright © 2016 MadAppGang. All rights reserved.
//

import XCTest
@testable import SmartHeartTraining

class StorageManagerTests: XCTestCase {

    var storageManager: StorageManager!
    
    override func setUp() {
        super.setUp()
        
        let expectation = expectationWithDescription("StorageManagerTests.StorageManagerConfigurationExpectation")
        
        storageManager = StorageManager(purpose: .testing)
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
        
        waitForExpectationsWithTimeout(60) { error in
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
    
    func testAccelerometerDataCreatingAndFetching() {
        let sessionID = 20
        
        var accelerometerData: [AccelerometerData] = []
        for index in 0...1000 {
            let accelerometerDataSample = AccelerometerData(sessionID: sessionID, x: index, y: index, z: index, dateTaken: NSDate(timeIntervalSince1970: NSTimeInterval(index)))
            accelerometerData.append(accelerometerDataSample)
        }
        
        let expectation = expectationWithDescription("StorageManagerTests.AccelerometerDataCreatingAndFetchingExpectation")
        
        storageManager.create(accelerometerData) {
            let savedAccelerometerData = self.storageManager.fetchAccelerometerData(sessionID: sessionID)
            
            XCTAssertEqual(accelerometerData, savedAccelerometerData)
            
            expectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(0.2) { error in
            guard let error = error else { return }
            
            XCTFail("\(error)")
        }
    }
    
    func testMarkersCreatingAndFetching() {
        let sessionID = 20
        
        var markers: [Marker] = []
        for index in 0...1000 {
            let marker = Marker(sessionID: sessionID, dateAdded: NSDate(timeIntervalSince1970: NSTimeInterval(index)))
            markers.append(marker)
        }
        
        let expectation = expectationWithDescription("StorageManagerTests.MarkersCreatingAndFetchingExpectation")
        
        storageManager.create(markers) {
            let savedMarkers = self.storageManager.fetchMarkers(sessionID: sessionID)
            
            XCTAssertEqual(markers, savedMarkers)
            
            expectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(0.2) { error in
            guard let error = error else { return }
            
            XCTFail("\(error)")
        }
    }

}
