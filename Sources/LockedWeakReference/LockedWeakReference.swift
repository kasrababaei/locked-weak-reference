@attached(member, names: arbitrary)
@attached(extension, names: named(LockedWeakReference))
@attached(memberAttribute)
public macro LockedWeakReference() = #externalMacro(
    module: "LockedWeakReferenceMacro",
    type: "LockedWeakReference"
)

@attached(accessor, names: named(_), named(withLocked))
public macro RegisterWeakReference() = #externalMacro(
    module: "LockedWeakReferenceMacro",
    type: "RegisterWeakReference"
)
