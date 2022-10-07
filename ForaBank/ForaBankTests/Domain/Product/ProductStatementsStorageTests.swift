//
//  ProductStatementsStorageTests.swift
//  ForaBankTests
//
//  Created by Max Gribov on 09.06.2022.
//

import XCTest
@testable import ForaBank

class ProductStatementsStorageTests: XCTestCase {
    
    let calendar = Calendar.current

    func testLatestPeriod() throws {
        
        // given
        let startDate = Date.date(year: 2022, month: 4, day: 10, calendar: calendar)!
        let endDate = Date.date(year: 2022, month: 5, day: 10, calendar: calendar)!
        
        let initialPeriod = Period(start: startDate, end: endDate)
        let storage = ProductStatementsStorage(period: initialPeriod, statements: [])
        
        let limitDate = Date.date(year: 2022, month: 6, day: 1, calendar: calendar)!
        
        // when
        guard let result = storage.latestPeriod(days: 5, limitDate: limitDate) else {
            XCTFail()
            return
        }
        
        // then
        let resultStart = calendar.dateComponents([.year, .month, .day], from: result.start)
        XCTAssertEqual(resultStart.year, 2022)
        XCTAssertEqual(resultStart.month, 5)
        XCTAssertEqual(resultStart.day, 10)
        
        let resultEnd = calendar.dateComponents([.year, .month, .day], from: result.end)
        XCTAssertEqual(resultEnd.year, 2022)
        XCTAssertEqual(resultEnd.month, 5)
        XCTAssertEqual(resultEnd.day, 15)
    }
    
    func testLatestPeriod_Limit_Hitted() throws {
        
        // given
        let startDate = Date.date(year: 2022, month: 4, day: 10, calendar: calendar)!
        let endDate = Date.date(year: 2022, month: 5, day: 10, calendar: calendar)!
        
        let initialPeriod = Period(start: startDate, end: endDate)
        let storage = ProductStatementsStorage(period: initialPeriod, statements: [])
        
        let limitDate = Date.date(year: 2022, month: 6, day: 1, calendar: calendar)!
        
        // when
        guard let result = storage.latestPeriod(days: 100, limitDate: limitDate) else {
            XCTFail()
            return
        }
        
        // then
        let resultStart = calendar.dateComponents([.year, .month, .day], from: result.start)
        XCTAssertEqual(resultStart.year, 2022)
        XCTAssertEqual(resultStart.month, 5)
        XCTAssertEqual(resultStart.day, 10)
        
        let resultEnd = calendar.dateComponents([.year, .month, .day], from: result.end)
        XCTAssertEqual(resultEnd.year, 2022)
        XCTAssertEqual(resultEnd.month, 6)
        XCTAssertEqual(resultEnd.day, 1)
    }
    
    func testLatestPeriod_Limit_Incorrect() throws {
        
        // given
        let startDate = Date.date(year: 2022, month: 4, day: 10, calendar: calendar)!
        let endDate = Date.date(year: 2022, month: 5, day: 10, calendar: calendar)!
        
        let initialPeriod = Period(start: startDate, end: endDate)
        let storage = ProductStatementsStorage(period: initialPeriod, statements: [])
        
        let limitDate = Date.date(year: 2022, month: 3, day: 1, calendar: calendar)!
        
        // when
        let result = storage.latestPeriod(days: 100, limitDate: limitDate)
        
        // then
        XCTAssertNil(result)
    }
    
    func testEldestPeriod() throws {
        
        // given
        let startDate = Date.date(year: 2022, month: 4, day: 10, calendar: calendar)!
        let endDate = Date.date(year: 2022, month: 5, day: 10, calendar: calendar)!
        
        let initialPeriod = Period(start: startDate, end: endDate)
        let storage = ProductStatementsStorage(period: initialPeriod, statements: [])
        
        let limitDate = Date.date(year: 2022, month: 1, day: 1, calendar: calendar)!
        
        // when
        guard let result = storage.eldestPeriod(days: 5, limitDate: limitDate) else {
            XCTFail()
            return
        }
        
        // then
        let resultStart = calendar.dateComponents([.year, .month, .day], from: result.start)
        XCTAssertEqual(resultStart.year, 2022)
        XCTAssertEqual(resultStart.month, 4)
        XCTAssertEqual(resultStart.day, 5)
        
        let resultEnd = calendar.dateComponents([.year, .month, .day], from: result.end)
        XCTAssertEqual(resultEnd.year, 2022)
        XCTAssertEqual(resultEnd.month, 4)
        XCTAssertEqual(resultEnd.day, 10)
    }
    
    func testEldestPeriod_Limit_Hitted() throws {
        
        // given
        let startDate = Date.date(year: 2022, month: 4, day: 10, calendar: calendar)!
        let endDate = Date.date(year: 2022, month: 5, day: 10, calendar: calendar)!
        
        let initialPeriod = Period(start: startDate, end: endDate)
        let storage = ProductStatementsStorage(period: initialPeriod, statements: [])
        
        let limitDate = Date.date(year: 2022, month: 1, day: 1, calendar: calendar)!
        
        // when
        guard let result = storage.eldestPeriod(days: 100, limitDate: limitDate) else {
            XCTFail()
            return
        }
        
        // then
        let resultStart = calendar.dateComponents([.year, .month, .day], from: result.start)
        XCTAssertEqual(resultStart.year, 2022)
        XCTAssertEqual(resultStart.month, 1)
        XCTAssertEqual(resultStart.day, 1)
        
        let resultEnd = calendar.dateComponents([.year, .month, .day], from: result.end)
        XCTAssertEqual(resultEnd.year, 2022)
        XCTAssertEqual(resultEnd.month, 4)
        XCTAssertEqual(resultEnd.day, 10)
    }
    
    func testEldestPeriod_Limit_Incorrect() throws {
        
        // given
        let startDate = Date.date(year: 2022, month: 4, day: 10, calendar: calendar)!
        let endDate = Date.date(year: 2022, month: 5, day: 10, calendar: calendar)!
        
        let initialPeriod = Period(start: startDate, end: endDate)
        let storage = ProductStatementsStorage(period: initialPeriod, statements: [])
        
        let limitDate = Date.date(year: 2022, month: 5, day: 1, calendar: calendar)!
        
        // when
        let result = storage.eldestPeriod(days: 100, limitDate: limitDate)
        
        // then
        XCTAssertNil(result)
    }
    
    //MARK: - isHistoryComplete
    
    func testIsHistoryComplete_With_Update_Eldest_True() {
        
        // given
        let startDate = Date.date(year: 2022, month: 4, day: 10, calendar: calendar)!
        let endDate = Date.date(year: 2022, month: 5, day: 10, calendar: calendar)!
        
        let period = Period(start: startDate, end: endDate)
        
        let limitDate = Date.date(year: 2022, month: 4, day: 10, calendar: calendar)!
        let update = ProductStatementsStorage.Update(period: period, statements: [], direction: .eldest, limitDate: limitDate, override: false)
        
        // when
        let result = ProductStatementsStorage(with: update, historyLimitDate: limitDate).isHistoryComplete
        
        // then
        XCTAssertTrue(result)
    }
    
    func testIsHistoryComplete_With_Update_Eldest_False() {
        
        // given
        let startDate = Date.date(year: 2022, month: 4, day: 10, calendar: calendar)!
        let endDate = Date.date(year: 2022, month: 5, day: 10, calendar: calendar)!
        
        let period = Period(start: startDate, end: endDate)
        
        let limitDate = Date.date(year: 2022, month: 3, day: 10, calendar: calendar)!
        let update = ProductStatementsStorage.Update(period: period, statements: [], direction: .eldest, limitDate: limitDate, override: false)
        
        // when
        let result = ProductStatementsStorage(with: update, historyLimitDate: limitDate)
        
        // then
        XCTAssertFalse(result.isHistoryComplete)
    }
    
    func testIsHistoryComplete_With_Update_Latest_True() {
        
        // given
        let startDate = Date.date(year: 2022, month: 4, day: 10, calendar: calendar)!
        let endDate = Date.date(year: 2022, month: 6, day: 10, calendar: calendar)!
        
        let period = Period(start: startDate, end: endDate)
        
        let limitDate = Date.date(year: 2022, month: 5, day: 10, calendar: calendar)!
        let update = ProductStatementsStorage.Update(period: period, statements: [], direction: .latest, limitDate: limitDate, override: false)
        
        // when
        let result = ProductStatementsStorage(with: update, historyLimitDate: limitDate).isHistoryComplete
        
        // then
        XCTAssertTrue(result)
    }
}

fileprivate extension Date {
    
    static func date(year: Int, month: Int, day: Int, calendar: Calendar) -> Date? {
        
        let components = DateComponents(year: year, month: month, day: day)
        return calendar.date(from: components)
    }
}
