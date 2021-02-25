//
//  Page.swift
//  GoodSwift
//
//  Created by Marek Spalek on 28/06/2017.
//
//

import Foundation

struct Page: Codable {
    
    let id: Int
    let title: String
    let extract: String
    let thumbnail: Image?
    
    enum CodingKeys: String, CodingKey {
        case id = "pageid"
        case title, extract, thumbnail
    }
    
}

struct Image: Codable {
    
    let source: URL
    let width: Int
    let height: Int
    
}
