//
//  Dictionary+merge.swift
//  Mustang
//
//  Created by Derek Knight on 5/11/16.
//  Copyright © 2016 Derek Knight. All rights reserved.
//

import Foundation

extension Dictionary {
    
    mutating func merge(with dictionary: Dictionary) {
        dictionary.forEach { updateValue($1, forKey: $0) }
    }
    
    func merged(with dictionary: Dictionary) -> Dictionary {
        var dict = self
        dict.merge(with: dictionary)
        return dict
    }
}
