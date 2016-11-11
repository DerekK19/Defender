//
//  PresetDocument.swift
//  Defender
//
//  Created by Derek Knight on 11/11/16.
//  Copyright © 2016 Derek Knight. All rights reserved.
//

import Cocoa
import Mustang

class PresetDocument : NSDocument {
    
    override func read(from data: Data, ofType typeName: String) throws {
        
        NSLog("readFromData \(typeName)")
        let zString = String(data: data, encoding: .ascii)
        NSLog("readFromData -> \(zString)")
    }
    
    override func data(ofType typeName: String) throws -> Data {
        NSLog("dataOfType \(typeName)")
        let zString = "The Owl and the Pussycat went to sea"
        let data = zString.data(using: .ascii, allowLossyConversion: false)
        return data!
    }
    
}
