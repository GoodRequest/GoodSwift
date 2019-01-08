//
// UIKitExtensions.swift
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
    
    /// View's layer masks to bounds
    @IBInspectable public var masksToBounds: Bool {
        get {
            return layer.masksToBounds
        } set {
            layer.masksToBounds = newValue
        }
    }
    
    /// View shadow opacity
    @IBInspectable public var shadowOpacity: Float {
        get {
            return layer.shadowOpacity
        } set {
            layer.shadowOpacity = newValue
        }
    }
    
    /// View shadow color
    @IBInspectable public var shadowColor: UIColor {
        get {
            return UIColor(cgColor: layer.shadowColor ?? UIColor.black.cgColor)
        } set {
            layer.shadowColor = newValue.cgColor
        }
    }
    
    /// View shadow radius
    @IBInspectable public var shadowRadius: CGFloat {
        get {
            return layer.shadowRadius
        } set {
            layer.shadowRadius = newValue
        }
    }
    
    /// View shadow offset
    @IBInspectable public var shadowOffset: CGSize {
        get {
            return layer.shadowOffset
        } set {
            layer.shadowOffset = newValue
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
    
    /// Register reusable cell with specified class type.
    public func registerCell<T: UICollectionViewCell>(fromClass type: T.Type)  {
        register(UINib(nibName: String(describing: type), bundle: nil), forCellWithReuseIdentifier: String(describing: type))
    }
    
    /// Register reusable supplementary view with specified class type.
    public func register<T: UICollectionReusableView>(viewClass type: T.Type, forSupplementaryViewOfKind: String = UICollectionView.elementKindSectionHeader) {
        register(UINib(nibName: String(describing: type), bundle: nil), forSupplementaryViewOfKind: forSupplementaryViewOfKind, withReuseIdentifier: String(describing: type))
    }
    
    /// Dequeue reusable supplementary view with specified class type.
    public func dequeueReusableSupplementaryView<T: UICollectionReusableView>(ofKind kind: String, fromClass type: T.Type, for indexPath: IndexPath) -> T {
        return dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: String(describing: type), for: indexPath) as! T
    }
    
    /// Dequeue reusable cell with specified class type.
    public func dequeueReusableCell<T: UICollectionViewCell>(fromClass type: T.Type, for indexPath: IndexPath) -> T {
        return dequeueReusableCell(withReuseIdentifier: String(describing: type), for: indexPath) as! T
    }
    
    /// Deselect first selected item along UIViewController`s transition coordinator.
    public func deselectSelectedItem(along transitionCoordinator: UIViewControllerTransitionCoordinator?) {
        guard let selectedIndexPath = indexPathsForSelectedItems?.first else { return }
        
        guard let coordinator = transitionCoordinator else {
            deselectItem(at: selectedIndexPath, animated: false)
            return
        }
        
        coordinator.animate(alongsideTransition: { _ in
            self.deselectItem(at: selectedIndexPath, animated: true)
        }) { [weak self] (context) in
            if context.isCancelled {
                self?.selectItem(at: selectedIndexPath, animated: false, scrollPosition: UICollectionView.ScrollPosition(rawValue: 0))
            }
        }
    }
    
}

extension UITableView {
    
    /// Register reusable cell with specified class type.
    public func registerCell<T: UITableViewCell>(fromClass type: T.Type)  {
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
    
    /// Deselect selected row along UIViewController`s transition coordinator.
    public func deselectSelectedRow(along transitionCoordinator: UIViewControllerTransitionCoordinator?) {
        guard let selectedIndexPath = indexPathForSelectedRow else { return }
        
        guard let coordinator = transitionCoordinator else {
            deselectRow(at: selectedIndexPath, animated: false)
            return
        }
        
        coordinator.animate(alongsideTransition: { _ in
            self.deselectRow(at: selectedIndexPath, animated: true)
        }) { [weak self] (context) in
            if context.isCancelled {
                self?.selectRow(at: selectedIndexPath, animated: false, scrollPosition: .none)
            }
        }
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
