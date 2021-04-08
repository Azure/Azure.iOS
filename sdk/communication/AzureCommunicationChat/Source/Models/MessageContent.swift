// --------------------------------------------------------------------------
//
// Copyright (c) Microsoft Corporation. All rights reserved.
//
// The MIT License (MIT)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the ""Software""), to
// deal in the Software without restriction, including without limitation the
// rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
// sell copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED *AS IS*, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
// FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
// IN THE SOFTWARE.
//
// --------------------------------------------------------------------------

import AzureCommunication
import AzureCore
import Foundation

/// Content of a message.
public struct MessageContent: Codable {
    // MARK: Properties

    /// Chat message content for messages of types text or html.
    public let message: String?
    /// Chat message content for messages of type topicUpdated.
    public let topic: String?
    /// Chat message content for messages of types participantAdded or participantRemoved.
    public let participants: [Participant]?
    /// CommunicationUserIdentifier of chat message initiator
    public let initiator: CommunicationUserIdentifier?

    // MARK: Initializers

    /// Initializes a `MessageContent` structure from a ChatMessageContent.
    /// - Parameters:
    ///   - chatMessageContent: ChatMessageContent to initialize from.
    public init(
        from chatMessageContent: ChatMessageContent
    ) throws {
        self.message = chatMessageContent.message
        self.topic = chatMessageContent.topic

        // Convert ChatParticipants to Participants
        if let participants = chatMessageContent.participants {
            self.participants = try participants.map { try Participant(from: $0) }
        } else {
            self.participants = nil
        }

        // Deserialize the identifier to CommunicationUserIdentifier
        if let identifierModel = chatMessageContent.initiatorCommunicationIdentifier {
            let identifier = try IdentifierSerializer.deserialize(identifier: identifierModel)
            self.initiator = identifier as? CommunicationUserIdentifier
        } else {
            self.initiator = nil
        }
    }

    /// Initialize a `MessageContent` structure.
    /// - Parameters:
    ///   - message: Message content for messages of types text or html.
    ///   - topic: Message content for messages of type topicUpdated.
    ///   - participants: Message content for messages of types participantAdded or participantRemoved.
    ///   - initiator: Message content for messages of types participantAdded or participantRemoved.
    public init(
        message: String? = nil,
        topic: String? = nil,
        participants: [Participant]? = nil,
        initiatorId: String? = nil
    ) {
        self.message = message
        self.topic = topic
        self.participants = participants

        // Construct the CommunicationUserIdentifier
        if let identifier = initiatorId {
            self.initiator = CommunicationUserIdentifier(identifier: identifier)
        } else {
            self.initiator = nil
        }
    }

    // MARK: Codable

    enum CodingKeys: String, CodingKey {
        case message
        case topic
        case participants
        case initiator = "initiatorCommunicationIdentifier"
    }

    /// Initialize a `MessageContent` structure from decoder
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.message = try? container.decode(String.self, forKey: .message)
        self.topic = try? container.decode(String.self, forKey: .topic)

        // Decode ChatParticipants to Participants
        let chatParticipants = try? container.decode([ChatParticipant].self, forKey: .participants)

        if let participants = chatParticipants {
            self.participants = try participants.map { try Participant(from: $0) }
        } else {
            self.participants = nil
        }

        // Decode CommunicationIdentifierModel to CommunicationUserIdentifier
        if let identifierModel = try? container.decode(CommunicationIdentifierModel.self, forKey: .initiator) {
            self.initiator = try IdentifierSerializer
                .deserialize(identifier: identifierModel) as? CommunicationUserIdentifier
        } else {
            self.initiator = nil
        }
    }

    /// Encode a `MessageContent` structure
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        if message != nil { try? container.encode(message, forKey: .message) }
        if topic != nil { try? container.encode(topic, forKey: .topic) }

        // Encode Participant to ChatParticipant format
        if let participants = participants {
            let chatParticipants = try participants.map { (participant) -> ChatParticipant in
                let identifierModel = try IdentifierSerializer.serialize(identifier: participant.user)
                return ChatParticipant(
                    communicationIdentifier: identifierModel,
                    displayName: participant.displayName,
                    shareHistoryTime: participant.shareHistoryTime
                )
            }
            try? container.encode(chatParticipants, forKey: .participants)
        }

        // Encode CommunicationUserIdentifier to CommunicationIdentifierModel
        if let identifier = initiator {
            let identifierModel = try IdentifierSerializer.serialize(identifier: identifier)
            try? container.encode(identifierModel, forKey: .initiator)
        }
    }
}