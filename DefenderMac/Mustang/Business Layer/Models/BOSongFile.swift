//
//  BOSongFile.swift
//  Mustang
//
//  Created by Derek Knight on 27/12/16.
//  Copyright © 2016 Derek Knight. All rights reserved.
//

import Foundation

struct BOSongFile: DTOSongFile {
    
    var location: Int
    var name: String?

    init(dl: DLSongFile) {
        self.location = dl.location
        self.name = dl.name
    }
    
    static func convertArray(_ dls: [DLSongFile]) -> [BOSongFile] {
        return dls.map { BOSongFile(dl: $0) }
    }
    
    var dataObject: DLSongFile {
        return DLSongFile(withLocation: location,
                          name: name)
    }
}
