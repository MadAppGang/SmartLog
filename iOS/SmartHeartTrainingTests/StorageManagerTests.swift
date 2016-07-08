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
    
    func testCreateAcceleromterData() {
        
    }
}
