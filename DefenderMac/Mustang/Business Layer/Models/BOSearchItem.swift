//
//  BOSearchItem.swift
//  Mustang
//
//  Created by Derek Knight on 6/11/16.
//  Copyright © 2016 Derek Knight. All rights reserved.
//

import Foundation

struct BOSearchItem : DTOSearchItem {
    
    var id: String
    var title: String
    var data: DTOSearchItemData?
    
    private let _data: BOSearchItemData?
    
    init (dl: DLSearchItem) {
        id = dl.id
        title = dl.title
        _data = BOSearchItemData(dl: dl.data)
        data = _data
    }
    
    var dataObject: DLSearchItem? {
        if let dataObject = _data?.dataObject {
            return DLSearchItem(withId: id, title: title, data: dataObject)
        }
        return nil
    }
    
    static func convertArray(_ dls: [DLSearchItem]) -> [BOSearchItem] {
        return dls.map { BOSearchItem(dl: $0) }
    }
    
}
