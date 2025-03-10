//
//  Calendar+currentTimeStringTests.swift
//
//
//  Created by Igor Malyarov on 08.03.2025.
//

import Foundation

extension Calendar {
    
    /// Returns the current time formatted as a string (`HH:mm`).
    ///
    /// - Parameters:
    ///   - currentDate: Closure returning the current `Date`. Defaults to `Date.init`.
    ///   - separator: Separator between hour and minute. Defaults to ":".
    /// - Returns: Formatted time string (`HH:mm`), or `nil` if extraction fails.
    func currentTimeString(
        currentDate: @escaping () -> Date = Date.init,
        separator: String = ":"
    ) -> String? {
        
        let components = dateComponents([.hour, .minute], from: currentDate())
        
        guard
            let hour = components.hour,
            let minute = components.minute
        else { return nil }
        
        return String(format: "%02d%@%02d", hour, separator, minute)
    }
}

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
