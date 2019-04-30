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
    static let summary = "https://en.wikipedia.org/api/rest_v1/page/summary/Swift"
    static let relatedPages = "https://en.wikipedia.org/api/rest_v1/page/related/Swift"
    static let notFound = "https://en.wikipedia.org/api/rest_v1/notFound"
}

class GoodSwiftTest: XCTestCase {
    
    override func setUp() {
        super.setUp()
        
        DataRequest.logLevel = .verbose
    }
    
    func evaluate<T>(expectation: XCTestExpectation, result: AFResult<T>) {
        switch result {
        case .success(let value):
            print(value)
            expectation.fulfill()
        case .failure(let error):
            XCTFail(error.localizedDescription)
        }
    }
    
    func testSummary() {
        let exp = expectation(description: "Summary expectation")
        
        AF.request(Endpoint.summary).decode { (response: DataResponse<Page>) in
            self.evaluate(expectation: exp, result: response.result)
        }
        waitForExpectations(timeout: timeout, handler: nil)
    }
    
    func testRelatedPages() {
        let exp = expectation(description: "Related pages expectation")
        
        AF.request(Endpoint.relatedPages).decode(key: "pages") { (response: DataResponse<[Page]>) in
            self.evaluate(expectation: exp, result: response.result)
        }
        waitForExpectations(timeout: timeout, handler: nil)
    }
    
    func testWrongKeyPath() {
        let exp = expectation(description: "Wrong key path expectation")
        
        AF.request(Endpoint.relatedPages).decode(key: nil) { (response: DataResponse<[Page]>) in
            switch response.result {
            case .success(let value):
                print(value)
                XCTFail()
            case .failure(let error):
                if error is GoodSwiftError {
                    exp.fulfill()
                } else {
                    XCTFail(error.localizedDescription)
                }
            }
        }
        waitForExpectations(timeout: timeout, handler: nil)
    }
    
    func testNotFound() {
        let exp = expectation(description: "Not found (404) expectation")
        
        AF.request(Endpoint.notFound).decode { (response: DataResponse<Revision>) in
            switch response.result {
            case .success(let value):
                print(value)
                XCTFail()
            case .failure(let error):
                if response.response?.statusCode == 404 {
                    exp.fulfill()
                } else {
                    XCTFail(error.localizedDescription)
                }
            }
        }
        waitForExpectations(timeout: timeout, handler: nil)
    }
    
}
