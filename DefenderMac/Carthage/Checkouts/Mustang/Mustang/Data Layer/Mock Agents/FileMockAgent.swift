//
//  FileMockAgent.swift
//  Mustang
//
//  Created by Derek Knight on 1/11/16.
//  Copyright © 2016 Derek Knight. All rights reserved.
//

import Foundation

class FileMockAgent : NSObject, FileServiceAgentProtocol {
    
    func importPresetWithXml(_ xml: XMLDocument, onSuccess: @escaping (DLPreset) -> (), onFail: @escaping () -> ()) {
        do {
            let preset = try DLPreset(xml: xml)
            onSuccess(preset)
        }
        catch {
            onFail()
        }
    }

    func exportPresetAsXml(_ preset: DLPreset, onSuccess: @escaping (_ xml: XMLDocument) -> (), onFail: @escaping () -> ()) {
        onFail()
    }
    
}

extension XMLNode {
    var intValue: Int? {
        get {
            if let str = stringValue {
                return Int(str)
            }
            return nil
        }
    }
}
