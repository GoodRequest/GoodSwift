//
// AlamofireExtensions.swift
// GoodSwift
//
// Copyright (c) 2017 GoodRequest (https://goodrequest.com)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import Alamofire
import Unbox
import Foundation

/// Log level enum
///
/// error - prints only when error occurs
/// info - prints request url with response status and error when occurs
/// verbose - prints everything including request body and response object
public enum GoodSwiftLogLevel {
    case error, info, verbose
}

/// Functions for printing in each log level.
private func logError(_ text: String) {
    #if DEBUG
        print(text)
    #endif
}

private func logInfo(_ text: String) {
    #if DEBUG
        if DataRequest.logLevel != .error {
            print(text)
        }
    #endif
}

private func logVerbose(_ text: String) {
    #if DEBUG
        if DataRequest.logLevel == .verbose {
            print(text)
        }
    #endif
}

// MARK: - Alamofire

extension DataRequest {
    
    public static var logLevel = GoodSwiftLogLevel.info
    
    /// Prints request and response information.
    ///
    /// - returns: Self.
    @discardableResult
    public func log() -> Self {
        #if DEBUG
            response(completionHandler: { (response: DataResponse) in
                print("")
                if let url = response.request?.url?.absoluteString.removingPercentEncoding, let method = response.request?.httpMethod {
                    if response.error == nil {
                        logInfo("🚀 \(method) \(url)")
                    } else {
                        logError("🚀 \(method) \(url)")
                    }
                }
                if let body = response.request?.httpBody, let string = String(data: body, encoding: String.Encoding.utf8), string.count > 0 {
                    logVerbose("📦 \(string)")
                }
                if let response = response.response {
                    switch response.statusCode {
                    case 200 ..< 300:
                        logInfo("✅ \(response.statusCode)")
                    default:
                        logInfo("❌ \(response.statusCode)")
                        break
                    }
                }
                if let data = response.data, let string = String(data: data, encoding: String.Encoding.utf8), string.count > 0 {
                    logVerbose("📦 \(string)")
                }
                if let error = response.error as NSError? {
                    logError("‼️ [\(error.domain) \(error.code)] \(error.localizedDescription)")
                } else if let error = response.error {
                    logError("‼️ \(error)")
                }
            })
        #endif
        return self
    }
    
    /// Unbox an array of JSON dictionaries into an array of `T`, optionally allowing invalid elements.
    ///
    /// - parameter keyPath:                JSON keyPath of the array.
    /// - parameter allowInvalidElements:   Whether to allow invalid elements in array.
    /// - parameter completion:             A closure to be executed once the request has finished.
    ///
    /// - returns: Self.
    @discardableResult
    public func unboxArray<T: Unboxable>(keyPath: String? = nil, allowInvalidElements: Bool = false, completion: @escaping (Result<[T], AFError>) -> Void) -> Self {
        log()
        return responseJSON { response in
            switch response.result {
            case .success(let value):
                let statusCode = response.response?.statusCode ?? -1
                switch statusCode {
                case 200..<300:
                    do {
                        let array = try unboxItems(value, atKeyPath: keyPath, allowInvalidElements: allowInvalidElements) as [T]
                        completion(.success(array))
                    } catch let error {
                        logError("‼️ Error while unboxing [\(T.self)]\n\(error)")
                        completion(.failure(serializationAFError(error: error)))
                    }
                    
                default:
                    let error = GoodSwiftError(description: "‼️ Status code error \(statusCode)")
                    logError(error.description)
                    completion(.failure(serializationAFError(error: error)))
                }
                
            case .failure(let error):
                logError(error.localizedDescription)
                completion(.failure(error))
            }
        }
    }
    
    /// Unbox a JSON dictionary into a model `T` beginning at a certain key path.
    ///
    /// - parameter keyPath:                JSON keyPath of the model.
    /// - parameter completion:             A closure to be executed once the request has finished.
    ///
    /// - returns: Self.
    @discardableResult
    public func unbox<T: Unboxable>(keyPath: String? = nil, completion: @escaping (Result<T, AFError>) -> Void) -> Self {
        log()
        return responseJSON { response in
            switch response.result {
            case .success(let value):
                if let httpResponse = response.response {
                    switch httpResponse.statusCode {
                    case 200 ..< 300:
                        do {
                            let item = try unboxItem(value, atKeyPath: keyPath) as T
                            completion(.success(item))
                        } catch let error {
                            logError("‼️ Error while unboxing \(T.self)\n\(error)")
                            completion(.failure(serializationAFError(error: error)))
                        }
                    default:
                        let error = GoodSwiftError(description: "‼️ Status code error \(httpResponse.statusCode)")
                        logError(error.description)
                        completion(.failure(serializationAFError(error: error)))
                    }
                } else {
                    let error = GoodSwiftError(description: "‼️ Error while unboxing \(T.self)")
                    logError(error.description)
                    completion(.failure(serializationAFError(error: error)))
                }
            case .failure(let error):
                logError(error.localizedDescription)
                completion(.failure(error))
            }
        }
    }
    
}

func unboxItem<T: Unboxable>(_ value: Any, atKeyPath keyPath: String? = nil) throws -> T {
    var item: T?
    if let dictionary = value as? UnboxableDictionary {
        if let keyPath = keyPath {
            item = try Unbox.unbox(dictionary: dictionary, atKeyPath: keyPath) as T
        } else {
            item = try Unbox.unbox(dictionary: dictionary) as T
        }
    }
    if let item = item {
        return item
    } else {
        throw GoodSwiftError(description: "‼️ Path \"\(keyPath ?? "")\" is missing or not unboxable.")
    }
}

func unboxItems<T: Unboxable>(_ value: Any, atKeyPath keyPath: String? = nil, allowInvalidElements: Bool = false) throws -> [T] {
    var array: [T]?
    if let keyPath = keyPath, let dictionary = value as? UnboxableDictionary {
        array = try Unbox.unbox(dictionary: dictionary, atKeyPath: keyPath, allowInvalidElements: allowInvalidElements)
    } else if let dictionaries = value as? [UnboxableDictionary] {
        array = try Unbox.unbox(dictionaries: dictionaries, allowInvalidElements: allowInvalidElements)
    }
    if let array = array {
        return array
    } else {
        throw GoodSwiftError(description: "‼️ Path \"\(keyPath ?? "")\" is missing or not unboxable.")
    }
}

fileprivate func serializationAFError(error: Error) -> AFError {
    AFError.responseSerializationFailed(reason: .customSerializationFailed(error: error))
}

// MARK: - Error

/// GoodSwift error.
public struct GoodSwiftError: Error, CustomStringConvertible {
    
    public let description: String
    
}
