// SPDX-License-Identifier: MIT
import Foundation

public struct MCPRequest: Codable {
    public let jsonrpc: String
    public let id: Int
    public let method: String
    public let params: [String: AnyCodable]?
}

public struct AnyCodable: Codable {
    public let value: Any

    public init(_ value: Any) {
        self.value = value
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let intVal = try? container.decode(Int.self) {
            value = intVal
        } else if let stringVal = try? container.decode(String.self) {
            value = stringVal
        } else if let boolVal = try? container.decode(Bool.self) {
            value = boolVal
        } else if let arrayVal = try? container.decode([AnyCodable].self) {
            value = arrayVal.map { $0.value }
        } else if let dictVal = try? container.decode([String: AnyCodable].self) {
            value = dictVal.mapValues { $0.value }
        } else {
            value = NSNull()
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch value {
        case let intVal as Int: try container.encode(intVal)
        case let stringVal as String: try container.encode(stringVal)
        case let boolVal as Bool: try container.encode(boolVal)
        case let arrayVal as [Any]: try container.encode(arrayVal.map { AnyCodable($0) })
        case let dictVal as [String: Any]: try container.encode(dictVal.mapValues { AnyCodable($0) })
        default: try container.encodeNil()
        }
    }
}

public struct MCPResponse: Codable {
    public let jsonrpc: String
    public let id: Int?
    public let result: [String: AnyCodable]?
    public let error: MCPError?
}

public struct MCPError: Codable, Error {
    public let code: Int
    public let message: String
}
