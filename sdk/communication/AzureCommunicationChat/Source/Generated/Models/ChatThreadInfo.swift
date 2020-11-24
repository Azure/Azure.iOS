// --------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for
// license information.
//
// Code generated by Microsoft (R) AutoRest Code Generator.
// Changes may cause incorrect behavior and will be lost if the code is
// regenerated.
// --------------------------------------------------------------------------

import AzureCore
import Foundation
// swiftlint:disable superfluous_disable_command
// swiftlint:disable identifier_name
// swiftlint:disable line_length
// swiftlint:disable cyclomatic_complexity

public struct ChatThreadInfo: Codable {
    // MARK: Properties

    /// Chat thread id.
    public let id: String?
    /// Chat thread topic.
    public let topic: String?
    /// The timestamp when the chat thread was deleted. The timestamp is in ISO8601 format: `yyyy-MM-ddTHH:mm:ssZ`.
    public let deletedOn: Date?
    /// The timestamp when the last message arrived at the server. The timestamp is in ISO8601 format: `yyyy-MM-ddTHH:mm:ssZ`.
    public let lastMessageReceivedOn: Iso8601Date?

    // MARK: Initializers

    /// Initialize a `ChatThreadInfo` structure.
    /// - Parameters:
    ///   - id: Chat thread id.
    ///   - topic: Chat thread topic.
    ///   - deletedOn: The timestamp when the chat thread was deleted. The timestamp is in ISO8601 format: `yyyy-MM-ddTHH:mm:ssZ`.
    ///   - lastMessageReceivedOn: The timestamp when the last message arrived at the server. The timestamp is in ISO8601 format: `yyyy-MM-ddTHH:mm:ssZ`.
    public init(
        id: String? = nil, topic: String? = nil, deletedOn: Date? = nil, lastMessageReceivedOn: Date? = nil
    ) {
        self.id = id
        self.topic = topic
        self.deletedOn = deletedOn
        self.lastMessageReceivedOn = lastMessageReceivedOn
    }

    // MARK: Codable

    enum CodingKeys: String, CodingKey {
        case id
        case topic
        case deletedOn
        case lastMessageReceivedOn
    }

    /// Initialize a `ChatThreadInfo` structure from decoder
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try? container.decode(String.self, forKey: .id)
        self.topic = try? container.decode(String.self, forKey: .topic)
        if let dateString = try? container.decode(String.self, forKey: .deletedOn) {
            self.deletedOn = Date(dateString, format: Date.Format.iso8601)
        } else {
            self.deletedOn = nil
        }
        if let dateString = try? container.decode(String.self, forKey: .lastMessageReceivedOn) {
            self.lastMessageReceivedOn = Date(dateString, format: Date.Format.iso8601)
        } else {
            self.lastMessageReceivedOn = nil
        }
    }

    /// Encode a `ChatThreadInfo` structure
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        if id != nil { try? container.encode(id, forKey: .id) }
        if topic != nil { try? container.encode(topic, forKey: .topic) }
        if deletedOn != nil {
            let dateFormatter = DateFormatter()
            let dateString = dateFormatter.string(from: deletedOn!)
            try? container.encode(dateString, forKey: .deletedOn)
        }

        if lastMessageReceivedOn != nil {
            let dateFormatter = DateFormatter()
            let dateString = dateFormatter.string(from: lastMessageReceivedOn!)
            try? container.encode(dateString, forKey: .lastMessageReceivedOn)
        }
    }
}
