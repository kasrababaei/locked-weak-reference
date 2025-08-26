import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

extension DeclSyntaxProtocol {
    var isClass: Bool {
        self.is(ClassDeclSyntax.self)
    }
    
    var isActor: Bool {
        self.is(ActorDeclSyntax.self)
    }
    
    var isEnum: Bool {
        self.is(EnumDeclSyntax.self)
    }
    
    var isStruct: Bool {
        self.is(StructDeclSyntax.self)
    }
}

extension VariableDeclSyntax {
    var canLockWeakReference: Bool {
        isOptional
        && isWeak
        && isInstance
        && !isComputed
        && !isImmutable
    }
    
    var isOptional: Bool {
        type?.is(OptionalTypeSyntax.self) ?? false
    }
    
    var isWeak: Bool {
        modifiers.contains { modifier in
            modifier.tokens(viewMode: .all)
                .contains { token in
                    token.tokenKind == .keyword(.weak)
                }
        }
    }
    
    var isInstance: Bool {
        modifiers.contains { modifier in
            modifier.tokens(viewMode: .all)
                .contains { token in
                    token.tokenKind != .keyword(.static)
                    && token.tokenKind != .keyword(.class)
                }
        }
    }
    
    var type: TypeSyntax? {
        bindings.first?.typeAnnotation?.type
    }
    
    var pattern: PatternSyntax? {
        bindings.first?.pattern
    }
    
    var isComputed: Bool {
        if accessorsMatching({ $0 == .keyword(.get) }).count > 0 {
            return true
        } else {
            return bindings.contains { binding in
                guard case .getter = binding.accessorBlock?.accessors else {
                    return false
                }
                return true
            }
        }
    }
    
    var isImmutable: Bool {
        bindingSpecifier.tokenKind == .keyword(.let)
    }
    
    func accessorsMatching(_ predicate: (TokenKind) -> Bool) -> [AccessorDeclSyntax] {
        let accessors: [AccessorDeclListSyntax.Element] = bindings.compactMap { patternBinding -> AccessorDeclListSyntax? in
            guard let accessorBlock = patternBinding.accessorBlock,
                  case .accessors(let accessors) = accessorBlock.accessors
            else {
                return nil
            }
            
            return accessors
        }.flatMap { $0 }
        
        return accessors.compactMap { accessor in
            predicate(accessor.accessorSpecifier.tokenKind) ? accessor : nil
        }
    }
    
    func hasMacroApplication(_ name: String) -> Bool {
        for attribute in attributes {
            switch attribute {
            case .attribute(let attr):
                if attr.attributeName.tokens(viewMode: .all).map({ $0.tokenKind }) == [.identifier(name)] {
                    return true
                }
            default:
                break
            }
        }
        return false
    }
}

extension DiagnosticsError {
    init<S: SyntaxProtocol>(syntax: S, message: String) {
        self.init(diagnostics: [
            Diagnostic(
                node: Syntax(syntax),
                message: LockedWeakReferenceDiagnostic(message: message)
            )
        ])
    }
}
