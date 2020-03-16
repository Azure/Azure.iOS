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

import CoreData
import Foundation

public enum TransferState: Int16 {
    case unknown, pending, inProgress, paused, complete, failed, canceled, deleted

    public func string() -> String {
        switch self {
        case .unknown:
            return "Unknown"
        case .pending:
            return "Pending"
        case .inProgress:
            return "In Progress"
        case .paused:
            return "Paused"
        case .complete:
            return "Complete"
        case .failed:
            return "Failed"
        case .canceled:
            return "Canceled"
        case .deleted:
            return "Deleted"
        }
    }
}

public protocol ResumableOperationDelegate: AnyObject {
    func operation(_ operation: ResumableOperation?, didChangeState state: TransferState)
}

open class ResumableOperation: Operation {
    // MARK: Properties

    internal var internalState: TransferState
    public var state: TransferState {
        return internalState
    }

    public weak var delegate: ResumableOperationDelegate?

    open var isPaused: Bool {
        return internalState == .paused
    }

    public var debugString: String {
        return "Operation \(type(of: self)) \(hash): Status \(internalState.string())"
    }

    // MARK: Initializers

    public init(state: TransferState = .pending, delegate: ResumableOperationDelegate? = nil) {
        self.internalState = state
        self.delegate = delegate
    }

    // MARK: Public Methods

    open override func main() {
        if isCancelled || isPaused { return }
        internalState = .complete
    }

    open override func start() {
        if internalState == .pending {
            internalState = .inProgress
        }
        super.start()
    }

    open override func cancel() {
        internalState = .canceled
        super.cancel()
    }

    open func pause() {
        internalState = .paused
        super.cancel()
    }
}
