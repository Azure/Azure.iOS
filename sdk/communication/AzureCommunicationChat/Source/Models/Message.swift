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

/// Message.
public struct Message: Codable {
    // MARK: Properties

    /// The id of the message. This id is server generated.
    public let id: String
    /// The message type.
    public let type: ChatMessageType
    /// Sequence of the message in the conversation.
    public let sequenceId: String
    /// Version of the message.
    public let version: String
    /// Content of the message.
    public let content: MessageContent?
    /// The display name of the message sender. This property is used to populate sender name for push notifications.
    public let senderDisplayName: String?
    /// The timestamp when the message arrived at the server. The timestamp is in RFC3339 format: `yyyy-MM-ddTHH:mm:ssZ`.
    public let createdOn: Iso8601Date
    /// The sender of the message.
    public let sender: CommunicationUserIdentifier?
    /// The timestamp (if applicable) when the message was deleted. The timestamp is in RFC3339 format: `yyyy-MM-ddTHH:mm:ssZ`.
    public let deletedOn: Iso8601Date?
    /// The last timestamp (if applicable) when the message was edited. The timestamp is in RFC3339 format: `yyyy-MM-ddTHH:mm:ssZ`.
    public let editedOn: Iso8601Date?

    // MARK: Initializers

    /// Initialize a `Message` structure from a ChatMessage.
    /// - Parameters:
    ///   - chatMessage: The ChatMessage to initialize from.
    public init(
        from chatMessage: ChatMessage
    ) throws {
        self.id = chatMessage.id
        self.type = chatMessage.type
        self.sequenceId = chatMessage.sequenceId
        self.version = chatMessage.version

        // Convert ChatMessageContent to MessageContent
        if let content = chatMessage.content {
            self.content = try MessageContent(from: content)
        } else {
            self.content = nil
        }

        self.senderDisplayName = chatMessage.senderDisplayName
        self.createdOn = chatMessage.createdOn

        // Deserialize the identifier to CommunicationUserIdentifier
        if let identifierModel = chatMessage.senderCommunicationIdentifier {
            let identifier = try IdentifierSerializer.deserialize(identifier: identifierModel)
            self.sender = identifier as? CommunicationUserIdentifier
        } else {
            self.sender = nil
        }

        self.deletedOn = chatMessage.deletedOn
        self.editedOn = chatMessage.editedOn
    }

    /// Initialize a `Message` structure.
    /// - Parameters:
    ///   - id: The id of the message. This id is server generated.
    ///   - type: The chat message type.
    ///   - sequenceId: Sequence of the message in the conversation.
    ///   - version: Version of the message.
    ///   - content: Content of a message.
    ///   - senderDisplayName: The display name of the message sender. This property is used to populate sender name for push notifications.
    ///   - createdOn: The timestamp when the message arrived at the server. The timestamp is in RFC3339 format: `yyyy-MM-ddTHH:mm:ssZ`.
    ///   - sender: The id of the sender of the message.
    ///   - deletedOn: The timestamp (if applicable) when the message was deleted. The timestamp is in RFC3339 format: `yyyy-MM-ddTHH:mm:ssZ`.
    ///   - editedOn: The last timestamp (if applicable) when the message was edited. The timestamp is in RFC3339 format: `yyyy-MM-ddTHH:mm:ssZ`.
    public init(
        id: String,
        type: ChatMessageType,
        sequenceId: String,
        version: String,
        content: MessageContent? = nil,
        senderDisplayName: String? = nil,
        createdOn: Iso8601Date,
        senderId: String? = nil,
        deletedOn: Iso8601Date? = nil,
        editedOn: Iso8601Date? = nil
    ) {
        self.id = id
        self.type = type
        self.sequenceId = sequenceId
        self.version = version
        self.content = content
        self.senderDisplayName = senderDisplayName
        self.createdOn = createdOn

        // Construct the CommunicationUserIdentifier
        if let sender = senderId {
            self.sender = CommunicationUserIdentifier(identifier: sender)
        } else {
            self.sender = nil
        }

        self.deletedOn = deletedOn
        self.editedOn = editedOn
    }

    // MARK: Codable

    enum CodingKeys: String, CodingKey {
        case id
        case type
        case sequenceId
        case version
        case content
        case senderDisplayName
        case createdOn
        case sender = "senderCommunicationIdentifier"
        case deletedOn
        case editedOn
    }

    /// Initialize a `Message` structure from decoder
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.id = try container.decode(String.self, forKey: .id)
        self.type = try container.decode(ChatMessageType.self, forKey: .type)
        self.sequenceId = try container.decode(String.self, forKey: .sequenceId)
        self.version = try container.decode(String.self, forKey: .version)

        // Convert ChatMessageContent to MessageContent
        let chatMessageContent = try? container.decode(ChatMessageContent.self, forKey: .content)

        if let content = chatMessageContent {
            self.content = try? MessageContent(from: content)
        } else {
            self.content = nil
        }

        self.senderDisplayName = try? container.decode(String.self, forKey: .senderDisplayName)
        self.createdOn = try container.decode(Iso8601Date.self, forKey: .createdOn)

        // Decode CommunicationIdentifierModel to CommunicationUserIdentifier
        if let identifierModel = try? container.decode(CommunicationIdentifierModel.self, forKey: .sender) {
            self.sender = try IdentifierSerializer
                .deserialize(identifier: identifierModel) as? CommunicationUserIdentifier
        } else {
            self.sender = nil
        }

        self.deletedOn = try? container.decode(Iso8601Date.self, forKey: .deletedOn)
        self.editedOn = try? container.decode(Iso8601Date.self, forKey: .editedOn)
    }

    /// Encode a `Message` structure
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(id, forKey: .id)
        try container.encode(type, forKey: .type)
        try container.encode(sequenceId, forKey: .sequenceId)
        try container.encode(version, forKey: .version)
        if content != nil { try? container.encode(content, forKey: .content) }
        if senderDisplayName != nil { try? container.encode(senderDisplayName, forKey: .senderDisplayName) }
        try container.encode(createdOn, forKey: .createdOn)

        // Encode CommunicationUserIdentifier to CommunicationIdentifierModel
        if sender != nil {
            let identifierModel = try IdentifierSerializer.serialize(identifier: sender!)
            try? container.encode(identifierModel, forKey: .sender)
        }

        if deletedOn != nil { try? container.encode(deletedOn, forKey: .deletedOn) }
        if editedOn != nil { try? container.encode(editedOn, forKey: .editedOn) }
    }
}