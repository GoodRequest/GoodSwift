//
// LinkedList.swift
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


/// Cointainer for item in LinkedList.
/// Node contains of value called `item` and next chained node
class Node<T> {
    
    var item: T
    var nextNode: Node<T>? = nil
    
    init(_ item: T) {
        self.item = item
    }
    
}

/// Collection of data elements. Linear order is given by chaining nodes of data structure. 
/// It's also called: Queue, Front. LinkedList is implementation of `FIFO`
public class LinkedList<T>: Sequence {
    
    public typealias Iterator = LinkedListIterator<T>
    
    var head: Node<T>?
    var tail: Node<T>?
    
    /// Pops first item from LinkedList and remove it from queue.
    ///
    /// - returns: First item of queue
    public func pop() -> T? {
        let node = head
        head = head?.nextNode
        if head == nil {
            tail = nil
        }
        return node?.item
    }
    
    /// Return first item of LinkedList without removing it from queue.
    ///
    /// - returns: First item of queue
    public func peak() -> T? {
        return head?.item
    }
    
    /// Insert item into LinkedList on the last position.
    ///
    /// - parameter item: Item to insert
    public func push(_ item: T) {
        if head == nil {
            head = Node(item)
            tail = head
            return
        }
        tail?.nextNode = Node(item)
        tail = tail?.nextNode
    }
    
    public init() {
        head = nil
        tail = nil
    }
    
    /// Check if collection is empty
    ///
    /// - returns: Bool value
    public var isEmpty: Bool {
        return head == nil && tail == nil
    }
    
    /// Create iterator from LinkedList
    ///
    /// - returns: LinkedListIterator of current LinkedList
    public func makeIterator() -> LinkedListIterator<T> {
        return LinkedListIterator(self)
    }
    
}

public struct LinkedListIterator<T>: IteratorProtocol {
    
    public typealias Element = T
    
    let head: Node<T>
    var current: Node<T>?
    
    mutating public func next() -> T? {
        let currentNode = current
        current = currentNode?.nextNode
        return currentNode?.item
    }
    
}

extension LinkedListIterator {
    
    init(_ linkedList: LinkedList<Element>) {
        head = linkedList.head!
        current = head
    }
    
}
