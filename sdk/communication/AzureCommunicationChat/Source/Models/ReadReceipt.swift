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

/// A read receipt indicates the time a message was read by a recipient.
public struct ReadReceipt: Codable {
    // MARK: Properties

    /// The user who read the message.
    public let sender: CommunicationUserIdentifier
    /// Id of the message that has been read. This id is generated by the server.
    public let chatMessageId: String
    /// The time at which the message was read. The timestamp is in RFC3339 format: `yyyy-MM-ddTHH:mm:ssZ`.
    public let readOn: Iso8601Date

    // MARK: Initializers

    /// Initialize a `ReadReceipt` structure from a ChatMessageReadReceipt.
    /// - Parameters:
    ///   - chatMessageReadReceipt: The ChatMessageReadReceipt to initialize from.
    public init(
        from chatMessageReadReceipt: ChatMessageReadReceipt
    ) throws {
        let identifier = try IdentifierSerializer.deserialize(identifier: chatMessageReadReceipt.senderCommunicationIdentifier)
        self.sender = identifier as! CommunicationUserIdentifier
        self.chatMessageId = chatMessageReadReceipt.chatMessageId
        self.readOn = chatMessageReadReceipt.readOn
    }

    /// Initialize a `ReadReceipt` structure.
    /// - Parameters:
    ///   - senderId: Id of the participant who read the message.
    ///   - chatMessageId: Id of the chat message that has been read. This id is generated by the server.
    ///   - readOn: The time at which the message was read. The timestamp is in RFC3339 format: `yyyy-MM-ddTHH:mm:ssZ`.
    public init(
        senderId: String,
        chatMessageId: String,
        readOn: Iso8601Date
    ) {
        self.sender = CommunicationUserIdentifier(identifier: senderId)
        self.chatMessageId = chatMessageId
        self.readOn = readOn
    }

    // MARK: Codable

    enum CodingKeys: String, CodingKey {
        case sender = "senderCommunicationIdentifier"
        case chatMessageId
        case readOn
    }

    /// Initialize a `ReadReceipt` structure from decoder
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        // Decode CommunicationIdentifierModel to CommunicationUserIdentifier
        let identifierModel = try container.decode(CommunicationIdentifierModel.self, forKey: .sender)
        self.sender = try IdentifierSerializer.deserialize(identifier: identifierModel) as! CommunicationUserIdentifier

        self.chatMessageId = try container.decode(String.self, forKey: .chatMessageId)
        self.readOn = try container.decode(Iso8601Date.self, forKey: .readOn)
    }

    /// Encode a `ReadReceipt` structure
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        // Encode CommunicationUserIdentifier to CommunicationIdentifierModel
        let identifierModel = try IdentifierSerializer.serialize(identifier: sender)
        try container.encode(identifierModel, forKey: .sender)

        try container.encode(chatMessageId, forKey: .chatMessageId)
        try container.encode(readOn, forKey: .readOn)
    }
}
