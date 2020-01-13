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

import XCTest
@testable import AzureCore

class RegexUtilTests: XCTestCase {

    func testRegexUtil() {
        let regex = NSRegularExpression("^(application|text)/([0-9a-z+.]+)?json$")
        let goodString = "application/json"
        let badString = "application/xml"

        // test a good string
        let result = regex.firstMatch(in: goodString)
        XCTAssertTrue(regex.hasMatch(in: goodString))
        XCTAssertEqual(result, goodString)

        // test a bad string
        XCTAssertFalse(regex.hasMatch(in: badString))
        XCTAssertNil(regex.firstMatch(in: badString))
    }

    func testDateUtil() {
        let rfc1123String = "Jan, 02 2020 07:12:34 GMT"
        let date = rfc1123String.rfc1123Date

        // ensure date string can be round-tripped
        XCTAssertNotNil(date)
        XCTAssertEqual(date?.rfc1123Format, rfc1123String)

        // setup calendar
        let units = Set<Calendar.Component>([.day, .month, .year, .hour, .minute, .second, .timeZone])
        var calendar = Calendar.current
        calendar.timeZone = TimeZone(identifier: "GMT")!

        // verify parses to correct components
        let dateComponents = Calendar.current.dateComponents(units, from: date!)
        XCTAssertEqual(dateComponents.month, 1)
        XCTAssertEqual(dateComponents.day, 2)
        XCTAssertEqual(dateComponents.year, 2020)
        XCTAssertEqual(dateComponents.hour, 7)
        XCTAssertEqual(dateComponents.minute, 12)
        XCTAssertEqual(dateComponents.second, 34)
        XCTAssertEqual(dateComponents.timeZone, TimeZone.init(abbreviation: "GMT"))
    }

    func testStringUtil() {
        let dateString = "Jan, 02 2020 07:12:34 GMT"
        let headers: HTTPHeaders = [
            "string": "test",
            "bool": "true",
            "int": "22",
            "date": dateString,
            "enum": "Accept"
        ]
        XCTAssertEqual(headers["string"], "test")

        // test asBool
        XCTAssertEqual(headers["bool"].asBool, true)
        XCTAssertNil(headers["string"].asBool)

        // test asInt
        XCTAssertEqual(headers["int"].asInt, 22)
        XCTAssertNil(headers["bool"].asInt)

        // test asEnum
        XCTAssertEqual(headers["enum"].asEnum(HTTPHeader.self), HTTPHeader.accept)
        XCTAssertNil(headers["int"].asEnum(HTTPHeader.self))

        // test asDate
        XCTAssertEqual(headers["date"].asDate, dateString.rfc1123Date)
        XCTAssertNil(headers["bool"].asDate)
    }
}
