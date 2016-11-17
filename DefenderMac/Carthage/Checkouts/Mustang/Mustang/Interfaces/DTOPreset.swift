//
//  DTOPreset.swift
//  Mustang
//
//  Created by Derek Knight on 6/08/16.
//  Copyright © 2016 Derek Knight. All rights reserved.
//

import Foundation

public protocol DTOPreset {
    var number: UInt8? { get set }
    var name: String { get set }
    var current: Bool  { get }
    var module: Int? { get set }
    var moduleName: String? { get }
    var volume: Float? { get set }
    var gain1: Float? { get set }
    var gain2: Float? { get set }
    var masterVolume: Float? { get set }
    var treble: Float? { get set }
    var middle: Float? { get set }
    var bass: Float? { get set }
    var presence: Float? { get set }
    var depth: Int? { get set }
    var bias: Int? { get set }
    var noiseGate: Int? { get set }
    var threshold: Int? { get set }
    var cabinet: Int? { get set }
    var cabinetName: String? { get set }
    var sag: Int? { get set }
    var brightness: Int? { get set }
    var unknown1: UInt8? { get }
    var unknown2: UInt8? { get }
    var unknown3: UInt8? { get }
    var unknown4: UInt8? { get }
    var unknown5: UInt8? { get }
    var unknown6: UInt8? { get }
    var unknown7: UInt8? { get }
    var unknown8: UInt8? { get }
    var effects: [DTOEffect] { get set }
}
