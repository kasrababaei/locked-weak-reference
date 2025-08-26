import Foundation
import LockedWeakReference

protocol FooDelegate: AnyObject {}

@LockedWeakReference
final class AnyFoo: FooDelegate {
    weak var delegate: FooDelegate?
    
    var name = ""
    let id = 1
}
