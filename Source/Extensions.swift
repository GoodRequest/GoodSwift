//
// Extensions.swift
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

import UIKit
import Alamofire
import Unbox

// MARK: - Alamofire

extension DataRequest {
    
    static let goodSwiftErrorDomain = "com.goodrequest.goodswift"
    
    /// Prints request and response information.
    ///
    /// - returns: Self.
    @discardableResult
    public func log() -> Self {
        response(completionHandler: { (response: DefaultDataResponse) in
            if let url = response.request?.url, let method = response.request?.httpMethod {
                print("🚀 \(method) \(url.absoluteString)")
            }
            if let body = response.request?.httpBody, let string = String(data: body, encoding: String.Encoding.utf8), string.characters.count > 0 {
                print("📦 \(string)")
            }
            if let response = response.response {
                switch response.statusCode {
                case 200 ..< 300:
                    print("✅ \(response.statusCode)")
                default:
                    print("❌ \(response.statusCode)")
                    break
                }
            }
            if let data = response.data, let string = String(data: data, encoding: String.Encoding.utf8), string.characters.count > 0 {
                print("📦 \(string)")
            }
            if let error = response.error as? NSError {
                print("‼️ [\(error.domain) \(error.code)] \(error.localizedDescription)")
            } else if let error = response.error {
                print("‼️ \(error)")
            }
            print("")
        })
        return self
    }
    
    @discardableResult
    public func unboxArray<T: Unboxable>(keyPath: String? = nil, allowInvalidElements: Bool = false, completion: @escaping (DataResponse<[T]>) -> Void) -> Self {
        
        return responseJSON(completionHandler: { (response: DataResponse<Any>) in
            switch response.result {
            case .success(let value):
                do {
                    var array: [T]?
                    if let keyPath = keyPath, let dictionary = value as? UnboxableDictionary {
                        array = try Unbox.unbox(dictionary: dictionary, atKeyPath: keyPath, allowInvalidElements: allowInvalidElements)
                    } else if let dictionaries = value as? [UnboxableDictionary] {
                        array = try Unbox.unbox(dictionaries: dictionaries, allowInvalidElements: allowInvalidElements)
                    }
                    if let array = array {
                        completion(DataResponse<[T]>(request: response.request, response: response.response, data: response.data, result: Result<[T]>.success(array)))
                    } else {
                        let error = NSError(domain: DataRequest.goodSwiftErrorDomain, code: 1, userInfo: nil)
                        print("‼️ Error while unboxing [\(T.self)]\n\(error)\n")
                        completion(DataResponse<[T]>(request: response.request, response: response.response, data: response.data, result: Result<[T]>.failure(error)))
                    }
                } catch let error {
                    print("‼️ Error while unboxing [\(T.self)]\n\(error)\n")
                    completion(DataResponse<[T]>(request: response.request, response: response.response, data: response.data, result: Result<[T]>.failure(error)))
                }
            case .failure(let error):
                completion(DataResponse<[T]>(request: response.request, response: response.response, data: response.data, result: Result<[T]>.failure(error)))
            }
        }).log()
    }
    
    @discardableResult
    public func unbox<T: Unboxable>(keyPath: String? = nil, completion: @escaping (DataResponse<T>) -> Void) -> Self {
        
        return responseJSON(completionHandler: { (response: DataResponse<Any>) in
            switch response.result {
            case .success(let value):
                do {
                    var item: T?
                    if let dictionary = value as? UnboxableDictionary {
                        if let keyPath = keyPath {
                            item = try Unbox.unbox(dictionary: dictionary, atKeyPath: keyPath) as T
                        } else {
                            item = try Unbox.unbox(dictionary: dictionary) as T
                        }
                    }
                    if let item = item {
                        completion(DataResponse<T>(request: response.request, response: response.response, data: response.data, result: Result<T>.success(item)))
                    } else {
                        let error = NSError(domain: DataRequest.goodSwiftErrorDomain, code: 1, userInfo: nil)
                        print("‼️ Error while unboxing \(T.self)\n\(error)\n")
                        completion(DataResponse<T>(request: response.request, response: response.response, data: response.data, result: Result<T>.failure(error)))
                    }
                } catch let error {
                    print("‼️ Error while unboxing \(T.self)\n\(error)\n")
                    completion(DataResponse<T>(request: response.request, response: response.response, data: response.data, result: Result<T>.failure(error)))
                }
            case .failure(let error):
                completion(DataResponse<T>(request: response.request, response: response.response, data: response.data, result: Result<T>.failure(error)))
            }
        }).log()
    }
    
}

// MARK: - UIKit

extension UIView {
    
    public enum Rotate {
        
        case by0, by90, by180, by270
        
        var rotationValue: Double {
            switch self {
            case .by0:
                return 0.0
            case .by90:
                return M_PI_2
            case .by180:
                return M_PI
            case .by270:
                return M_PI + M_PI_2
            }
        }
        
    }
    
    /// Rotates the view by specified angle.
    public func rotate(_ rotateBy: Rotate) {
        let superviewOfView = superview != nil ? superview! : self
        
        UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 1, initialSpringVelocity: 0.5, options: .beginFromCurrentState, animations: {
            self.transform = CGAffineTransform(rotationAngle: CGFloat(rotateBy.rotationValue))
            superviewOfView.layoutIfNeeded()
        }, completion: nil)
    }
    
}

extension UIStoryboard {
    
    /// Creates an instance of storyboard with specified class type.
    ///
    /// - returns: The new `Type` instance.
    public func instantiateViewController<T: UIViewController>(withClass clas: T.Type) -> T? {
        return instantiateViewController(withIdentifier: String(describing: clas)) as? T
    }
    
}

extension UITableView {
    
    /// Register header footer view with specified class type.
    public func registerHeaderFooterView<T: UITableViewHeaderFooterView>(fromClass type: T.Type) {
        register(UINib(nibName: String(describing: type), bundle: nil), forHeaderFooterViewReuseIdentifier: String(describing: type))
    }
    
    /// Dequeue reusable header footer view with specified class type.
    public func dequeueReusableHeaderFooterView<T: UITableViewHeaderFooterView>(fromClass type: T.Type) -> T? {
        return dequeueReusableHeaderFooterView(withIdentifier: String(describing: type)) as? T
    }
    
    /// Dequeue reusable cell with specified class type.
    public func dequeueReusableCell<T: UITableViewCell>(fromClass type: T.Type, for indexPath: IndexPath) -> T? {
        return dequeueReusableCell(withIdentifier: String(describing: type), for: indexPath) as? T
    }
    
}

extension UIColor {
    
    /// Creates an instance with specified RGBA values.
    ///
    /// - returns: The new `UIColor` instance.
    public class func color(rgb: Int, a: CGFloat = 1.0) -> UIColor {
        return UIColor.color(r: rgb, g: rgb, b: rgb, a: a)
    }
    
    /// Creates an instance with specified RGBA values.
    ///
    /// - returns: The new `UIColor` instance.
    public class func color(r: Int, g: Int, b: Int, a: CGFloat = 1.0) -> UIColor {
        return UIColor(red: CGFloat(r)/255.0, green: CGFloat(g)/255.0, blue: CGFloat(b)/255.0, alpha: a)
    }
    
}

// MARK: - Foundation

extension String {
    
    /// Returns localized String with given arguments.
    ///
    /// - returns: A localized String.
    public init(localized: String, arguments: CVarArg...) {
        self.init(format: NSLocalizedString(localized, comment: ""), arguments: arguments)
    }
    
    /// Returns localized String.
    ///
    /// - returns: A localized String.
    public init(localized: String) {
        self = NSLocalizedString(localized, comment: "")
    }
    
}

extension Array {
    
    /// Returns random item from array or nil if the array is empty.
    ///
    /// - returns: An Element or nil.
    public func randomItem() -> Element? {
        guard count > 0 else { return nil }
        return self[Int(arc4random_uniform(UInt32(count)))]
    }
    
    /// Returns true if array contains item with specified index, otherwise returns false.
    ///
    /// - returns: true or false whether the array contains specified index.
    public func contains(index: Int) -> Bool {
        return (startIndex..<endIndex).contains(index)
    }
    
}
