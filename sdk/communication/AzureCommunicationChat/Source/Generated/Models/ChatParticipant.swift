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

/// A participant of the chat thread.
public struct ChatParticipant: Codable, Equatable {
    // MARK: Properties

    /// Identifies a participant in Azure Communication services. A participant is, for example, a phone number or an Azure communication user. This model must be interpreted as a union: Apart from rawId, at most one further property may be set.
    public let communicationIdentifier: CommunicationIdentifierModel
    /// Display name for the chat participant.
    public let displayName: String?
    /// Time from which the chat history is shared with the participant. The timestamp is in RFC3339 format: `yyyy-MM-ddTHH:mm:ssZ`.
    public let shareHistoryTime: Iso8601Date?

    // MARK: Initializers

    /// Initialize a `ChatParticipant` structure.
    /// - Parameters:
    ///   - communicationIdentifier: Identifies a participant in Azure Communication services. A participant is, for example, a phone number or an Azure communication user. This model must be interpreted as a union: Apart from rawId, at most one further property may be set.
    ///   - displayName: Display name for the chat participant.
    ///   - shareHistoryTime: Time from which the chat history is shared with the participant. The timestamp is in RFC3339 format: `yyyy-MM-ddTHH:mm:ssZ`.
    public init(
        communicationIdentifier: CommunicationIdentifierModel, displayName: String? = nil,
        shareHistoryTime: Iso8601Date? = nil
    ) {
        self.communicationIdentifier = communicationIdentifier
        self.displayName = displayName
        self.shareHistoryTime = shareHistoryTime
    }

    // MARK: Codable

    enum CodingKeys: String, CodingKey {
        case communicationIdentifier = "communicationIdentifier"
        case displayName = "displayName"
        case shareHistoryTime = "shareHistoryTime"
    }

    /// Initialize a `ChatParticipant` structure from decoder
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.communicationIdentifier = try container.decode(
            CommunicationIdentifierModel.self,
            forKey: .communicationIdentifier
        )
        self.displayName = try? container.decode(String.self, forKey: .displayName)
        self.shareHistoryTime = try? container.decode(Iso8601Date.self, forKey: .shareHistoryTime)
    }

    /// Encode a `ChatParticipant` structure
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(communicationIdentifier, forKey: .communicationIdentifier)
        if displayName != nil { try? container.encode(displayName, forKey: .displayName) }
        if shareHistoryTime != nil { try? container.encode(shareHistoryTime, forKey: .shareHistoryTime) }
    }
}
