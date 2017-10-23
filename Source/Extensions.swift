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

/// Log level enum
///
/// error - prints only when error occurs
/// info - prints request url with response status and error when occurs
/// verbose - prints everything including request body and response object
public enum GoodSwiftLogLevel {
    case    error,
            info,
            verbose
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
    
    open static var logLevel = GoodSwiftLogLevel.info
    
    /// Prints request and response information.
    ///
    /// - returns: Self.
    @discardableResult
    public func log() -> Self {
        #if DEBUG
            response(completionHandler: { (response: DefaultDataResponse) in
                print("")
                if let url = response.request?.url?.absoluteString.removingPercentEncoding, let method = response.request?.httpMethod {
                    if response.error == nil {
                        logInfo("🚀 \(method) \(url)")
                    } else {
                        logError("🚀 \(method) \(url)")
                    }
                }
                if let body = response.request?.httpBody, let string = String(data: body, encoding: String.Encoding.utf8), string.characters.count > 0 {
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
                if let data = response.data, let string = String(data: data, encoding: String.Encoding.utf8), string.characters.count > 0 {
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
    public func unboxArray<T: Unboxable>(keyPath: String? = nil, allowInvalidElements: Bool = false, completion: @escaping (DataResponse<[T]>) -> Void) -> Self {
        log()
        
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
                        let error = GoodSwiftError(description: "‼️ Error while unboxing [\(T.self)]")
                        logError(error.description)
                        completion(DataResponse<[T]>(request: response.request, response: response.response, data: response.data, result: Result<[T]>.failure(error)))
                    }
                } catch let error {
                    logError("‼️ Error while unboxing [\(T.self)]\n\(error)")
                    completion(DataResponse<[T]>(request: response.request, response: response.response, data: response.data, result: Result<[T]>.failure(error)))
                }
            case .failure(let error):
                completion(DataResponse<[T]>(request: response.request, response: response.response, data: response.data, result: Result<[T]>.failure(error)))
            }
        })
    }
    
    /// Unbox a JSON dictionary into a model `T` beginning at a certain key path.
    ///
    /// - parameter keyPath:                JSON keyPath of the model.
    /// - parameter completion:             A closure to be executed once the request has finished.
    ///
    /// - returns: Self.
    @discardableResult
    public func unbox<T: Unboxable>(keyPath: String? = nil, completion: @escaping (DataResponse<T>) -> Void) -> Self {
        log()
        
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
                        let error = GoodSwiftError(description: "‼️ Error while unboxing \(T.self)")
                        logError(error.description)
                        completion(DataResponse<T>(request: response.request, response: response.response, data: response.data, result: Result<T>.failure(error)))
                    }
                } catch let error {
                    logError("‼️ Error while unboxing \(T.self)\n\(error)")
                    completion(DataResponse<T>(request: response.request, response: response.response, data: response.data, result: Result<T>.failure(error)))
                }
            case .failure(let error):
                completion(DataResponse<T>(request: response.request, response: response.response, data: response.data, result: Result<T>.failure(error)))
            }
        })
    }
    
}

// MARK: - Error

/// GoodSwift error.
public struct GoodSwiftError: Error, CustomStringConvertible {
    
    public let description: String
    
}

// MARK: - UIKit

extension UIView {
    
    /// View corner radius. Don't forget to set clipsToBounds = true
    @IBInspectable public var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        } set {
            layer.cornerRadius = newValue
        }
    }
    
    /// View border color
    @IBInspectable public var borderColor: UIColor {
        get {
            return UIColor(cgColor: layer.borderColor ?? UIColor.black.cgColor)
        } set {
            layer.borderColor = newValue.cgColor
        }
    }
    
    /// View border width
    @IBInspectable public var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        } set {
            layer.borderWidth = newValue
        }
    }
    
    /// Animates shake with view
    public func shakeView(duration: CFTimeInterval = 0.02, repeatCount: Float = 8.0, offset: CGFloat = 5.0) {
        let animation = CABasicAnimation(keyPath: "position")
        animation.duration = duration
        animation.repeatCount = repeatCount
        animation.autoreverses = true
        animation.fromValue = NSValue(cgPoint: CGPoint(x: center.x - offset, y: center.y))
        animation.toValue = NSValue(cgPoint: CGPoint(x: center.x + offset, y: center.y))
        layer.add(animation, forKey: "position")
    }
    
    public enum Rotate {
        
        case by0, by90, by180, by270
        
        var rotationValue: Double {
            switch self {
            case .by0:
                return 0.0
            case .by90:
                return .pi / 2
            case .by180:
                return .pi
            case .by270:
                return .pi + .pi / 2
            }
        }
        
    }
    
    /// Rotates the view by specified angle.
    public func rotate(_ rotateBy: Rotate) {
        UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 1, initialSpringVelocity: 0.5, options: .beginFromCurrentState, animations: {
            self.transform = CGAffineTransform(rotationAngle: CGFloat(rotateBy.rotationValue))
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

extension UICollectionView {
    
    /// Register reusable supplementary view with specified class type.
    public func register<T: UICollectionReusableView>(viewClass type: T.Type, forSupplementaryViewOfKind: String = UICollectionElementKindSectionHeader) {
        return register(UINib(nibName: String(describing: type), bundle: nil), forSupplementaryViewOfKind: forSupplementaryViewOfKind, withReuseIdentifier: String(describing: type))
    }
    
    /// Dequeue reusable supplementary view with specified class type.
    public func dequeueReusableSupplementaryView<T: UICollectionReusableView>(ofKind kind: String, fromClass type: T.Type, for indexPath: IndexPath) -> T {
        return dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: String(describing: type), for: indexPath) as! T
    }
    
    /// Dequeue reusable cell with specified class type.
    public func dequeueReusableCell<T: UICollectionViewCell>(fromClass type: T.Type, for indexPath: IndexPath) -> T {
        return dequeueReusableCell(withReuseIdentifier: String(describing: type), for: indexPath) as! T
    }
    
}

extension UITableView {
    
    /// Register reusable cell with specified class type.
    func registerCell<T: UITableViewCell>(fromClass type: T.Type)  {
        register(UINib(nibName: String(describing: type), bundle: nil), forCellReuseIdentifier: String(describing: type))
    }
    
    /// Register reusable header footer view with specified class type.
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
    
    /// Return localized String from current string.
    /// - returns: A localized String.
    ///Usage: "someString".localized
    
    var localized: String {
        return NSLocalizedString(self, comment: "")
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

extension DispatchQueue {
    
    /// Asyncs after closure
    ///
    /// - parameter seconds: Time to dispatch after in seconds
    /// - parameter handler: Closure to execute after given time
    public func asyncAfter(seconds: TimeInterval, handler: @escaping () -> Void) {
        let deadline = DispatchTime.now() + DispatchTimeInterval.milliseconds(Int(Double(seconds * 1000)))
        asyncAfter(deadline: deadline, execute: handler)
    }
    
}

extension Sequence where Iterator.Element == String? {
    
    /// Joins sequence of strings into one string with given separator
    ///
    /// - parameter separator: Separator between each two elements in sequence
    public func joined(withSeparator separator: String) -> String {
        return filter { $0 != nil && $0!.characters.count > 0 }
            .map { $0! }
            .joined(separator: separator)
    }
    
}
