import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public enum RegisterWeakReference: AccessorMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingAccessorsOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [AccessorDeclSyntax] {
        guard let varDecl = declaration.as(VariableDeclSyntax.self),
              varDecl.canLockWeakReference,
              let propertyName = varDecl.pattern?.trimmedDescription,
              let propertyType = varDecl.type?.as(OptionalTypeSyntax.self)?.wrappedType.trimmedDescription
        else {
            return []
        }
        
        let accessorGetter = AccessorDeclSyntax(
            """
            get {
                _\(raw: propertyName).withLock { $0 as? \(raw: propertyType) }
            } 
            """
        )
        
        let accessorSetter = AccessorDeclSyntax("""
            set {
                _\(raw: propertyName).withLock { $0 = newValue }
            }
            """
        )
        
        return [accessorGetter, accessorSetter]
    }
}
