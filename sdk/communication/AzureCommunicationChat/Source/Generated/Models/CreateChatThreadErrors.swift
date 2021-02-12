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

/// Errors encountered during the creation of the chat thread.
public struct CreateChatThreadErrors: Codable, Equatable {
    // MARK: Properties

    /// The participants that failed to be added to the chat thread.
    public let invalidParticipants: [CommunicationError]?

    // MARK: Initializers

    /// Initialize a `CreateChatThreadErrors` structure.
    /// - Parameters:
    ///   - invalidParticipants: The participants that failed to be added to the chat thread.
    public init(
        invalidParticipants: [CommunicationError]? = nil
    ) {
        self.invalidParticipants = invalidParticipants
    }

    // MARK: Codable

    enum CodingKeys: String, CodingKey {
        case invalidParticipants = "invalidParticipants"
    }

    /// Initialize a `CreateChatThreadErrors` structure from decoder
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.invalidParticipants = try? container.decode([CommunicationError].self, forKey: .invalidParticipants)
    }

    /// Encode a `CreateChatThreadErrors` structure
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        if invalidParticipants != nil { try? container.encode(invalidParticipants, forKey: .invalidParticipants) }
    }
}
