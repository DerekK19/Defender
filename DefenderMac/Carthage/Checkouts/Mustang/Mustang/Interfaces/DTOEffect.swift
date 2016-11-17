//
//  DTOEffect.swift
//  Mustang
//
//  Created by Derek Knight on 3/10/16.
//  Copyright © 2016 Derek Knight. All rights reserved.
//

import Foundation

public protocol DTOEffect {
    var type : DTOEffectType { get }
    var module: Int { get }
    var slot: Int { get set }
    var enabled: Bool { get set }
    var colour: Int { get set }
    var knobs: [DTOKnob] { get set }
    var name: String? { get }
    var knobCount: Int { get set }
    var aValue1: Int { get }
    var aValue2: Int { get }
    var aValue3: Int { get }
}
