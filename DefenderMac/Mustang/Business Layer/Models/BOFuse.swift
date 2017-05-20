//
//  BOFuse.swift
//  Mustang
//
//  Created by Derek Knight on 27/12/16.
//  Copyright © 2016 Derek Knight. All rights reserved.
//

import Foundation

struct BOFuse: DTOFuse {
    
    var info: DTOInfo?
    
    private var _info: BOInfo?
    
    init(dl: DLFuse) {
        if let dlInfo = dl.info {
            self._info = BOInfo(dl: dlInfo)
            self.info = BOInfo(dl: dlInfo)
        }
    }
    
    var dataObject: DLFuse {
        return DLFuse(withInfo: _info?.dataObject)
    }
    
}
