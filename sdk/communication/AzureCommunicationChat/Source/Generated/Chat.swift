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
// swiftlint:disable file_length
// swiftlint:disable cyclomatic_complexity
// swiftlint:disable function_body_length
// swiftlint:disable type_body_length

public final class Chat {
    public let client: AzureCommunicationChatClient

    init(client: AzureCommunicationChatClient) {
        self.client = client
    }

    /// Creates a chat thread.
    /// - Parameters:
    ///    - chatThread : Request payload for creating a chat thread.
    ///    - options: A list of options for the operation
    ///    - completionHandler: A completion handler that receives a status code on
    ///     success.
    public func create(
        chatThread: CreateChatThreadRequest,
        withOptions options: CreateChatThreadOptions? = nil,
        completionHandler: @escaping HTTPResultHandler<CreateChatThreadResult>
    ) {
        let dispatchQueue = options?.dispatchQueue ?? client.commonOptions.dispatchQueue ?? DispatchQueue.main

        // Create request parameters
        let params = RequestParameters(
            (.header, "repeatability-request-id", options?.repeatabilityRequestId, .encode), (
                .uri,
                "endpoint",
                client.endpoint.absoluteString,
                .skipEncoding
            ), (.query, "api-version", client.options.apiVersion, .encode),
            (.header, "Content-Type", "application/json", .encode), (.header, "Accept", "application/json", .encode)
        )

        // Construct request
        guard let requestBody = try? JSONEncoder().encode(chatThread) else {
            client.options.logger.error("Failed to encode request body as json.")
            return
        }
        let urlTemplate = "/chat/threads"
        guard let requestUrl = client.url(host: "{endpoint}", template: urlTemplate, params: params),
            let request = try? HTTPRequest(method: .post, url: requestUrl, headers: params.headers, data: requestBody)
        else {
            client.options.logger.error("Failed to construct HTTP request.")
            return
        }

        // Send request
        let context = PipelineContext.of(keyValues: [
            ContextKey.allowedStatusCodes.rawValue: [201, 401, 403, 429, 503] as AnyObject
        ])
        context.add(cancellationToken: options?.cancellationToken, applying: client.options)
        context.merge(with: options?.context)
        client.request(request, context: context) { result, httpResponse in
            guard let data = httpResponse?.data else {
                let noDataError = AzureError.client("Response data expected but not found.")
                dispatchQueue.async {
                    completionHandler(.failure(noDataError), httpResponse)
                }
                return
            }
            switch result {
            case .success:
                guard let statusCode = httpResponse?.statusCode else {
                    let noStatusCodeError = AzureError.client("Expected a status code in response but didn't find one.")
                    dispatchQueue.async {
                        completionHandler(.failure(noStatusCodeError), httpResponse)
                    }
                    return
                }
                if [
                    201
                ].contains(statusCode) {
                    do {
                        let decoder = JSONDecoder()
                        let decoded = try decoder.decode(CreateChatThreadResult.self, from: data)
                        dispatchQueue.async {
                            completionHandler(.success(decoded), httpResponse)
                        }
                    } catch {
                        dispatchQueue.async {
                            completionHandler(.failure(AzureError.client("Decoding error.", error)), httpResponse)
                        }
                    }
                }
                if [401].contains(statusCode) {
                    do {
                        let decoder = JSONDecoder()
                        let decoded = try decoder.decode(CommunicationErrorResponse.self, from: data)
                        dispatchQueue.async {
                            completionHandler(.failure(AzureError.service("Unauthorized.", decoded)), httpResponse)
                        }
                    } catch {
                        dispatchQueue.async {
                            completionHandler(.failure(AzureError.client("Decoding error.", error)), httpResponse)
                        }
                    }
                }
                if [403].contains(statusCode) {
                    do {
                        let decoder = JSONDecoder()
                        let decoded = try decoder.decode(CommunicationErrorResponse.self, from: data)
                        dispatchQueue.async {
                            completionHandler(.failure(AzureError.service("Forbidden.", decoded)), httpResponse)
                        }
                    } catch {
                        dispatchQueue.async {
                            completionHandler(.failure(AzureError.client("Decoding error.", error)), httpResponse)
                        }
                    }
                }
                if [429].contains(statusCode) {
                    do {
                        let decoder = JSONDecoder()
                        let decoded = try decoder.decode(CommunicationErrorResponse.self, from: data)
                        dispatchQueue.async {
                            completionHandler(.failure(AzureError.service("Too many requests.", decoded)), httpResponse)
                        }
                    } catch {
                        dispatchQueue.async {
                            completionHandler(.failure(AzureError.client("Decoding error.", error)), httpResponse)
                        }
                    }
                }
                if [503].contains(statusCode) {
                    do {
                        let decoder = JSONDecoder()
                        let decoded = try decoder.decode(CommunicationErrorResponse.self, from: data)
                        dispatchQueue.async {
                            completionHandler(
                                .failure(AzureError.service("Service unavailable.", decoded)),
                                httpResponse
                            )
                        }
                    } catch {
                        dispatchQueue.async {
                            completionHandler(.failure(AzureError.client("Decoding error.", error)), httpResponse)
                        }
                    }
                }
            case let .failure(error):
                dispatchQueue.async {
                    completionHandler(.failure(error), httpResponse)
                }
            }
        }
    }

    /// Gets the list of chat threads of a user.
    /// - Parameters:

    ///    - options: A list of options for the operation
    ///    - completionHandler: A completion handler that receives a status code on
    ///     success.
    public func listChatThreads(
        withOptions options: ListChatThreadsOptions? = nil,
        completionHandler: @escaping HTTPResultHandler<PagedCollection<ChatThreadItem>>
    ) {
        let dispatchQueue = options?.dispatchQueue ?? client.commonOptions.dispatchQueue ?? DispatchQueue.main

        // Create request parameters
        let params = RequestParameters(
            (.query, "maxPageSize", options?.maxPageSize, .encode), (.query, "startTime", options?.startTime, .encode),
            (.uri, "endpoint", client.endpoint.absoluteString, .skipEncoding),
            (.query, "api-version", client.options.apiVersion, .encode),
            (.header, "Accept", "application/json", .encode)
        )

        // Construct request
        let urlTemplate = "/chat/threads"
        guard let requestUrl = client.url(host: "{endpoint}", template: urlTemplate, params: params),
            let request = try? HTTPRequest(method: .get, url: requestUrl, headers: params.headers)
        else {
            client.options.logger.error("Failed to construct HTTP request.")
            return
        }

        // Send request
        let context = PipelineContext.of(keyValues: [
            ContextKey.allowedStatusCodes.rawValue: [200, 401, 403, 429, 503] as AnyObject
        ])
        context.add(cancellationToken: options?.cancellationToken, applying: client.options)
        context.merge(with: options?.context)
        client.request(request, context: context) { result, httpResponse in
            guard let data = httpResponse?.data else {
                let noDataError = AzureError.client("Response data expected but not found.")
                dispatchQueue.async {
                    completionHandler(.failure(noDataError), httpResponse)
                }
                return
            }
            switch result {
            case .success:
                guard let statusCode = httpResponse?.statusCode else {
                    let noStatusCodeError = AzureError.client("Expected a status code in response but didn't find one.")
                    dispatchQueue.async {
                        completionHandler(.failure(noStatusCodeError), httpResponse)
                    }
                    return
                }
                if [
                    200
                ].contains(statusCode) {
                    do {
                        let decoder = JSONDecoder()
                        let codingKeys = PagedCodingKeys(
                            items: "value",
                            continuationToken: "nextLink"
                        )
                        let paged = try PagedCollection<ChatThreadItem>(
                            client: self.client,
                            request: request,
                            context: context,
                            data: data,
                            codingKeys: codingKeys,
                            decoder: decoder
                        )
                        dispatchQueue.async {
                            completionHandler(.success(paged), httpResponse)
                        }
                    } catch {
                        dispatchQueue.async {
                            completionHandler(.failure(AzureError.client("Decoding error.", error)), httpResponse)
                        }
                    }
                }

                if [401].contains(statusCode) {
                    do {
                        let decoder = JSONDecoder()
                        let decoded = try decoder.decode(CommunicationErrorResponse.self, from: data)
                        dispatchQueue.async {
                            completionHandler(.failure(AzureError.service("Unauthorized.", decoded)), httpResponse)
                        }
                    } catch {
                        dispatchQueue.async {
                            completionHandler(.failure(AzureError.client("Decoding error.", error)), httpResponse)
                        }
                    }
                }
                if [403].contains(statusCode) {
                    do {
                        let decoder = JSONDecoder()
                        let decoded = try decoder.decode(CommunicationErrorResponse.self, from: data)
                        dispatchQueue.async {
                            completionHandler(.failure(AzureError.service("Forbidden.", decoded)), httpResponse)
                        }
                    } catch {
                        dispatchQueue.async {
                            completionHandler(.failure(AzureError.client("Decoding error.", error)), httpResponse)
                        }
                    }
                }
                if [429].contains(statusCode) {
                    do {
                        let decoder = JSONDecoder()
                        let decoded = try decoder.decode(CommunicationErrorResponse.self, from: data)
                        dispatchQueue.async {
                            completionHandler(.failure(AzureError.service("Too many requests.", decoded)), httpResponse)
                        }
                    } catch {
                        dispatchQueue.async {
                            completionHandler(.failure(AzureError.client("Decoding error.", error)), httpResponse)
                        }
                    }
                }
                if [503].contains(statusCode) {
                    do {
                        let decoder = JSONDecoder()
                        let decoded = try decoder.decode(CommunicationErrorResponse.self, from: data)
                        dispatchQueue.async {
                            completionHandler(
                                .failure(AzureError.service("Service unavailable.", decoded)),
                                httpResponse
                            )
                        }
                    } catch {
                        dispatchQueue.async {
                            completionHandler(.failure(AzureError.client("Decoding error.", error)), httpResponse)
                        }
                    }
                }
            case let .failure(error):
                dispatchQueue.async {
                    completionHandler(.failure(error), httpResponse)
                }
            }
        }
    }

    /// Deletes a thread.
    /// - Parameters:
    ///    - chatThreadId : Id of the thread to be deleted.
    ///    - options: A list of options for the operation
    ///    - completionHandler: A completion handler that receives a status code on
    ///     success.
    public func deleteChatThread(
        chatThreadId: String,
        withOptions options: DeleteChatThreadOptions? = nil,
        completionHandler: @escaping HTTPResultHandler<Void>
    ) {
        let dispatchQueue = options?.dispatchQueue ?? client.commonOptions.dispatchQueue ?? DispatchQueue.main

        // Create request parameters
        let params = RequestParameters(
            (.path, "chatThreadId", chatThreadId, .encode),
            (.uri, "endpoint", client.endpoint.absoluteString, .skipEncoding),
            (.query, "api-version", client.options.apiVersion, .encode),
            (.header, "Accept", "application/json", .encode)
        )

        // Construct request
        let urlTemplate = "/chat/threads/{chatThreadId}"
        guard let requestUrl = client.url(host: "{endpoint}", template: urlTemplate, params: params),
            let request = try? HTTPRequest(method: .delete, url: requestUrl, headers: params.headers)
        else {
            client.options.logger.error("Failed to construct HTTP request.")
            return
        }

        // Send request
        let context = PipelineContext.of(keyValues: [
            ContextKey.allowedStatusCodes.rawValue: [204, 401, 403, 429, 503] as AnyObject
        ])
        context.add(cancellationToken: options?.cancellationToken, applying: client.options)
        context.merge(with: options?.context)
        client.request(request, context: context) { result, httpResponse in
            guard let data = httpResponse?.data else {
                let noDataError = AzureError.client("Response data expected but not found.")
                dispatchQueue.async {
                    completionHandler(.failure(noDataError), httpResponse)
                }
                return
            }
            switch result {
            case .success:
                guard let statusCode = httpResponse?.statusCode else {
                    let noStatusCodeError = AzureError.client("Expected a status code in response but didn't find one.")
                    dispatchQueue.async {
                        completionHandler(.failure(noStatusCodeError), httpResponse)
                    }
                    return
                }
                if [
                    204
                ].contains(statusCode) {
                    dispatchQueue.async {
                        completionHandler(
                            .success(()),
                            httpResponse
                        )
                    }
                }
                if [401].contains(statusCode) {
                    do {
                        let decoder = JSONDecoder()
                        let decoded = try decoder.decode(CommunicationErrorResponse.self, from: data)
                        dispatchQueue.async {
                            completionHandler(.failure(AzureError.service("Unauthorized.", decoded)), httpResponse)
                        }
                    } catch {
                        dispatchQueue.async {
                            completionHandler(.failure(AzureError.client("Decoding error.", error)), httpResponse)
                        }
                    }
                }
                if [403].contains(statusCode) {
                    do {
                        let decoder = JSONDecoder()
                        let decoded = try decoder.decode(CommunicationErrorResponse.self, from: data)
                        dispatchQueue.async {
                            completionHandler(.failure(AzureError.service("Forbidden.", decoded)), httpResponse)
                        }
                    } catch {
                        dispatchQueue.async {
                            completionHandler(.failure(AzureError.client("Decoding error.", error)), httpResponse)
                        }
                    }
                }
                if [429].contains(statusCode) {
                    do {
                        let decoder = JSONDecoder()
                        let decoded = try decoder.decode(CommunicationErrorResponse.self, from: data)
                        dispatchQueue.async {
                            completionHandler(.failure(AzureError.service("Too many requests.", decoded)), httpResponse)
                        }
                    } catch {
                        dispatchQueue.async {
                            completionHandler(.failure(AzureError.client("Decoding error.", error)), httpResponse)
                        }
                    }
                }
                if [503].contains(statusCode) {
                    do {
                        let decoder = JSONDecoder()
                        let decoded = try decoder.decode(CommunicationErrorResponse.self, from: data)
                        dispatchQueue.async {
                            completionHandler(
                                .failure(AzureError.service("Service unavailable.", decoded)),
                                httpResponse
                            )
                        }
                    } catch {
                        dispatchQueue.async {
                            completionHandler(.failure(AzureError.client("Decoding error.", error)), httpResponse)
                        }
                    }
                }
            case let .failure(error):
                dispatchQueue.async {
                    completionHandler(.failure(error), httpResponse)
                }
            }
        }
    }
}
