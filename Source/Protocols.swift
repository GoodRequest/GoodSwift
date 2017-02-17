//
//  Extensions.swift
//  GoodSwift
//
//  Created by Marek Spalek on 22/11/2016.
//  Copyright © 2017 GoodRequest. All rights reserved.
//

import ObjectMapper

public protocol ResponseMappable {
    
    associatedtype MappableType: Mappable
    
    init(from response: MappableType)
}
