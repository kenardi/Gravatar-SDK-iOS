import Foundation

/// Represents a Gravatar account email address
public struct Email {
    let string: String

    var hashId: HashId {
        HashId(email: self)
    }

    /// Initializes a new Email object, representing a Gravatar account email address
    /// - Parameter string: The Gravatar account email address`
    public init(_ string: String) {
        self.string = string.normalized()
    }
}

extension Email: IdentifierProvider {
    public var identifier: String {
        self.hashId.identifier
    }
}
