//
//  DateExtensionsTests.swift
//  ForaBankTests
//
//  Created by Max Gribov on 01.06.2022.
//

import XCTest
@testable import ForaBank

class DateExtensionsTests: XCTestCase {
    
    func testGroupDayIndex_Month_And_Day_Less_Ten() throws {
       
        // given
        let components = DateComponents(year: 2021, month: 3, day: 2, hour: 5, minute: 50, second: 44)
        guard let date = Calendar.current.date(from: components) else {
            XCTFail()
            return
        }
        
        // when
        let result = date.groupDayIndex
        
        // then
        XCTAssertEqual(result, 20210302)
    }
    
    func testGroupDayIndex_Month_And_Day_Greater_Ten() throws {
       
        // given
        let components = DateComponents(year: 2022, month: 11, day: 22, hour: 5, minute: 50, second: 44)
        guard let date = Calendar.current.date(from: components) else {
            XCTFail()
            return
        }
        
        // when
        let result = date.groupDayIndex
        
        // then
        XCTAssertEqual(result, 20221122)
    }
    
    func testGroupMonthIndex_Month_Less_Ten() throws {
       
        // given
        let components = DateComponents(year: 2021, month: 3, day: 2, hour: 5, minute: 50, second: 44)
        guard let date = Calendar.current.date(from: components) else {
            XCTFail()
            return
        }
        
        // when
        let result = date.groupMonthIndex
        
        // then
        XCTAssertEqual(result, 202103)
    }
    
    func testGroupMonthIndex_Month_Greater_Ten() throws {
       
        // given
        let components = DateComponents(year: 2022, month: 11, day: 22, hour: 5, minute: 50, second: 44)
        guard let date = Calendar.current.date(from: components) else {
            XCTFail()
            return
        }
        
        // when
        let result = date.groupMonthIndex
        
        // then
        XCTAssertEqual(result, 202211)
    }
}

//MARK: - Date UTC from Int seconds

extension DateExtensionsTests {
    
    func testDateUTC() throws {
        
        // given
        
        //Monday, 17 October 2022 20:29:02
        let miliseconds = 1666038542000
        
        // when
        let result = Date.dateUTC(with: miliseconds)
        
        // then
        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: result)
        XCTAssertEqual(components.year, 2022)
        XCTAssertEqual(components.month, 10)
        XCTAssertEqual(components.day, 17)
        XCTAssertEqual(components.hour, 20)
        XCTAssertEqual(components.minute, 29)
        XCTAssertEqual(components.second, 2)
    }
    
    func testSecondsSince1970() throws {
        
        // given
        let miliseconds = 1666038542000
        let date = Date.dateUTC(with: miliseconds)
        
        // when
        let result = date.secondsSince1970UTC
        
        // then
        XCTAssertEqual(result, miliseconds)
    }
}

