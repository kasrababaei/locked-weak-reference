import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

#if canImport(LockedWeakReferenceMacro)
import LockedWeakReferenceMacro

let testMacros: [String: Macro.Type] = [
    "LockedWeakReference": LockedWeakReference.self,
    "RegisterWeakReference": RegisterWeakReference.self,
]
#endif

final class LockedWeakReferenceTests: XCTestCase {
    func testLockedWeakReferenceMacro() throws {
        #if canImport(LockedWeakReferenceMacro)
        assertMacroExpansion(
            """
            protocol FooDelegate: AnyObject {}
            @LockedWeakReference
            final class AnyFoo: FooDelegate, Sendable {
                weak var delegate: FooDelegate?
                var name = ""
                let value = 1
            }
            """,
            expandedSource: """
            protocol FooDelegate: AnyObject {}
            final class AnyFoo: FooDelegate, Sendable {
                weak var delegate: FooDelegate? {
                    get {
                        _delegate.withLock {
                            $0 as? FooDelegate
                        }
                    }
                    set {
                        _delegate.withLock {
                            $0 = newValue
                        }
                    }
                }
                var name = ""
                let value = 1
            
                private let _delegate = LockedWeakReference()
            }
            
            private extension AnyFoo {
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
            """,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
}
