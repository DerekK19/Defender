//
//  BOAudioDevice.swift
//  Mustang
//
//  Created by Derek Knight on 24/07/16.
//  Copyright © 2016 Derek Knight. All rights reserved.
//

import Foundation

struct BOAudioDevice {
    let manufacturer: String
    let name: String
    let deviceId: UInt32
    
    init(dl: DLAudioDevice) {
        self.manufacturer = dl.manufacturer
        self.name = dl.name
        self.deviceId = dl.deviceId
    }
    
    static func convertArray(_ dls: [DLAudioDevice]) -> [BOAudioDevice] {
        return dls.map { BOAudioDevice(dl: $0) }
    }
    
    var dataObject: DLAudioDevice {
        return DLAudioDevice(withManufacturer: self.manufacturer,
                           name: self.name,
                           deviceId: self.deviceId)
    }
}
