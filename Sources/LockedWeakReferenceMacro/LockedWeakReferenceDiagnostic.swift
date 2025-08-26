import SwiftDiagnostics

struct LockedWeakReferenceDiagnostic: DiagnosticMessage {
    var message: String
    var diagnosticID = MessageID(domain: "LockedWeakReference", id: "invalid specifier")
    var severity = DiagnosticSeverity.error
}
