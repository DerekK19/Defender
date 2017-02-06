//
//  DataManager.swift
//  DefenderApp
//
//  Created by Derek Knight on 5/02/17.
//  Copyright © 2017 Derek Knight. All rights reserved.
//

import Foundation


class DataManager {

    static var instance = DataManager()

    var presets = [String]()
    var currentPreset = ""
    var chosenPreset: UInt8? = nil

}
