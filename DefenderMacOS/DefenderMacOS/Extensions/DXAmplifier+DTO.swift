//
//  DXAmplifier+BO.swift
//  Defender
//
//  Created by Derek Knight on 17/11/16.
//  Copyright © 2016 Derek Knight. All rights reserved.
//

import Foundation

extension DXAmplifier {
    
    convenience init(dto: BOAmplifier) {
        self.init(name: dto.name, manufacturer: dto.manufacturer)
    }
    
}
