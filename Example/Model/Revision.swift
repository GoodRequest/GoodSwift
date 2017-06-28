//
//  Revision.swift
//  GoodSwift
//
//  Created by Marek Spalek on 28/06/2017.
//
//

import Unbox

struct Revision {
    
    let items: [Int]
    let nextHref: String?
    
}

extension Revision: Unboxable {
    
    init(unboxer: Unboxer) throws {
        self.items      = try unboxer.unbox(key : "items")
        self.nextHref   = unboxer.unbox(key : "_links.next.href")
    }
    
}
