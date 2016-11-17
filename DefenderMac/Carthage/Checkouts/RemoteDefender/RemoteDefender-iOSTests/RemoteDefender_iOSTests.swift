//
//  RemoteDefender_iOSTests.swift
//  RemoteDefender-iOSTests
//
//  Created by Derek Knight on 14/11/16.
//  Copyright © 2016 Derek Knight. All rights reserved.
//

import XCTest
@testable import RemoteDefender

class RemoteDefender_iOSTests: XCTestCase {
    
    let startTimeout: TimeInterval = 5

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testCreate() {
        let actual = Central()
        XCTAssertNotNil(actual)
    }

    /*
     Will Need a true mock to run unit tests. Cannot run Bluetooth on Simulator
    func testStart() {
        let actual = Central()
        XCTAssertNotNil(actual)
        
        let startExpectation = self.expectation(description: "\(#function)\(#line)")
        CentralNotification.centralBecameAvailable.observe() { notification in
            startExpectation.fulfill()
        }
        actual.start()
        self.waitForExpectations(timeout: startTimeout) { (timeoutError) in }

        actual.stop()
        
    }
     */

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}

