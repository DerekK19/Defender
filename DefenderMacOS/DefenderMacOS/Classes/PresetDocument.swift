//
//  PresetDocument.swift
//  Defender
//
//  Created by Derek Knight on 11/11/16.
//  Copyright © 2016 Derek Knight. All rights reserved.
//

import Cocoa

class PresetDocument : NSDocument {
    
    var document = XMLDocument()
    
    override func makeWindowControllers() {
        
        if let windowController = NSApplication.shared.mainWindow?.windowController {
            addWindowController(windowController)
            let vc = windowController.contentViewController as! MainVC
            vc.willImportPresetFromXml(document)
        }
    }
    
    override func read(from data: Data, ofType typeName: String) throws {
        
        do {
            document = try XMLDocument(data: data, options: XMLNode.Options(rawValue: 0))
        }
        catch {}

    }
    
    override func data(ofType typeName: String) throws -> Data {
        if let vc = windowControllers.first?.contentViewController as? MainVC {
            if let xml = vc.exportPresetAsXml() {
                document = xml
            }
        }
        let data = document.xmlData(options: XMLNode.Options(rawValue: XMLNode.Options.RawValue(Int(XMLNode.Options.nodePrettyPrint.rawValue))))
        return data
    }
    
    override func save(_ sender: Any?) {
        ULog.debug("Save %@", sender as? String ?? "Unknown")
        super.save(sender)
    }
    
    override func saveAs(_ sender: Any?) {
        ULog.debug("Save as %@", sender as? String ?? "Unknown")
        super.saveAs(sender)
    }
}
