import Foundation

/// The languages the user knows. This is only provided in authenticated API requests.
///
public struct Language: Codable, Hashable, Sendable {
    /// The language code.
    public private(set) var code: String
    /// The language name.
    public private(set) var name: String
    /// Whether the language is the user's primary language.
    public private(set) var isPrimary: Bool
    /// The order of the language in the user's profile.
    public private(set) var order: Int

    @available(*, deprecated, message: "init will become internal on the next release")
    public init(code: String, name: String, isPrimary: Bool, order: Int) {
        self.code = code
        self.name = name
        self.isPrimary = isPrimary
        self.order = order
    }

    @available(*, deprecated, message: "CodingKeys will become internal on the next release.")
    public enum CodingKeys: String, CodingKey, CaseIterable {
        case code
        case name
        case isPrimary = "is_primary"
        case order
    }

    enum InternalCodingKeys: String, CodingKey, CaseIterable {
        case code
        case name
        case isPrimary = "is_primary"
        case order
    }

    // Encodable protocol methods

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: InternalCodingKeys.self)
        try container.encode(code, forKey: .code)
        try container.encode(name, forKey: .name)
        try container.encode(isPrimary, forKey: .isPrimary)
        try container.encode(order, forKey: .order)
    }

    // Decodable protocol methods

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: InternalCodingKeys.self)

        code = try container.decode(String.self, forKey: .code)
        name = try container.decode(String.self, forKey: .name)
        isPrimary = try container.decode(Bool.self, forKey: .isPrimary)
        order = try container.decode(Int.self, forKey: .order)
    }
}
