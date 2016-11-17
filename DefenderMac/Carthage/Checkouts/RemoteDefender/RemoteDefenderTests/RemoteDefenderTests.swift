//
//  RemoteDefenderTests.swift
//  RemoteDefenderTests
//
//  Created by Derek Knight on 13/11/16.
//  Copyright © 2016 Derek Knight. All rights reserved.
//

import XCTest
@testable import RemoteDefender

class RemoteDefenderTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testCreate() {
        let actual = Peripheral()
        XCTAssertNotNil(actual)
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
