# Locked Weak Reference

A tiny Swift utility that wraps a `weak` reference behind a lock so you can
access and mutate it safely from multiple threads, perfect for things like
delegates where you want ARC semantics **and** thread safety without leaking or racing.

## Why?

Plain `weak` properties are great to avoid retain cycles, but concurrent
reads/writes of the same weak storage can race. This macro makes it easier
to annotate a class as `Sendable` without unnecessarily marking it with
`@MainActor` (which can otherwise cascade `@MainActor` into call sites even
when not needed).

## Usage

For example, imagine `APINetwork` class which has a `delegate` property which
is an existential type that conforms to `URLSessionDelegate`. Even though
[URLSessionDelegate](https://developer.apple.com/documentation/foundation/urlsessiondelegate)
conforms to the `Sendable` protocol, it's not possible to annotate `APINetwork`
class as `Sendable`:

```swift
import Foundation

final class APINetwork: Sendable {
  // Stored property 'delegate' of 'Sendable'-conforming class 'APINetwork'
  // is mutable; this is an error in the Swift 6 language mode
  weak var delegate: URLSessionDelegate?
}
```

By adding this package as a dependency to your project, it's possible to safely make
the `APINetwork` class thread-safe:

```swift
import Foundation
import LockedWeakReference

@LockedWeakReference
final class APINetwork: Sendable {
  weak var delegate: URLSessionDelegate?
}
```

The macro is capable of finding all the `weak` types and safely wrap them in an
atomic type. Here's the expanded macro for the example above:

```swift
import Foundation
import LockedWeakReference

@LockedWeakReference
final class APINetwork: Sendable {
  @RegisterWeakReference
  weak var delegate: URLSessionDelegate?
  {
    get {
        _delegate.withLock {
            $0 as? URLSessionDelegate
        }
    }
    set {
        _delegate.withLock {
            $0 = newValue
        }
    }
  }
  private let _delegate = LockedWeakReference()
}
private extension APINetwork {
    final class LockedWeakReference: @unchecked Sendable {
        private let lock: NSLock = {
            NSLock()
        }()
        private(set) weak var value: AnyObject?
        func withLock<R>(_ body: (inout AnyObject?) throws -> R) rethrows -> R {
            lock.lock()
            defer {
                lock.unlock()
            }
            return try body(&value)
        }
    }
}
```

## Installation

The dependency can be added to an Xcode project by adding it to your project as
a package. You can either add it to your Xcode project as a package:

```text
https://github.com/kasrababaei/locked-weak-reference
```

Or add it to you SPM by simply modifying the `Package.swift` file:

```swift
dependencies: [
  .package(url: "https://github.com/kasrababaei/locked-weak-reference", from: "1.0.0")
]
```

Next, add the product to any target that needs access to the macro:

```swift
.product(name: "LockedWeakReference", package: "locked-weak-reference"),
```
