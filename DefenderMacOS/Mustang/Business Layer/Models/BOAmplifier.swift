//
//  BOAmplifier.swift
//  Mustang
//
//  Created by Derek Knight on 26/06/16.
//  Copyright © 2016 Derek Knight. All rights reserved.
//

import Foundation

struct BOAmplifier {
    let vendor: Int
    let product: Int
    let name: String
    let location: UInt32
    let manufacturer: String
    let device: UInt32
    
    init(dl: DLAmplifier) {
        self.vendor = dl.vendorId
        self.product = dl.productId
        self.manufacturer = dl.manufacturer
        self.name = dl.product
        self.location = dl.locationId
        self.device = dl.deviceId
    }
    
    static func convertArray(usb: [DLUSBDevice], hid: [DLHIDDevice], audio: [DLAudioDevice]) -> [BOAmplifier] {
        var rValue = [BOAmplifier]()
        if usb.count == audio.count && usb.count == hid.count {
            for i in 0..<usb.count {
                rValue.append(BOAmplifier(dl: DLAmplifier(usb: usb[i], hid: hid[i], audio: audio[i])))
            }
        } else if audio.count == 0 && hid.count == 0 {
            for i in 0..<usb.count {
                rValue.append(BOAmplifier(dl: DLAmplifier(usb: usb[i], hid: nil, audio: nil)))
            }
        } else if usb.count == hid.count && audio.count == 0 {
            for i in 0..<usb.count {
                rValue.append(BOAmplifier(dl: DLAmplifier(usb: usb[i], hid: hid[i], audio: nil)))
            }
        } else if usb.count == audio.count && hid.count == 0 {
            for i in 0..<usb.count {
                rValue.append(BOAmplifier(dl: DLAmplifier(usb: usb[i], hid: nil, audio: audio[i])))
            }
        }
        return rValue
    }
    
    var dataObject: DLAmplifier {
        return DLAmplifier(withVendorId: vendor,
                           productId: product,
                           manufacturer: manufacturer,
                           product: name,
                           locationId: location,
                           deviceId: device)
    }
}
