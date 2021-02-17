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

/// Errors encountered during the addition of the chat participant to the chat thread.
// TODO: Does not conform to equatable
public struct AddChatParticipantsErrors: Codable {
    // MARK: Properties

    /// The participants that failed to be added to the chat thread.
    public let invalidParticipants: [CommunicationError]

    // MARK: Initializers

    /// Initialize a `AddChatParticipantsErrors` structure.
    /// - Parameters:
    ///   - invalidParticipants: The participants that failed to be added to the chat thread.
    public init(
        invalidParticipants: [CommunicationError]
    ) {
        self.invalidParticipants = invalidParticipants
    }

    // MARK: Codable

    enum CodingKeys: String, CodingKey {
        case invalidParticipants = "invalidParticipants"
    }

    /// Initialize a `AddChatParticipantsErrors` structure from decoder
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.invalidParticipants = try container.decode([CommunicationError].self, forKey: .invalidParticipants)
    }

    /// Encode a `AddChatParticipantsErrors` structure
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(invalidParticipants, forKey: .invalidParticipants)
    }
}
