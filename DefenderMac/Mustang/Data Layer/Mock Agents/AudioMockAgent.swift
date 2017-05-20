//
//  AudioMockAgent.swift
//  Mustang
//
//  Created by Derek Knight on 11/10/16.
//  Copyright © 2016 Derek Knight. All rights reserved.
//

import Foundation

private let FenderManufacturer: String = "FMIC"
private let MustangName: String = "Mockstang III"

internal class AudioMockAgent: AudioServiceAgentProtocol {
 
    func getDevices() -> [DLAudioDevice] {
        return [DLAudioDevice(withManufacturer: FenderManufacturer, name: MustangName, deviceId: 1234)]
    }
    
}
