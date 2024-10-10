import Foundation

open class CodableHelper: @unchecked Sendable {
    public init() {}

    private var customDateFormatter: DateFormatter?
    private var defaultDateFormatter: DateFormatter = OpenISO8601DateFormatter()

    private var customJSONDecoder: JSONDecoder?
    private lazy var defaultJSONDecoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(dateFormatter)
        return decoder
    }()

    private var customJSONEncoder: JSONEncoder?
    private lazy var defaultJSONEncoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .formatted(dateFormatter)
        encoder.outputFormatting = .prettyPrinted
        return encoder
    }()

    public var dateFormatter: DateFormatter {
        get { customDateFormatter ?? defaultDateFormatter }
        set { customDateFormatter = newValue }
    }

    public var jsonDecoder: JSONDecoder {
        get { customJSONDecoder ?? defaultJSONDecoder }
        set { customJSONDecoder = newValue }
    }

    public var jsonEncoder: JSONEncoder {
        get { customJSONEncoder ?? defaultJSONEncoder }
        set { customJSONEncoder = newValue }
    }

    open func decode<T>(_ type: T.Type, from data: Data) -> Swift.Result<T, Error> where T: Decodable {
        Swift.Result { try jsonDecoder.decode(type, from: data) }
    }

    open func encode(_ value: some Encodable) -> Swift.Result<Data, Error> {
        Swift.Result { try jsonEncoder.encode(value) }
    }
}
