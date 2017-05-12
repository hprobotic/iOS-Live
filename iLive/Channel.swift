//
//  Channel.swift
//  iLive
//
//  Created by JohnP on 5/12/17.
//  Copyright © 2017 JohnP. All rights reserved.
//

import Foundation

struct Channel {
    
    var key: String
    var title: String
    
    init(dict: [String: AnyObject]) {
        title = dict["title"] as! String
        key = dict["key"] as! String
    }
    
    func toDict() -> [String: AnyObject] {
        return [
            "title": title as AnyObject,
            "key": key as AnyObject
        ]
    }
}
