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

import AzureCore
import Foundation

// MARK: Data Structures

/// Data structure representing the progress of a blob transfer.
public struct TransferProgress {
    /// Completed bytes.
    public let bytes: Int
    /// Total bytes to transfer.
    public let totalBytes: Int
    /// Percentage of the transfer that is complete, as an Int between 0 and 100.
    public var asPercent: Int {
        return Int(asFloat * 100.0)
    }

    /// Percentage of the transfer that is complete, as a Float between 0 and 1.
    public var asFloat: Float {
        return Float(bytes) / Float(totalBytes)
    }
}

// MARK: Protocols

/// Object that contains information about a transfer operation.
public protocol Transfer: AnyObject {
    /// The unique identifier for this transfer operation.
    var id: UUID { get }
    /// The current state of the transfer.
    var state: TransferState { get }
    /// A debug representation of the transfer.
    var debugString: String { get }
    /// :nodoc: Internal representation of the state.
    var rawState: Int16 { get }
}

internal protocol TransferImpl: Transfer {
    var operation: ResumableOperation? { get set }
    var state: TransferState { get set }
    var rawState: Int16 { get set }
}

// MARK: Extensions

public extension Transfer {
    var state: TransferState { return TransferState(rawValue: rawState)! }
}

internal extension TransferImpl {
    var state: TransferState {
        get { return TransferState(rawValue: rawState)! }
        set { rawState = newValue.rawValue }
    }
}
