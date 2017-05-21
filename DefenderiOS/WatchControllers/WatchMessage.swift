//
//  WatchMessage.swift
//  DefenderApp
//
//  Created by Derek Knight on 4/02/17.
//  Copyright © 2017 Derek Knight. All rights reserved.
//

import Foundation

enum WatchMessage: String {
    case hello = "HELLO"
    case active = "ACTIVE"
    case inactive = "INACTIVE"
    case connect = "CONNECT"
    case disconnect = "DISCONNECT"
    case amplifier = "AMPLIFIER"
    case preset = "PRESET"
    case presets = "PRESETS"
    case message = "MESSAGE"
    case log = "LOG"
    case unknown = "UNKNOWN"
}
