//
//  DXAmplifier+DTO.swift
//  Defender
//
//  Created by Derek Knight on 17/11/16.
//  Copyright © 2016 Derek Knight. All rights reserved.
//

import Foundation

extension DXAmplifier {
    
    convenience init(dto: DTOAmplifier) {
        self.init(name: dto.name, manufacturer: dto.manufacturer)
    }
    
}
