//
//  Calendar+currentTimeStringTests.swift
//  
//
//  Created by Igor Malyarov on 12.03.2025.
//

import VortexTools
import XCTest

final class Calendar_currentTimeStringTests: XCTestCase {
    
    func test_shouldReturnCorrectTime() throws {
        
        try XCTAssertNoDiff(currentTimeString(hour: 14, minute: 23), "14:23")
    }
    
    func test_shouldHandleSingleDigitHours() throws {
        
        try XCTAssertNoDiff(currentTimeString(hour: 4, minute: 23), "04:23")
    }
    
    func test_shouldHandleSingleDigitMinutes() throws {
        
        try XCTAssertNoDiff(currentTimeString(hour: 14, minute: 5), "14:05")
    }
    
    func test_shouldFormatMidnight() throws {
        
        try XCTAssertNoDiff(currentTimeString(hour: 0, minute: 0), "00:00")
    }
    
    func test_shouldFormatBeforeMidnight() throws {
        
        try XCTAssertNoDiff(currentTimeString(hour: 23, minute: 59), "23:59")
    }
    
    func test_shouldHandleCustomSeparator() throws {
        
        try XCTAssertNoDiff(
            currentTimeString(hour: 9, minute: 7, separator: "-"),
            "09-07"
        )
    }
    
    // MARK: - Helpers
    
    private func currentTimeString(
        calendar: Calendar = .init(identifier: .gregorian),
        timeZone: TimeZone? = .init(secondsFromGMT: 0),
        hour: Int,
        minute: Int,
        separator: String = ":",
        file: StaticString = #file,
        line: UInt = #line
    ) throws -> String {
        
        var calendar = calendar
        calendar.timeZone = try XCTUnwrap(timeZone, file: file, line: line)
        
        let components = DateComponents(
            calendar: calendar,
            year: 2025,
            month: 1,
            day: 1,
            hour: hour,
            minute: minute
        )
        
        let date = try XCTUnwrap(components.date, file: file, line: line)
        
        return try XCTUnwrap(
            calendar.currentTimeString(
                currentDate: { date },
                separator: separator
            ),
            file: file, line: line
        )
    }
}
