//
//  DTOInfo.swift
//  Mustang
//
//  Created by Derek Knight on 27/12/16.
//  Copyright © 2016 Derek Knight. All rights reserved.
//

import Foundation

public protocol DTOInfo {
    var name: String {get set}
    var author: String {get set}
    var rating: Int {get set}
    var genre1: Int {get set}
    var genre2: Int {get set}
    var genre3: Int {get set}
    var tags: String {get set}
    var fenderid: Int {get set}
}
