//
// FoundationExtensions.swift
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

import Foundation
import UIKit

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
    
    /// Returns height of string with constraint width
    ///
    /// - parameter width: Constrained width of string
    /// - parameter font: Font used to calculate height
    /// - returns: Height of string
    public func height(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSFontAttributeName: font], context: nil)
        
        return boundingBox.height
    }
    
    /// Returns width of string with constraint height
    ///
    /// - parameter height: Constrained height of string
    /// - parameter font: Font used to calculate width
    /// - returns: Width of string
    public func width(withConstraintedHeight height: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSFontAttributeName: font], context: nil)
        
        return boundingBox.width
    }
    
}

extension NSAttributedString {
    
    /// Returns height of attributed string with constraint width
    ///
    /// - parameter width: Constrained width of attributed string
    /// - returns: Height of attributed string
    public func height(withConstrainedWidth width: CGFloat) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, context: nil)
        
        return boundingBox.height
    }
    
    /// Returns height of attributed string with constraint width
    ///
    /// - parameter width: Constrained width of attributed string
    /// - returns: Height of attributed string
    public func width(withConstraintedHeight height: CGFloat) -> CGFloat {
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, context: nil)
        
        return boundingBox.height
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

extension DateFormatter {
    
    /// Convenience initializer for date with format
    public convenience init(format: String) {
        self.init()
        dateFormat = format
    }
    
}
