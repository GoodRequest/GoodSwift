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
            response() { (response: DataResponse<Data?>) in
                print("")
                if let url = response.request?.url?.absoluteString.removingPercentEncoding, let method = response.request?.httpMethod {
                    if response.error == nil {
                        logInfo("🚀 \(method) \(url)")
                    } else {
                        logError("🚀 \(method) \(url)")
                    }
                }
                if let string = response.request?.httpBody?.jsonString, !string.isEmpty {
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
                if let string = response.data?.jsonString, !string.isEmpty {
                    logVerbose("📦 \(string)")
                }
                if let error = response.error as NSError? {
                    logError("‼️ [\(error.domain) \(error.code)] \(error.localizedDescription)")
                } else if let error = response.error {
                    logError("‼️ \(error)")
                }
            }
        #endif
        return self
    }
    
    /// Decode a JSON dictionary into a model `T`.
    ///
    /// - parameter completion: A closure to be executed once the request has finished.
    ///
    /// - returns: Self.
    @discardableResult
    public func decode<T: Decodable>(key: String? = nil, decoder: JSONDecoder = JSONDecoder(), completion: @escaping (DataResponse<T>) -> Void) -> Self {
        log()
        return responseData(completionHandler: { (response: DataResponse<Data>) in
            switch response.result {
            case .success(let value):
                if let httpResponse = response.response {
                    switch httpResponse.statusCode {
                    case 200 ..< 300:
                        do {
                            let item = try decodeData(value, for: key, decoder: decoder) as T
                            completion(response.response(withValue: item))
                        } catch let error {
                            logError("‼️ Error while decoding \(T.self)\n\(error)")
                            completion(response.response(withError: error))
                        }
                    default:
                        let error = GoodSwiftError(description: "‼️ code error \(httpResponse.statusCode)")
                        logError(error.description)
                        completion(response.response(withError: error))
                    }
                } else {
                    let error = GoodSwiftError(description: "‼️ Error while decoding \(T.self)")
                    logError(error.description)
                    completion(response.response(withError: error))
                }
            case .failure(let error):
                logError(error.localizedDescription)
                completion(response.response(withError: error))
            }
        })
    }
    
}

// MARK: - Private

extension DataResponse {
    
    func response<T>(withValue value: T) -> DataResponse<T> {
        return DataResponse<T>(request: request, response: response, data: data, metrics: nil, serializationDuration: 0, result: AFResult<T>.success(value))
    }
    
    func response<T>(withError error: Error) -> DataResponse<T> {
        return DataResponse<T>(request: request, response: response, data: data, metrics: nil, serializationDuration: 0, result: AFResult<T>.failure(error))
    }
    
}

func decodeData<T: Decodable>(_ value: Data, for key: String?, decoder: JSONDecoder) throws -> T {
    var item: T?
    
    do {
        if let key = key {
            let nestedItem = try decoder.decode([String: T].self, from: value)
            item = nestedItem[key]
        } else {
            item = try decoder.decode(T.self, from: value)
        }
    } catch {
        throw GoodSwiftError(description: "‼️ Decoding error: \(error)")
    }
    
    if let item = item {
        return item
    } else {
        throw GoodSwiftError(description: "‼️ Key \"\(key ?? "")\" is missing or not decodable.")
    }
}

// MARK: - Error

/// GoodSwift error.
public struct GoodSwiftError: Error, CustomStringConvertible {
    
    public let description: String
    
}
