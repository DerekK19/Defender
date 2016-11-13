//
//  RemoteManager.swift
//  Defender
//
//  Created by Derek Knight on 13/11/16.
//  Copyright © 2016 Derek Knight. All rights reserved.
//

import Foundation
import RemoteDefender

class RemoteManager {
    
    let peripheral = Peripheral()
    
    init() {
        peripheral.start()
    }
    
    deinit {
        peripheral.stop()
    }
    
}

