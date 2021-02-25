//
//  Revision.swift
//  GoodSwift
//
//  Created by Marek Spalek on 28/06/2017.
//
//

import Foundation

struct Revision: Codable {
    
    let items: [Int]
    let nextHref: String?
    
    enum CodingKeys: String, CodingKey {
        case items
        case nextHref = "_links.next.href"
    }
    
}
