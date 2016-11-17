//
//  MustangTests.swift
//  MustangTests
//
//  Created by Derek Knight on 26/06/16.
//  Copyright © 2016 Derek Knight. All rights reserved.
//

import XCTest
@testable import Mustang

class MustangTests: XCTestCase {
    
    let connectTimeout: TimeInterval = 15
    let presetsTimeout: TimeInterval = 5
    let loginTimeout: TimeInterval = 5
    let searchTimeout: TimeInterval = 20

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testConstructor() {
        let actual = Mustang()
        XCTAssertNotNil(actual)
    }
    
    func testGetUSBDevices() {
        let actual = Mustang().getUSBDevices()
        XCTAssertNotNil(actual)
        XCTAssertNotEqual(actual.count, 0)
    }
    
    func testGetHIDDevices() {
        let actual = Mustang().getHIDDevices()
        XCTAssertNotNil(actual)
        XCTAssertNotEqual(actual.count, 0)
    }
    
    func testGetAudioDevices() {
        let actual = Mustang().getAudioDevices()
        XCTAssertNotNil(actual)
        XCTAssertNotEqual(actual.count, 0)
    }
    
    func testGetAmplifiers() {
        let amps = Mustang().getConnectedAmplifiers()
        XCTAssertNotNil(amps)
        XCTAssertNotEqual(amps.count, 0)
    }
    
    func testFirstAmpType() {
        let amps = Mustang().getConnectedAmplifiers()
        XCTAssertNotNil(amps)
        XCTAssertNotEqual(amps.count, 0)
        if amps.count > 0 {
            let actual = Mustang().getAmplifierType(amps[0])
            XCTAssertNotEqual(actual, "Unknown")
        }
    }
    
    func testGetAllPresets() {
        let amps = Mustang().getConnectedAmplifiers()
        XCTAssertNotNil(amps)
        XCTAssertNotEqual(amps.count, 0)
        if amps.count > 0 {
            var actual: [DTOPreset]? = nil
            let presetsExpectation = self.expectation(description: "\(#function)\(#line)")
            Mustang().getPresets(amps[0]) { (presets) in
                actual = presets
                presetsExpectation.fulfill()
            }
            self.waitForExpectations(timeout: presetsTimeout) { (timeoutError) in }
            XCTAssertNotNil(actual)
            XCTAssertNotEqual(actual?.count, 0, "No presets. There should be at least 1")
            if actual?.count ?? 0 > 0 {
                actual = actual?.sorted { $0.number ?? 255 < $1.number ?? 255 }
                let first = actual![0]
                XCTAssertEqual(first.name, "Liquid Solo")
                XCTAssertEqual(first.moduleName, "American '90s")
                XCTAssertEqual(first.cabinetName, "1x15 Vintage")
                XCTAssertNotNil(first.volume, "The first preset is not valid")
                if first.volume != nil {
                    XCTAssertEqualWithAccuracy(first.volume!, 8.1, accuracy: 0.1)
                    XCTAssertEqualWithAccuracy(first.gain1!, 7.5, accuracy: 0.1)
                    XCTAssertEqualWithAccuracy(first.gain2!, 5.5, accuracy: 0.1)
                    XCTAssertEqualWithAccuracy(first.treble!, 5.3, accuracy: 0.1)
                    XCTAssertEqualWithAccuracy(first.middle!, 3.4, accuracy: 0.1)
                    XCTAssertEqualWithAccuracy(first.bass!, 8.0, accuracy: 0.1)
                    XCTAssertEqualWithAccuracy(first.presence!, 5.0, accuracy: 0.1)
                    let actualStp = first.effects.filter({$0.type == .Stomp}).first
                    XCTAssertNil(actualStp)
                    XCTAssertNil(actualStp?.name)
                    let actualMod = first.effects.filter({$0.type == .Modulation}).first
                    XCTAssertNil(actualMod)
                    XCTAssertNil(actualMod?.name)
                    let actualDel = first.effects.filter({$0.type == .Delay}).first
                    XCTAssertNotNil(actualDel)
                    XCTAssertEqual(actualDel?.name, "Tape")
                    let actualRev = first.effects.filter({$0.type == .Reverb}).first
                    XCTAssertNotNil(actualRev)
                    XCTAssertEqual(actualRev?.name, "Small Hall")
                }
            }
        }
    }
    
    func testGetPresetForSlot1() {
        let amps = Mustang().getConnectedAmplifiers()
        XCTAssertNotNil(amps)
        XCTAssertNotEqual(amps.count, 0)
        if amps.count > 0 {
            var actual: DTOPreset? = nil
            let presetsExpectation = self.expectation(description: "\(#function)\(#line)")
            Mustang().getPreset(amps[0], preset: 1) { (preset) in
                actual = preset
                presetsExpectation.fulfill()
            }
            self.waitForExpectations(timeout: presetsTimeout) { (timeoutError) in }
            XCTAssertNotNil(actual)
            if let actual = actual {
                XCTAssertEqual(actual.name, "Whitechapel Heavy")
                XCTAssertEqual(actual.moduleName, "Metal 2000")
                XCTAssertEqual(actual.cabinetName, "2x15 Vintage")
                XCTAssertEqualWithAccuracy(actual.volume!, 8.0, accuracy: 0.1)
                XCTAssertEqualWithAccuracy(actual.gain1!, 4.0, accuracy: 0.1)
                XCTAssertEqualWithAccuracy(actual.gain2!, 5.5, accuracy: 0.1)
                XCTAssertEqualWithAccuracy(actual.treble!, 6.0, accuracy: 0.1)
                XCTAssertEqualWithAccuracy(actual.middle!, 6.0, accuracy: 0.1)
                XCTAssertEqualWithAccuracy(actual.bass!, 8.0, accuracy: 0.1)
                XCTAssertEqualWithAccuracy(actual.presence!, 5.5, accuracy: 0.1)
                let actualStp = actual.effects.filter({$0.type == .Stomp}).first
                XCTAssertNotNil(actualStp)
                XCTAssertEqual(actualStp?.name, "Overdrive")
                XCTAssertNotEqual(actualStp?.knobs.count, 0)
                let actualMod = actual.effects.filter({$0.type == .Modulation}).first
                XCTAssertNil(actualMod)
                XCTAssertNil(actualMod?.name)
                let actualDel = actual.effects.filter({$0.type == .Delay}).first
                XCTAssertNil(actualDel)
                XCTAssertNil(actualDel?.name)
                let actualRev = actual.effects.filter({$0.type == .Reverb}).first
                XCTAssertNotNil(actualRev)
                XCTAssertEqual(actualRev?.name, "Large Hall")
                XCTAssertNotEqual(actualRev?.knobs.count, 0)
            }
            Mustang().getPreset(amps[0], preset: 0) { (preset) in } // Set back to preset 0
        }
    }
    
    func testSetPresetForSlot97() {
        let amps = Mustang().getConnectedAmplifiers()
        XCTAssertNotNil(amps)
        XCTAssertNotEqual(amps.count, 0)
        if amps.count > 0 {
            var vOriginal: DTOPreset? = nil
            let getPresetsExpectation = self.expectation(description: "\(#function)\(#line)")
            Mustang().getPreset(amps[0], preset: 97) { (preset) in
                vOriginal = preset
                getPresetsExpectation.fulfill()
            }
            self.waitForExpectations(timeout: presetsTimeout) { (timeoutError) in }
            XCTAssertNotNil(vOriginal)
            if let original = vOriginal {
                XCTAssertEqual(original.name, "Basic Super-Sonic")
                XCTAssertEqual(original.moduleName, "Super-Sonic")
                XCTAssertEqual(original.cabinetName, "1x18 Vintage")
                XCTAssertEqualWithAccuracy(original.volume!, 8.3, accuracy: 0.1)
                XCTAssertEqualWithAccuracy(original.gain1!, 7.67, accuracy: 0.1)
                XCTAssertEqualWithAccuracy(original.gain2!, 5.6, accuracy: 0.1)
                XCTAssertEqualWithAccuracy(original.treble!, 6.4, accuracy: 0.1)
                XCTAssertEqualWithAccuracy(original.middle!, 6.7, accuracy: 0.1)
                XCTAssertEqualWithAccuracy(original.bass!, 6.4, accuracy: 0.1)
                XCTAssertEqualWithAccuracy(original.presence!, 5.5, accuracy: 0.1)
                let actualStp = original.effects.filter({$0.type == .Stomp}).first
                XCTAssertNil(actualStp)
                XCTAssertNil(actualStp?.name)
                let actualMod = original.effects.filter({$0.type == .Modulation}).first
                XCTAssertNil(actualMod)
                XCTAssertNil(actualMod?.name)
                let actualDel = original.effects.filter({$0.type == .Delay}).first
                XCTAssertNil(actualDel)
                XCTAssertNil(actualDel?.name)
                let actualRev = original.effects.filter({$0.type == .Reverb}).first
                XCTAssertNil(actualRev)
                XCTAssertNil(actualRev?.name)
                print("Got")

                vOriginal!.treble = 6.4
                
                let setPresetsExpectation = self.expectation(description: "\(#function)\(#line)")
                var changed: DTOPreset? = nil
                Mustang().setPreset(amps[0], preset: vOriginal!) { (preset) in
                    changed = preset
                    setPresetsExpectation.fulfill()
                }
                self.waitForExpectations(timeout: presetsTimeout) { (timeoutError) in }
                XCTAssertNotNil(changed)
                print("Changed")
                
                let savePresetsExpectation = self.expectation(description: "\(#function)\(#line)")
                var saved: Bool? = nil
                Mustang().savePreset(amps[0], preset: 97, name: "Basic Super-Sonic", onCompletion: { (wasSaved) in
                    saved = wasSaved
                    savePresetsExpectation.fulfill()
                })
                self.waitForExpectations(timeout: presetsTimeout) { (timeoutError) in }
                XCTAssertNotNil(saved)
                XCTAssert(saved == true)
                print("Saved")
            }
            //Mustang().getPreset(amps[0], preset: 0) { (preset) in } // Set back to preset 0
        }
    }
    
    func testLogin() {
        let loginPresetExpectation = self.expectation(description: "\(#function)\(#line)")
        var loggedIn = false
        Mustang().login(username: "derekk19",
                        password: "Fe62h2zj",
                        onSuccess: {
                            loginPresetExpectation.fulfill()
                            loggedIn = true
                        },
                        onFail: { (error) in
                            loginPresetExpectation.fulfill()
                        }
        )
        self.waitForExpectations(timeout: loginTimeout) { (timeoutError) in }
        XCTAssert(loggedIn)
    }
    
    func testLoginLogout() {
        let loginExpectation = self.expectation(description: "\(#function)\(#line)")
        var loggedIn = false
        Mustang().login(username: "derekk19",
                        password: "Fe62h2zj",
                        onSuccess: {
                            loginExpectation.fulfill()
                            loggedIn = true
                        },
                        onFail: { (error) in
                            loginExpectation.fulfill()
                        }
        )
        self.waitForExpectations(timeout: loginTimeout) { (timeoutError) in }
        XCTAssert(loggedIn)
        
        let logoutPresetExpectation = self.expectation(description: "\(#function)\(#line)")
        var loggedOut = false
        Mustang().logout(onSuccess: {
                            logoutPresetExpectation.fulfill()
                            loggedOut = true
                        },
                        onFail: { (error) in
                            logoutPresetExpectation.fulfill()
                        }
        )
        self.waitForExpectations(timeout: loginTimeout) { (timeoutError) in }
        XCTAssert(loggedOut)
    }
    
    func testLoginSearchLogout() {
        let loginExpectation = self.expectation(description: "\(#function)\(#line)")
        var loggedIn = false
        Mustang().login(username: "derekk19",
                        password: "Fe62h2zj",
                        onSuccess: {
                            loginExpectation.fulfill()
                            loggedIn = true
                        },
                        onFail: { (error) in
                            loginExpectation.fulfill()
                        }
        )
        self.waitForExpectations(timeout: loginTimeout) { (timeoutError) in }
        XCTAssert(loggedIn)

        let searchExpectation = self.expectation(description: "\(#function)\(#line)")
        var actual: DTOSearchResponse? = nil
        Mustang().search(forTitle: "tom sawyer",
                         pageNumber: 1,
                         maxReturn: 10,
                         onSuccess: { (response) in
                            searchExpectation.fulfill()
                            actual = response
                         },
                         onFail: { (error) in
                            searchExpectation.fulfill()
                         }
        )
        self.waitForExpectations(timeout: searchTimeout) { (timeoutError) in }
        XCTAssertNotNil(actual)
        XCTAssertNotNil(actual?.pagination.total)
        XCTAssertEqual(actual?.pagination.limit, 10)
        XCTAssertNotNil(actual?.pagination.pages)
        XCTAssertNotNil(actual?.pagination.page)

        let logoutExpectation = self.expectation(description: "\(#function)\(#line)")
        var loggedOut = false
        Mustang().logout(onSuccess: {
                            logoutExpectation.fulfill()
                            loggedOut = true
                         },
                         onFail: { (error) in
                            logoutExpectation.fulfill()
                         }
        )
        self.waitForExpectations(timeout: loginTimeout) { (timeoutError) in }
        XCTAssert(loggedOut)
    }
    
    func testImportPreset() {
        let downloadPresetExpectation = self.expectation(description: "\(#function)\(#line)")
        var downloaded: DTOPreset? = nil

        let document = self.getFuseFile("M2_Preset1")
        XCTAssertNotNil(document)
        if document == nil { return }
        
        Mustang(mockMode: true).importPreset(document!) {
            (preset) in
            downloaded = preset
            downloadPresetExpectation.fulfill()
        }
        self.waitForExpectations(timeout: presetsTimeout) { (timeoutError) in }
        XCTAssertNotNil(downloaded)
        if let actual = downloaded {
            XCTAssertEqual(actual.name, "Preset1")
            XCTAssertEqual(actual.moduleName, "Metal 2000")
            XCTAssertEqual(actual.cabinetName, "2x15 Vintage")
            XCTAssertEqualWithAccuracy(actual.volume!, 8.0, accuracy: 0.1)
            XCTAssertEqualWithAccuracy(actual.gain1!, 4.0, accuracy: 0.1)
            XCTAssertEqualWithAccuracy(actual.gain2!, 5.5, accuracy: 0.1)
            XCTAssertEqualWithAccuracy(actual.treble!, 6.0, accuracy: 0.1)
            XCTAssertEqualWithAccuracy(actual.middle!, 6.0, accuracy: 0.1)
            XCTAssertEqualWithAccuracy(actual.bass!, 8.0, accuracy: 0.1)
            XCTAssertEqualWithAccuracy(actual.presence!, 5.5, accuracy: 0.1)
            let actualStp = actual.effects.filter({$0.type == .Stomp}).first
            XCTAssertNotNil(actualStp)
            XCTAssertEqual(actualStp?.name, "Overdrive")
            XCTAssertNotEqual(actualStp?.knobs.count, 0)
            let actualMod = actual.effects.filter({$0.type == .Modulation}).first
            XCTAssertNil(actualMod)
            XCTAssertNil(actualMod?.name)
            let actualDel = actual.effects.filter({$0.type == .Delay}).first
            XCTAssertNil(actualDel)
            XCTAssertNil(actualDel?.name)
            let actualRev = actual.effects.filter({$0.type == .Reverb}).first
            XCTAssertNotNil(actualRev)
            XCTAssertEqual(actualRev?.name, "Large Hall")
            XCTAssertNotEqual(actualRev?.knobs.count, 0)
        }
    }
    
    func testReplaceCancelPresetForSlot97() {
        let document = self.getFuseFile("M2_Preset1")
        XCTAssertNotNil(document)
        if document == nil { return }
        
        let amps = Mustang(mockMode: true).getConnectedAmplifiers()
        XCTAssertNotNil(amps)
        XCTAssertNotEqual(amps.count, 0)
        if amps.count > 0 {
            var vOriginal: DTOPreset? = nil
            let getPresetsExpectation = self.expectation(description: "\(#function)\(#line)")
            Mustang(mockMode: true).getPreset(amps[0], preset: 97) { (preset) in
                vOriginal = preset
                getPresetsExpectation.fulfill()
            }
            self.waitForExpectations(timeout: presetsTimeout) { (timeoutError) in }
            XCTAssertNotNil(vOriginal)
            print("Got")
            if let _ = vOriginal {
                let downloadPresetExpectation = self.expectation(description: "\(#function)\(#line)")
                var downloaded: DTOPreset? = nil
                Mustang(mockMode: true).importPreset(document!) {
                    (preset) in
                    downloaded = preset
                    downloadPresetExpectation.fulfill()
                }
                self.waitForExpectations(timeout: presetsTimeout) { (timeoutError) in }
                XCTAssertNotNil(downloaded)
                print("Downloaded")
                if downloaded != nil {
                    downloaded!.number = vOriginal!.number
                    let setPresetExpectation = self.expectation(description: "\(#function)\(#line)")
                    var changed: DTOPreset? = nil
                    Mustang(mockMode: true).setPreset(amps[0], preset: downloaded!) { (preset) in
                        changed = preset
                        setPresetExpectation.fulfill()
                    }
                    self.waitForExpectations(timeout: presetsTimeout) { (timeoutError) in }
                    XCTAssertNotNil(changed)
                    print("Changed")                    
                    vOriginal = nil
                    let resetPresetExpectation = self.expectation(description: "\(#function)\(#line)")
                    Mustang(mockMode: true).getPreset(amps[0], preset: 97, onCompletion: { (preset) in
                        vOriginal = preset
                        resetPresetExpectation.fulfill()
                    })
                    self.waitForExpectations(timeout: presetsTimeout) { (timeoutError) in }
                    XCTAssertNotNil(vOriginal)
                    print("Reset")
                }
            }
        }
    }
    
//    func testConnectAndDisconnectAmp() {
//        let connectExpectation = self.expectationWithDescription("testConnectAndDisconnectAmp")
//        print("----- Plug in and unplug the amplifier in the next \(connectTimeout) seconds")
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64((connectTimeout-1) * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) {
//            connectExpectation.fulfill()
//        }
//        Mustang().getConnectedAmplifiers(
//            didConnect: { (amplifier) in
//                connectExpectation.fulfill()
//            }, didDisconnect: { (amplifier) in
//                connectExpectation.fulfill()
//            }
//        )
//        self.waitForExpectationsWithTimeout(connectTimeout) { (timeoutError) in }
//    }
//    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    // Priovate functions
    fileprivate func getFuseFile(_ name: String) -> XMLDocument? {
        var document: XMLDocument? = nil
        if let path = Bundle(for: FileMockAgent.self).path(forResource: name, ofType: "fuse") {
            do {
                document = try XMLDocument(contentsOf: URL(fileURLWithPath: path), options: 0)
            }
            catch { }
        }
        return document
    }
}
