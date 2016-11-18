//
//  DXPreset+DTO.swift
//  Defender
//
//  Created by Derek Knight on 18/11/16.
//  Copyright © 2016 Derek Knight. All rights reserved.
//

import Foundation
import Mustang

extension DXPreset {
    
    convenience init(dto: DTOPreset) {
        self.init(name: dto.name)
    }
    
}
