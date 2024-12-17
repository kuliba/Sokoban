//
//  CalendarExtensionsTests.swift
//  ForaBankTests
//
//  Created by Max Gribov on 14.06.2022.
//

import XCTest
@testable import ForaBank

class CalendarExtensionsTests: XCTestCase {

    let calendar = Calendar.current

    func testNumberOfDaysBetween_Positive() throws {
     
        // given
        let startDate = Date.date(year: 2022, month: 6, day: 1, calendar: calendar)!
        let endDate = Date.date(year: 2022, month: 6, day: 28, calendar: calendar)!
        
        // when
        let result = calendar.numberOfDaysBetween(startDate, and: endDate)
        
        // then
        XCTAssertEqual(result, 27)
    }
    
    func testNumberOfDaysBetween_Negative() throws {
     
        // given
        let startDate = Date.date(year: 2022, month: 6, day: 20, calendar: calendar)!
        let endDate = Date.date(year: 2022, month: 6, day: 5, calendar: calendar)!
        
        // when
        let result = calendar.numberOfDaysBetween(startDate, and: endDate)
        
        // then
        XCTAssertEqual(result, -15)
    }
}
