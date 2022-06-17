//
//  PeriodTests.swift
//  ForaBankTests
//
//  Created by Max Gribov on 09.06.2022.
//

import XCTest
@testable import ForaBank

class PeriodTests: XCTestCase {

    let calendar = Calendar.current
    
    func testDaysBack() throws {
        
        // given
        let referenceDate = Date.date(year: 2022, month: 3, day: 10, calendar: calendar)!
        
        // when
        let result = Period(daysBack: 5, from: referenceDate)
        
        // then
        let resultStart = calendar.dateComponents([.year, .month, .day], from: result.start)
        XCTAssertEqual(resultStart.year, 2022)
        XCTAssertEqual(resultStart.month, 3)
        XCTAssertEqual(resultStart.day, 5)
        
        let resultEnd = calendar.dateComponents([.year, .month, .day], from: result.end)
        XCTAssertEqual(resultEnd.year, 2022)
        XCTAssertEqual(resultEnd.month, 3)
        XCTAssertEqual(resultEnd.day, 10)
    }
    
    func testIncluding_EldestPeriod() throws {
        
        // given
        let initialStartDate = Date.date(year: 2022, month: 3, day: 10, calendar: calendar)!
        let initialEndDate = Date.date(year: 2022, month: 5, day: 10, calendar: calendar)!
        let initialPeriod = Period(start: initialStartDate, end: initialEndDate)
        
        let otherStartDate = Date.date(year: 2022, month: 2, day: 10, calendar: calendar)!
        let otherEndDate = Date.date(year: 2022, month: 3, day: 10, calendar: calendar)!
        let otherPeriod = Period(start: otherStartDate, end: otherEndDate)
        
        // when
        let result = initialPeriod.including(otherPeriod)
        
        // then
        let resultStart = calendar.dateComponents([.year, .month, .day], from: result.start)
        XCTAssertEqual(resultStart.year, 2022)
        XCTAssertEqual(resultStart.month, 2)
        XCTAssertEqual(resultStart.day, 10)
        
        let resultEnd = calendar.dateComponents([.year, .month, .day], from: result.end)
        XCTAssertEqual(resultEnd.year, 2022)
        XCTAssertEqual(resultEnd.month, 5)
        XCTAssertEqual(resultEnd.day, 10)
    }
    
    func testIncluding_LatestPeriod() throws {
        
        // given
        let initialStartDate = Date.date(year: 2022, month: 3, day: 10, calendar: calendar)!
        let initialEndDate = Date.date(year: 2022, month: 5, day: 10, calendar: calendar)!
        let initialPeriod = Period(start: initialStartDate, end: initialEndDate)
        
        let otherStartDate = Date.date(year: 2022, month: 5, day: 10, calendar: calendar)!
        let otherEndDate = Date.date(year: 2022, month: 6, day: 10, calendar: calendar)!
        let otherPeriod = Period(start: otherStartDate, end: otherEndDate)
        
        // when
        let result = initialPeriod.including(otherPeriod)
        
        // then
        let resultStart = calendar.dateComponents([.year, .month, .day], from: result.start)
        XCTAssertEqual(resultStart.year, 2022)
        XCTAssertEqual(resultStart.month, 3)
        XCTAssertEqual(resultStart.day, 10)
        
        let resultEnd = calendar.dateComponents([.year, .month, .day], from: result.end)
        XCTAssertEqual(resultEnd.year, 2022)
        XCTAssertEqual(resultEnd.month, 6)
        XCTAssertEqual(resultEnd.day, 10)
    }
}

fileprivate extension Date {
    
    static func date(year: Int, month: Int, day: Int, calendar: Calendar) -> Date? {
        
        let components = DateComponents(year: year, month: month, day: day)
        return calendar.date(from: components)
    }
}
