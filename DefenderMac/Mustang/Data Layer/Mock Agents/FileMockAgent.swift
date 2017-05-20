//
//  FileMockAgent.swift
//  Mustang
//
//  Created by Derek Knight on 1/11/16.
//  Copyright © 2016 Derek Knight. All rights reserved.
//

import Foundation

class FileMockAgent : NSObject, FileServiceAgentProtocol {
    
    func importPresetWithXml(_ xml: XMLDocument) -> DLPreset? {
        do {
            let preset = try DLPreset(xml: xml)
            return preset
        }
        catch {
            return nil
        }
    }

    func exportPresetAsXml(_ preset: DLPreset) -> XMLDocument {
        let xml = preset.xml()
        return xml
    }
}
