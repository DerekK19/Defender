//
//  BOInfo.swift
//  Mustang
//
//  Created by Derek Knight on 27/12/16.
//  Copyright © 2016 Derek Knight. All rights reserved.
//

import Foundation

struct BOInfo: DTOInfo {
    
    var name: String
    var author: String
    var rating: Int
    var genre1: Int
    var genre2: Int
    var genre3: Int
    var tags: String
    var fenderid: Int

    init(dl: DLInfo) {
        self.name = dl.name
        self.author = dl.author
        self.rating = dl.rating
        self.genre1 = dl.genre1
        self.genre2 = dl.genre2
        self.genre3 = dl.genre3
        self.tags = dl.tags
        self.fenderid = dl.fenderid
    }
    
    static func convertArray(_ dls: [DLInfo]) -> [BOInfo] {
        return dls.map { BOInfo(dl: $0) }
    }
    
    var dataObject: DLInfo {
        return DLInfo(withName: name,
                      author: author,
                      rating: rating,
                      genre1: genre1,
                      genre2: genre2,
                      genre3: genre3,
                      tags: tags,
                      fenderid: fenderid)
    }
}
