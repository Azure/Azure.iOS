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
import os.log

/// Protocol which allows clients to customize how they work with Paged Collections.
public protocol PagedCollectionDelegate: AnyObject {
    func continuationUrl(continuationToken: String, queryParams: inout [String: String], requestUrl: String) -> String
}

/// Defines the property keys used to conform to the Azure paging design.
public struct PagedCodingKeys {
    public let items: String
    public let xmlItemName: String?
    public let continuationToken: String

    public init(items: String = "items", continuationToken: String = "continuationToken",
                xmlItemName xmlName: String? = nil) {
        self.items = items
        self.continuationToken = continuationToken
        xmlItemName = xmlName
    }

    internal func items(fromJson json: [String: Any]) -> [Any]? {
        var results: [Any]?
        let components = items.components(separatedBy: ".")
        var current = json
        for component in components {
            guard let temp = current[component] else { return nil }
            if let tempArray = temp as? [Any] {
                guard results == nil else { return nil }
                results = tempArray
            } else if let tempJson = temp as? [String: Any] {
                current = tempJson
            }
        }
        return results
    }

    internal func continuationToken(fromJson json: [String: Any]) -> String? {
        var result: String?
        let components = continuationToken.components(separatedBy: ".")
        var current = json
        for component in components {
            guard let temp = current[component] else { return nil }
            if let tempString = temp as? String {
                guard result == nil else { return nil }
                result = tempString
            } else if let tempJson = temp as? [String: Any] {
                current = tempJson
            }
        }
        return result
    }
}

/// A collection that fetches paged results in a lazy fashion.
public class PagedCollection<SingleElement: Codable>: Sequence, IteratorProtocol, PagedCollectionDelegate {
    public typealias Element = [SingleElement]

    private var _items: Element?

    private weak var delegate: PagedCollectionDelegate?

    /// Returns the current running list of items.
    public var items: Element? {
        return _items
    }

    private var pageRange: Range<Int>?

    /// Returns the subset of items that corresponds to the current page.
    public var pageItems: Element? {
        guard let range = pageRange else { return nil }
        guard let slice = _items?[range] else { return nil }
        return Array(slice)
    }

    /// The continuation token used to fetch the next page of results.
    private var continuationToken: String?

    /// The headers that accompanied the orignal request. Used as the basis for subsequent paged requests.
    private var requestHeaders: HttpHeaders!

    /// An index which tracks the next item to be returned when using the nextItem method.
    private var iteratorIndex: Int = 0

    /// A reference to the configured client that created the PagedCollection. Needed to make follow-up
    /// calls to retrieve additional pages.
    private let client: PipelineClient

    /// The JSON decoder used to deserialze the JSON payload into the appropriate models.
    private let decoder: JSONDecoder

    /// Key values needed to deserialize the service response into items and a continuation token.
    private let codingKeys: PagedCodingKeys

    public var underestimatedCount: Int {
        return items?.count ?? 0
    }

    /// The initial request URL
    private var requestUrl: String

    public func continuationUrl(continuationToken: String, queryParams _: inout [String: String],
                                requestUrl _: String) -> String {
        return client.format(urlTemplate: continuationToken)
    }

    /// Deserializes the JSON payload to append the new items, update tracking of the "current page" of items
    /// and reset the per page iterator.
    private func update(with data: Data?) throws {
        let noDataError = HttpResponseError.decode("Response data expected but not found.")
        guard let data = data else { throw noDataError }
        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] else { throw noDataError }
        let codingKeys = self.codingKeys
        let notPagedError = HttpResponseError.decode("Paged response expected but not found.")
        guard let itemJson = codingKeys.items(fromJson: json) else { throw notPagedError }
        continuationToken = codingKeys.continuationToken(fromJson: json)

        let itemData = try JSONSerialization.data(withJSONObject: itemJson)
        let newItems = try decoder.decode(Element.self, from: itemData)
        if let currentItems = self._items {
            // append rather than throw away old items
            pageRange = currentItems.count ..< (currentItems.count + newItems.count)
            _items = currentItems + newItems
        } else {
            _items = newItems
            pageRange = 0 ..< newItems.count
        }
    }

    public init(client: PipelineClient, request: HttpRequest, data: Data?, codingKeys: PagedCodingKeys? = nil,
                decoder: JSONDecoder? = nil, delegate: PagedCollectionDelegate? = nil) throws {
        let noDataError = HttpResponseError.decode("Response data expected but not found.")
        guard let data = data else { throw noDataError }
        self.client = client
        self.decoder = decoder ?? JSONDecoder()
        self.codingKeys = codingKeys ?? PagedCodingKeys()
        requestHeaders = request.headers
        requestUrl = request.url
        self.delegate = delegate
        try update(with: data)
    }

    /// Retrieves the next page of results asynchronously.
    public func nextPage(then completion: @escaping (Result<Element?, Error>) -> Void) {
        // exit if there is no valid continuation token
        guard let continuationToken = continuationToken else { completion(.success(nil)); return }
        guard continuationToken != "" else { completion(.success(nil)); return }

        let delegate = self.delegate ?? self

        client.logger.info(String(format: "Fetching next page with: %@", continuationToken))
        var queryParams = [String: String]()
        let url = delegate.continuationUrl(continuationToken: continuationToken, queryParams: &queryParams,
                                           requestUrl: requestUrl)
        let request = client.request(method: .GET,
                                     url: url,
                                     queryParams: queryParams,
                                     headerParams: requestHeaders)
        var context = [String: AnyObject]()
        if let xmlType = SingleElement.self as? XMLModelProtocol.Type {
            let xmlMap = XMLMap(withPagedCodingKeys: codingKeys, innerType: xmlType)
            context[ContextKey.xmlMap.rawValue] = xmlMap as AnyObject
        }
        client.run(request: request, context: context) { result, _ in
            var returnError: Error?
            switch result {
            case let .failure(error):
                returnError = error
            case let .success(data):
                do {
                    try self.update(with: data)
                } catch {
                    returnError = error
                }
            }
            if let returnError = returnError {
                completion(.failure(returnError))
            }
            self.iteratorIndex = 0
            completion(.success(self.pageItems))
        }
    }

    /// Retrieves the next item in the collection, automatically fetching new pages when needed.
    public func nextItem(then completion: @escaping (Result<SingleElement?, Error>) -> Void) {
        guard let pageItems = pageItems else {
            completion(.success(nil))
            return
        }
        if iteratorIndex >= pageItems.count {
            nextPage { result in
                switch result {
                case let .failure(error):
                    completion(.failure(error))
                case let .success(newPage):
                    if let newPage = newPage {
                        // since we return the first new item, the next iteration should start with the second item.
                        self.iteratorIndex = 1
                        completion(.success(newPage[0]))
                    } else {
                        self.iteratorIndex = 0
                        completion(.success(nil))
                    }
                }
            }
        } else {
            if let item = self.pageItems?[iteratorIndex] {
                iteratorIndex += 1
                completion(.success(item))
            } else {
                iteratorIndex = 0
                completion(.success(nil))
            }
        }
    }

    // MARK: Iterator Protocol

    /// Returns the next page of results. In order to conform with the protocol, this
    /// usage must be synchronous.
    public func next() -> Element? {
        guard let items = items else { return nil }
        if iteratorIndex < items.count {
            iteratorIndex = items.count
            return items
        }
        // must force synchronous behavior due to the constraints
        // of the protocol.
        let semaphore = DispatchSemaphore(value: 0)
        var newItems: Element?
        let logger = client.logger
        nextPage { result in
            switch result {
            case let .success(newPage):
                self.iteratorIndex = newPage?.count ?? 0
                newItems = newPage
            case let .failure(error):
                logger.error(String(format: "Error: %@", error.localizedDescription))
                newItems = nil
            }
            semaphore.signal()
        }
        _ = semaphore.wait(wallTimeout: .distantFuture)
        return newItems
    }
}
