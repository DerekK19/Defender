//
//  BOAmplifier.swift
//  Mustang
//
//  Created by Derek Knight on 26/06/16.
//  Copyright © 2016 Derek Knight. All rights reserved.
//

import Foundation

struct BOAmplifier: DTOAmplifier {
    let vendor: Int
    let product: Int
    let name: String
    let location: UInt32
    let manufacturer: String
    let device: UInt32
    
    init(usb: DLUSBDevice, hid: DLHIDDevice?, audio: DLAudioDevice?) {
        self.vendor = usb.vendor
        self.product = usb.product
        self.manufacturer = audio?.manufacturer ?? ""
        self.name = usb.name
        self.location = usb.locationId
        self.device = audio?.deviceId ?? 0
    }
    
    static func convertArray(usb: [DLUSBDevice], hid: [DLHIDDevice], audio: [DLAudioDevice]) -> [BOAmplifier] {
        var rValue = [BOAmplifier]()
        if usb.count == audio.count && usb.count == hid.count {
            for i in 0..<usb.count {
                rValue.append(BOAmplifier(usb: usb[i], hid: hid[i], audio: audio[i]))
            }
        } else if audio.count == 0 && hid.count == 0 {
            for i in 0..<usb.count {
                rValue.append(BOAmplifier(usb: usb[i], hid: nil, audio: nil))
            }
        } else if usb.count == hid.count && audio.count == 0 {
            for i in 0..<usb.count {
                rValue.append(BOAmplifier(usb: usb[i], hid: hid[i], audio: nil))
            }
        } else if usb.count == audio.count && hid.count == 0 {
            for i in 0..<usb.count {
                rValue.append(BOAmplifier(usb: usb[i], hid: nil, audio: audio[i]))
            }
        }
        return rValue
    }
    
}
