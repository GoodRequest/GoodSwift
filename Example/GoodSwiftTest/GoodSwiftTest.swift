//
//  GoodSwiftTest.swift
//  GoodSwiftTest
//
//  Created by Marek Spalek on 27/06/2017.
//
//

import XCTest
import Alamofire
import GoodSwift

let timeout: TimeInterval = 10

enum Endpoint {
    static let revision = "https://en.wikipedia.org/api/rest_v1/page/revision/"
    static let relatedPages = "https://en.wikipedia.org/api/rest_v1/page/related/Swift"
}

class GoodSwiftTest: XCTestCase {
    
    override func setUp() {
        super.setUp()
        
        DataRequest.logLevel = .verbose
    }
    
    func evaluate<T>(expectation: XCTestExpectation, result: Result<T>) {
        switch result {
        case .success(let value):
            print(value)
            expectation.fulfill()
        case .failure(let error):
            XCTFail(error.localizedDescription)
        }
    }
    
    func testRevision() {
        let exp = expectation(description: "Revision expectation")
        
        Alamofire.request(Endpoint.revision).unbox { (response: DataResponse<Revision>) in
            self.evaluate(expectation: exp, result: response.result)
        }
        waitForExpectations(timeout: timeout, handler: nil)
    }
    
    func testRelatedPages() {
        let exp = expectation(description: "Related pages expectation")
        
        Alamofire.request(Endpoint.relatedPages).unboxArray(keyPath: "pages") { (response: DataResponse<[Page]>) in
            self.evaluate(expectation: exp, result: response.result)
        }
        waitForExpectations(timeout: timeout, handler: nil)
    }
    
}
