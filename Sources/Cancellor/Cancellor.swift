// Copyright (c) 2021 Marin Todorov
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

#if os(iOS)
import UIKit
fileprivate typealias ViewController = UIViewController
#elseif os(macOS)
import Cocoa
fileprivate typealias ViewController = NSViewController
#endif

import Combine

/// A builder that passes through a sequence of `AnyCancellable` values.
@available(iOS 13.0, macOS 10.15, *)
@resultBuilder
public struct CancellablesBuilder {
    public static func buildBlock(_ parts: AnyCancellable...) -> [AnyCancellable] {
        return parts
    }
}

/// An extension that adds a function result builder to bind a list of cancellables
/// to the lifetime of the current view controller.
@available(iOS 13.0, macOS 10.15, *)
extension NSObject {
    private static var cancellablesLock: os_unfair_lock_s = { os_unfair_lock_s() }()
    private static var cancellablesKeyRawValue: UInt8 = 0

    fileprivate func addCancellables(_ cancellables: [AnyCancellable]) {
        os_unfair_lock_lock(&Self.cancellablesLock)
        
        var storage = objc_getAssociatedObject(self, &Self.cancellablesKeyRawValue) as? [AnyCancellable] ?? []
        storage.append(contentsOf: cancellables)
        objc_setAssociatedObject(self, &Self.cancellablesKeyRawValue, storage, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        
        os_unfair_lock_unlock(&Self.cancellablesLock)
    }
    
    /// Binds the given cancellables to the lifetime of the current controller.
    /// - Parameter content: A list of `AnyCancellable` expressions.
    ///
    /// Use this function to subscribe multiple publishers in your `viewDidLoad()` or
    /// once in your `viewDidAppear(_:)` method:
    /// ```
    /// ownedCancellables {
    ///   myPublisher1.sink { ... }
    ///   myPublisher2.sink { ... }
    ///   myPublisher3.assign(to: ..., on: ...)
    /// }
    /// ```
    public func ownedCancellables(@CancellablesBuilder content: () -> [AnyCancellable]) {
        addCancellables(content())
    }
}

extension AnyCancellable {
    /// Bind the lifetime of this subscription to to the given object.
    /// - parameter by: An `NSObject` inheriting owner.
    ///
    /// In case this cancellable isn't cancelled when the owner object is deinitialized
    /// it will be cancelled and then released.
    /// ```
    /// let viewModel = ViewModel(...)
    ///
    /// myPublisher
    ///   .sink { ... }
    ///   .owned(by: viewModel)
    /// ```
    public func owned(by owner: NSObject) {
        owner.addCancellables([self])
    }
}
