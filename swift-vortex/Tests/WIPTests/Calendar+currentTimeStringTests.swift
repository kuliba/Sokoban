//
//  Calendar+currentTimeStringTests.swift
//
//
//  Created by Igor Malyarov on 08.03.2025.
//

import Foundation

extension Calendar {
    
    func currentTimeString(
        currentDate: @escaping () -> Date = Date.init,
        separator: String = ":"
    ) -> String {
        
        let components = dateComponents([.hour, .minute], from: currentDate())
        
        return String(
            format: "%02d%@%02d",
            components.hour ?? 0,
            separator,
            components.minute ?? 0
        )
    }
}

import XCTest

final class Calendar_currentTimeStringTests: XCTestCase {
    
    func test_shouldReturnCorrectTime() throws {
        
        try XCTAssertNoDiff(makeCurrentTimeString(hour: 14, minute: 23), "14:23")
    }
    
    func test_shouldHandleSingleDigitHours() throws {
        
        try XCTAssertNoDiff(makeCurrentTimeString(hour: 4, minute: 23), "04:23")
    }
    
    func test_shouldHandleSingleDigitMinutes() throws {
        
        try XCTAssertNoDiff(makeCurrentTimeString(hour: 14, minute: 5), "14:05")
    }
    
    // MARK: - Helpers
    
    private func makeCurrentTimeString(
        calendar: Calendar = .init(identifier: .gregorian),
        hour: Int,
        minute: Int,
        separator: String = ":",
        file: StaticString = #file,
        line: UInt = #line
    ) throws -> String {
        
        let components = DateComponents(
            calendar: calendar,
            hour: hour,
            minute: minute
        )
        
        let date = try XCTUnwrap(components.date, file: file, line: line)
        
        return calendar.currentTimeString(
            currentDate: { date },
            separator: separator
        )
    }
}
