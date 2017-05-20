//
//  DTOBand.swift
//  Mustang
//
//  Created by Derek Knight on 28/12/16.
//  Copyright © 2016 Derek Knight. All rights reserved.
//

import Foundation

public protocol DTOBand {
    var type: Int { get set }
    var iRepeat: Int { get set }
    var audioMix: Int { get set }
    var balance: Int { get set }
    var speed: Int { get set }
    var pitch: Int { get set }
    var songFile: DTOSongFile? { get set }
}
