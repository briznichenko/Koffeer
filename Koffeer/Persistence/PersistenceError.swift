import Foundation

enum PersistenceError: LocalizedError, Equatable {
    case modelNotInContext
    case blendInUse

    var errorDescription: String? {
        switch self {
        case .modelNotInContext:
            "This record is no longer available for editing. Reopen it and try again."
        case .blendInUse:
            "This blend is used by saved brews. Reassign or delete those brews before deleting the blend."
        }
    }
}
