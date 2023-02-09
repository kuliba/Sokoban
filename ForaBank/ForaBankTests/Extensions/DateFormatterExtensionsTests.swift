//
//  DateFormatterExtensionsTests.swift
//  ForaBankTests
//
//  Created by Max Gribov on 03.02.2022.
//

import XCTest
@testable import ForaBank

class DateFormatterExtensionsTests: XCTestCase {

    func testIso8601() throws {

        // given
        let formatter = DateFormatter.iso8601
        let sample = "2022-01-20T11:52:41.707Z"

        // when
        let date = formatter.date(from: sample)
        var calendar = Calendar.current
        calendar.timeZone = TimeZone(identifier: "GMT+0")!
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date!)

        // then
        XCTAssertEqual(components.year, 2022)
        XCTAssertEqual(components.month, 1)
        XCTAssertEqual(components.day, 20)
        XCTAssertEqual(components.hour, 11)
        XCTAssertEqual(components.minute, 52)
        XCTAssertEqual(components.second, 41)
    }
    
    func testIso8601_With_TimeZone() throws {

        // given
        let formatter = DateFormatter.iso8601
        let sample = "2023-02-09T14:31:35.998716300+03:00"

        // when
        let date = formatter.date(from: sample)
        var calendar = Calendar.current
        calendar.timeZone = TimeZone(identifier: "GMT+3")!
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date!)

        // then
        XCTAssertEqual(components.year, 2023)
        XCTAssertEqual(components.month, 2)
        XCTAssertEqual(components.day, 9)
        XCTAssertEqual(components.hour, 14)
        XCTAssertEqual(components.minute, 31)
        XCTAssertEqual(components.second, 35)
    }

    func testDateAndTime() throws {

        // given
        let formatter = DateFormatter.dateAndTime
        let sample = "27.12.2021 18:22:58"

        // when
        let date = formatter.date(from: sample)
        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date!)

        // then
        XCTAssertEqual(components.year, 2021)
        XCTAssertEqual(components.month, 12)
        XCTAssertEqual(components.day, 27)
        XCTAssertEqual(components.hour, 18)
        XCTAssertEqual(components.minute, 22)
        XCTAssertEqual(components.second, 58)
    }
}
