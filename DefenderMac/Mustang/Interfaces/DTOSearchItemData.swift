//
//  DTOSearchItemData.swift
//  Mustang
//
//  Created by Derek Knight on 6/11/16.
//  Copyright © 2016 Derek Knight. All rights reserved.
//

import Foundation

public protocol DTOSearchItemData {
    var filename: String { get set }
    var preset: DTOPreset? { get set }
}
