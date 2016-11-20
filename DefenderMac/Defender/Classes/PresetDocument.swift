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
    
    var document = XMLDocument()
    
    override func makeWindowControllers() {
        
        if let windowController = NSApplication.shared().mainWindow?.windowController {
            let vc = windowController.contentViewController as! MainVC
            vc.willImportPresetFromXml(document)
        }
    }
    
    override func read(from data: Data, ofType typeName: String) throws {
        
        do {
            document = try XMLDocument(data: data, options: 0)
        }
        catch {}

    }
    
    override func data(ofType typeName: String) throws -> Data {
        NSLog("dataOfType \(typeName)")
        let zString = "The Owl and the Pussycat went to sea"
        let data = zString.data(using: .utf8, allowLossyConversion: false)
        return data!
    }
    
}
