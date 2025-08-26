import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct LockedWeakReference: ExtensionMacro, MemberMacro, MemberAttributeMacro {
    public static func expansion<T: DeclGroupSyntax, S: TypeSyntaxProtocol, U: MacroExpansionContext>(
        of node: AttributeSyntax,
        attachedTo declaration: T,
        providingExtensionsOf type: S,
        conformingTo protocols: [TypeSyntax],
        in context: U
    ) throws -> [ExtensionDeclSyntax] {
        guard let identified = declaration.asProtocol(NamedDeclSyntax.self) else {
            return []
        }
        
        let token = identified.name.trimmed
        
        if declaration.isEnum {
            throw DiagnosticsError(
                syntax: node,
                message: "'@LockedWeakReference' cannot be applied to enumeration type '\(token.text)'"
            )
        }
        
        if declaration.isStruct {
            throw DiagnosticsError(
                syntax: node,
                message: "'@LockedWeakReference' cannot be applied to struct type '\(token.text)'"
            )
        }
        
        if declaration.isActor {
            throw DiagnosticsError(
                syntax: node,
                message: "'@LockedWeakReference' cannot be applied to actor type '\(token.text)'"
            )
        }
        
        let decl: DeclSyntax = """
        private extension \(raw: token.text) {
            final class LockedWeakReference: @unchecked Sendable {
                private let lock: NSLock = { NSLock() }()
                private(set) weak var value: AnyObject?
                func withLock<R>(_ body: (inout AnyObject?) throws -> R) rethrows -> R {
                    lock.lock()
                    defer { lock.unlock() }
                    return try body(&value)
                }
            }
        }
        """
        
        return [decl.cast(ExtensionDeclSyntax.self)]
    }
    
    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard let identified = declaration.asProtocol(NamedDeclSyntax.self) else {
            return []
        }
        
        let token = identified.name.trimmed
        
        if declaration.isEnum {
            throw DiagnosticsError(
                syntax: node,
                message: "'@LockedWeakReference' cannot be applied to enumeration type '\(token.text)'"
            )
        }
        
        if declaration.isStruct {
            throw DiagnosticsError(
                syntax: node,
                message: "'@LockedWeakReference' cannot be applied to struct type '\(token.text)'"
            )
        }
        
        if declaration.isActor {
            throw DiagnosticsError(
                syntax: node,
                message: "'@LockedWeakReference' cannot be applied to actor type '\(token.text)'"
            )
        }
        
        guard let classDecl = declaration.as(ClassDeclSyntax.self) else {
            throw DiagnosticsError(
                syntax: node,
                message: "'@LockedWeakReference' cannot be applied to non-class types.'"
            )
        }
        
        let weakVariables = classDecl.memberBlock.members
            .compactMap { $0.decl.as(VariableDeclSyntax.self) }
            .filter { $0.canLockWeakReference }
        
        guard !weakVariables.isEmpty else {
            return []
        }
        
        return weakVariables
            .compactMap { $0.bindings.first?.pattern.trimmedDescription }
            .map { description -> DeclSyntax in "private let _\(raw: description) = LockedWeakReference()" }
    }
    
    public static func expansion(
      of node: AttributeSyntax,
      attachedTo declaration: some DeclGroupSyntax,
      providingAttributesFor member: some DeclSyntaxProtocol,
      in context: some MacroExpansionContext
    ) throws -> [AttributeSyntax] {
        guard declaration.isClass,
              let property = member.as(VariableDeclSyntax.self),
              !property.hasMacroApplication("RegisterWeakReference"),
              property.canLockWeakReference
        else {
            return []
        }
        
        return [
            AttributeSyntax(attributeName: IdentifierTypeSyntax(name: .identifier("RegisterWeakReference")))
        ]
    }
}
