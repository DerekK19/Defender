//
//  BOSearchItemData.swift
//  Mustang
//
//  Created by Derek Knight on 6/11/16.
//  Copyright © 2016 Derek Knight. All rights reserved.
//

import Foundation

struct BOSearchItemData: DTOSearchItemData {
    
    var filename: String
    var preset: DTOPreset?
    
    private let _preset: BOPreset?
    
    init (dl: DLSearchItemData) {
        filename = dl.filename
        if let preset = dl.preset {
            self._preset = BOPreset(dl: preset)
            self.preset = self._preset
        } else {
            preset = nil
            _preset = nil
        }
    }
    
    var dataObject: DLSearchItemData? {
        if let dataObject = _preset?.dataObject {
            return DLSearchItemData(withFilename: filename, preset: dataObject)
        }
        return nil
    }
    
    static func convertArray(_ dls: [DLSearchItemData]) -> [BOSearchItemData] {
        return dls.map { BOSearchItemData(dl: $0) }
    }
    
}
