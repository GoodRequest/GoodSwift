//
// AnimationChain.swift
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

/**
 Container containg all chained animation. If you want to use chained animation use this:
 */
import UIKit

public class AnimationChain {
    
    typealias Animation = (TimeInterval, () -> Void)
    fileprivate let queue: LinkedList<Animation> = LinkedList()
    
    /**
     Append new animation to current animation queue. At the and of caing just call start.
     - SeeAlso:  `AnimationChain`
     - Returns: **AnimationChain** object containg all chained animation.
     */
    public func animate(withDuration: TimeInterval, animation: @escaping () -> Void) -> AnimationChain {
        queue.push(Animation(withDuration, animation))
        return self
    }
    
    /**
     Start all animation.
     - parameter completion: Block which will be executed at the end of animations
     - Returns: **AnimationChain** object containg all chained animation.
     */
    public func start(completion: (() -> Void)? = nil) {
        start(animation: queue.pop(), completion: completion)
    }
    
    private func start(animation: Animation? = nil, completion: (() -> Swift.Void)? = nil) {
        if let topAnimation = animation {
            UIView.animate(withDuration: topAnimation.0, animations: topAnimation.1, completion: { _ in
                self.start(animation: self.queue.pop(), completion: completion)
            })
        } else {
            completion?()
        }
    }
 
}
