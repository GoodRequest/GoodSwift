//
//  GoodSwiftTest.swift
//  GoodSwiftTest
//
//  Created by Marek Spalek on 27/06/2017.
//
//

import XCTest
import Alamofire
@testable import GoodSwift

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
    
    func evaluate<T>(expectation: XCTestExpectation, result: Result<T, AFError>) {
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
        
        AF.request(Endpoint.summary).unbox() { (result: Result<Page, AFError>) in
            self.evaluate(expectation: exp, result: result)
        }
        waitForExpectations(timeout: timeout, handler: nil)
    }
    
    func testRelatedPages() {
        let exp = expectation(description: "Related pages expectation")
        
        AF.request(Endpoint.relatedPages).unboxArray(keyPath: "pages") { (result: Result<[Page], AFError>) in
            self.evaluate(expectation: exp, result: result)
        }
        waitForExpectations(timeout: timeout, handler: nil)
    }
    
    func testWrongKeyPath() {
        let exp = expectation(description: "Wrong key path expectation")
        
        AF.request(Endpoint.relatedPages).unboxArray(keyPath: nil) { (result: Result<[Page], AFError>) in
            switch result {
            case .success(let value):
                print(value)
                XCTFail()
            case .failure(let error):
                if error.isResponseSerializationError {
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
        
        AF.request(Endpoint.notFound).unbox { (result: Result<Revision, AFError>) in
            switch result {
            case .success(let value):
                print(value)
                XCTFail()
            case .failure(let error):
                if ((error.underlyingError as? GoodSwiftError) != nil) {
                    exp.fulfill()
                } else {
                    XCTFail(error.localizedDescription)
                }
            }
        }
        waitForExpectations(timeout: timeout, handler: nil)
    }
    
}
