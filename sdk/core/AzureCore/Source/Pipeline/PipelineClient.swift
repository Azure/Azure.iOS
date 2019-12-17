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

import Foundation

/// Base class containing baseline options for individual service clients.
open class AzureClientOptions {
    public let apiVersion: String
    public var logger: ClientLogger

    // MARK: Initializers

    public init(apiVersion: String) {
        self.apiVersion = apiVersion
        self.logger = ClientLoggers.default()
    }
}

/// Base class containing baseline options for individual client API calls.
open class AzureOptions {
    /// A client-generated, opaque value with 1KB character limit that is recorded in analytics logs.
    /// Highly recommended for correlating client-side activites with requests received by the server.
    public var clientRequestId: String?

    // MARK: Initializers

     public init() {
        self.clientRequestId = nil
    }
}

/// Base class for all pipeline-based service clients.
open class PipelineClient {
    public var logger: ClientLogger {
        return options.logger
    }

    internal var pipeline: Pipeline
    internal var baseUrl: String

    public var options: AzureClientOptions

    // MARK: Initializers

    public init(baseUrl: String, transport: HttpTransportable, policies: [PipelineStageProtocol],
                withOptions options: AzureClientOptions) {
        self.baseUrl = baseUrl
        if self.baseUrl.suffix(1) != "/" { self.baseUrl += "/" }
        pipeline = Pipeline(transport: transport, policies: policies)
        self.options = options
    }

    // MARK: Client API

    public func run(request: HttpRequest, context: [String: AnyObject]?,
                    completion: @escaping (Result<Data?, Error>, HttpResponse) -> Void) {
        var pipelineRequest = PipelineRequest(request: request, logger: logger)
        if let context = context {
            for (key, value) in context {
                pipelineRequest.add(value: value as AnyObject, forKey: key)
            }
        }
        pipeline.run(request: &pipelineRequest, completion: { result, httpResponse in
            switch result {
            case let .success(pipelineResponse):
                let deserializedData = pipelineResponse.value(forKey: .deserializedData) as? Data

                // invalid status code is a failure
                let statusCode = httpResponse.statusCode ?? -1
                let allowedStatusCodes = pipelineResponse.value(forKey: .allowedStatusCodes) as? [Int] ?? [200]
                if !allowedStatusCodes.contains(httpResponse.statusCode ?? -1) {
                    var message = "Service returned invalid status code [\(statusCode)]."
                    if let errorData = deserializedData,
                        let errorJson = try? JSONSerialization.jsonObject(with: errorData) {
                        message += " \(String(describing: errorJson))"
                    }
                    let error = HttpResponseError.statusCode(message)
                    completion(.failure(error), httpResponse)
                    return
                }

                if let deserialized = deserializedData {
                    completion(.success(deserialized), httpResponse)
                } else if let data = httpResponse.data {
                    completion(.success(data), httpResponse)
                }
            case let .failure(error):
                completion(.failure(error), httpResponse)
            }
        })
    }

    public func request(method: HttpMethod, url: String, queryParams: [String: String], headerParams: HttpHeaders,
                        content _: Data? = nil, formContent _: [String: AnyObject]? = nil,
                        streamContent _: AnyObject? = nil) -> HttpRequest {
        let request = HttpRequest(httpMethod: method, url: url, headers: headerParams)
        request.format(queryParams: queryParams)
        return request
    }

    public func format(urlTemplate: String?, withKwargs kwargs: [String: String] = [String: String]()) -> String {
        var template = urlTemplate ?? ""
        if template.hasPrefix("/") { template = String(template.dropFirst()) }
        var url: String
        if template.starts(with: baseUrl) {
            url = template
        } else {
            url = baseUrl + template
        }
        for (key, value) in kwargs {
            url = url.replacingOccurrences(of: "{\(key)}", with: value)
        }
        return url
    }
}
