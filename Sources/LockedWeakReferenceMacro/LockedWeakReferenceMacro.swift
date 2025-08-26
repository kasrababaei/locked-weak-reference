import SwiftCompilerPlugin
import SwiftSyntaxMacros

@main
struct LockedWeakReferenceMacro: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        LockedWeakReference.self,
        RegisterWeakReference.self
    ]
}
