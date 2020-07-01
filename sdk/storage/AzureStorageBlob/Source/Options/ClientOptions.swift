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

/// User-configurable options for the `StorageBlobClient`.
public struct StorageBlobClientOptions: AzureConfigurable {
    /// The API version of the Azure Storage Blob service to invoke.
    public let apiVersion: String
    /// The `ClientLogger` to be used by this `StorageBlobClient`.
    public let logger: ClientLogger

    internal let downloadNetworkPolicy: TransferNetworkPolicy

    internal let uploadNetworkPolicy: TransferNetworkPolicy

    // Blob operations

    /// The maximum size of a single chunk in a blob upload or download.
    public let maxChunkSizeInBytes: Int

    /// Initialize a `StorageBlobClientOptions` structure.
    /// - Parameters:
    ///   - apiVersion: The API version of the Azure Storage Blob service to invoke.
    ///   - logger: The `ClientLogger` to be used by this `StorageBlobClient`.
    ///   - maxChunkSizeInBytes: The maximum size of a single chunk in a blob upload or download.
    ///     Must be less than 4MB if enabling MD5 or CRC64 hashing.
    public init(
        apiVersion: StorageBlobClient.ApiVersion = .latest,
        logger: ClientLogger = ClientLoggers.default(tag: "StorageBlobClient"),
        maxChunkSizeInBytes: Int = 4 * 1024 * 1024 - 1,
        downloadNetworkPolicy: TransferNetworkPolicy? = nil,
        uploadNetworkPolicy: TransferNetworkPolicy? = nil
    ) {
        self.apiVersion = apiVersion.rawValue
        self.logger = logger
        self.maxChunkSizeInBytes = maxChunkSizeInBytes

        // apply default `TransferNetworkPolicy` if none supplied
        self.downloadNetworkPolicy = downloadNetworkPolicy ?? TransferNetworkPolicy.default
        self.uploadNetworkPolicy = uploadNetworkPolicy ?? TransferNetworkPolicy.default
    }
}
