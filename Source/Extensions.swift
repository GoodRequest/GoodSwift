//
//  Extensions.swift
//  GoodSwift
//
//  Created by Marek Spalek on 22/11/2016.
//  Copyright © 2017 GoodRequest. All rights reserved.
//

import Alamofire
import AlamofireObjectMapper
import ObjectMapper

// MARK: - Alamofire

extension DataRequest {
    
    @discardableResult
    public func log() -> Self {
        response(completionHandler: { (response: DefaultDataResponse) in
            if let url = response.request?.url {
                print("🚀 \(url.absoluteString)")
            }
            if let response = response.response {
                switch response.statusCode {
                case 200 ..< 300:
                    print("✅ \(response.statusCode)")
                default:
                    print("⁉️ \(response.statusCode)")
                    break
                }
            }
            if let data = response.data, let string = String(data: data, encoding: String.Encoding.utf8) {
                print("📦 \(string)")
            }
            if let error = response.error {
                print("‼️ \(error)")
            }
            print("")
        })
        return self
    }
    
    @discardableResult
    public func objectArray<T: ResponseMappable>(queue: DispatchQueue? = nil, keyPath: String? = nil, context: MapContext? = nil, completion: @escaping (DataResponse<[T]>) -> Void) -> Self {
        return responseArray(queue: queue, keyPath: keyPath, completionHandler: { (response: DataResponse<[T.MappableType]>) in
            switch response.result {
            case .success(let value):
                completion(DataResponse<[T]>(request: response.request, response: response.response, data: response.data, result: Result<[T]>.success(value.map { T(from: $0) } )))
            case .failure(let error):
                completion(DataResponse<[T]>(request: response.request, response: response.response, data: response.data, result: Result<[T]>.failure(error)))
            }
        })
    }
    
    @discardableResult
    public func object<T : ResponseMappable>(queue: DispatchQueue? = nil, keyPath: String? = nil, mapToObject object: T? = nil, context: MapContext? = nil, completion: @escaping (DataResponse<T>) -> Void) -> Self {
        return responseObject(queue: queue, keyPath: keyPath, mapToObject: nil, context: context, completionHandler: { (response: DataResponse<T.MappableType>) in
            switch response.result {
            case .success(let value):
                completion(DataResponse<T>(request: response.request, response: response.response, data: response.data, result: Result<T>.success(T.init(from: value))))
            case .failure(let error):
                completion(DataResponse<T>(request: response.request, response: response.response, data: response.data, result: Result<T>.failure(error)))
            }
        })
    }
    
}

// MARK: - UIKit

extension UIView {
    
    enum Rotate {
        
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
    
    func rotate(_ rotateBy: Rotate) {
        let superviewOfView = superview != nil ? superview! : self
        
        UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 1, initialSpringVelocity: 0.5, options: .beginFromCurrentState, animations: {
            self.transform = CGAffineTransform(rotationAngle: CGFloat(rotateBy.rotationValue))
            superviewOfView.layoutIfNeeded()
        }, completion: nil)
    }
    
}

extension UIStoryboard {
    
    func instantiateViewController<T: UIViewController>(withClass clas: T.Type) -> T? {
        return instantiateViewController(withIdentifier: String(describing: clas)) as? T
    }
    
}

extension UITableView {
    
    func registerHeaderFooterView<T: UITableViewHeaderFooterView>(fromClass type: T.Type) {
        register(UINib(nibName: String(describing: type), bundle: nil), forHeaderFooterViewReuseIdentifier: String(describing: type))
    }
    
    func dequeueReusableHeaderFooterView<T: UITableViewHeaderFooterView>(fromClass type: T.Type) -> T? {
        return dequeueReusableHeaderFooterView(withIdentifier: String(describing: type)) as? T
    }
    
    func dequeueReusableCell<T: UITableViewCell>(fromClass type: T.Type, for indexPath: IndexPath) -> T? {
        return dequeueReusableCell(withIdentifier: String(describing: type), for: indexPath) as? T
    }
    
}

extension UIColor {
    
    class func color(rgb: Int, a: CGFloat = 1.0) -> UIColor {
        return UIColor.color(r: rgb, g: rgb, b: rgb, a: a)
    }
    
    class func color(r: Int, g: Int, b: Int, a: CGFloat = 1.0) -> UIColor {
        return UIColor(red: CGFloat(r)/255.0, green: CGFloat(g)/255.0, blue: CGFloat(b)/255.0, alpha: a)
    }
    
}

// MARK: - Foundation

extension String {
    
    init(localized: String, arguments: CVarArg...) {
        self.init(format: NSLocalizedString(localized, comment: ""), arguments: arguments)
    }
    
    init(localized: String) {
        self = NSLocalizedString(localized, comment: "")
    }
    
}

extension Array {
    
    func randomItem() -> Element? {
        guard count > 0 else { return nil }
        return self[Int(arc4random_uniform(UInt32(count)))]
    }
    
    func contains(index: Int) -> Bool {
        return (startIndex..<endIndex).contains(index)
    }
    
}
