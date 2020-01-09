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

public final class PipelineResponse: PipelineContextProtocol, Copyable {

    // MARK: Properties

    public var httpRequest: HttpRequest
    public var httpResponse: HttpResponse?
    public var logger: ClientLoggerProtocol

    public var context: PipelineContext?

    // MARK: Initializers

    convenience init(request: HttpRequest, response: HttpResponse, logger: ClientLoggerProtocol) {
        self.init(request: request, response: response, logger: logger, context: nil)
    }

    init(request: HttpRequest, response: HttpResponse?, logger: ClientLoggerProtocol, context: PipelineContext?) {
        httpRequest = request
        httpResponse = response
        self.logger = logger
        self.context = context
    }

    public required convenience init(copy: PipelineResponse) {
        self.init(request: copy.httpRequest, response: copy.httpResponse, logger: copy.logger, context: copy.context)
    }
}
