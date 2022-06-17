//
//  Page.swift
//  GoodSwift
//
//  Created by Marek Spalek on 28/06/2017.
//
//

import Unbox
import Foundation

struct Page {
    
    let id: Int
    let title: String
    let extract: String
    let thumbnail: Image?
    
}

extension Page: Unboxable {
    
    init(unboxer: Unboxer) throws {
        self.id         = try unboxer.unbox(key : "pageid")
        self.title      = try unboxer.unbox(key : "title")
        self.extract    = try unboxer.unbox(key : "extract")
        self.thumbnail  = unboxer.unbox(key : "thumbnail")
    }
    
}

struct Image {
    
    let source: URL
    let width: Int
    let height: Int
    
}

extension Image: Unboxable {
    
    init(unboxer: Unboxer) throws {
        self.source = try unboxer.unbox(key : "source")
        self.width  = try unboxer.unbox(key : "width")
        self.height = try unboxer.unbox(key : "height")
    }
    
}
