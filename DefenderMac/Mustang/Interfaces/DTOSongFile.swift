//
//  DTOSongFile.swift
//  Mustang
//
//  Created by Derek Knight on 27/12/16.
//  Copyright © 2016 Derek Knight. All rights reserved.
//

import Foundation

public protocol DTOSongFile {
    
    var location: Int { get set }
    var name: String? { get set }
}
