//
//  TimePeriodTests.swift
//
//
//  Created by Igor Malyarov on 04.03.2025.
//

import GetSplashScreenServices
import RemoteServices
import XCTest

final class TimePeriodTests: XCTestCase {
    
    func test() {
        
        XCTAssertNoDiff(makeTimePeriods().period(for: ""), "DAY")
        XCTAssertNoDiff(makeTimePeriods().period(for: "abc"), "DAY")
        
        XCTAssertNoDiff(makeTimePeriods().period(for: "03:18"), "NIGHT")
        XCTAssertNoDiff(makeTimePeriods().period(for: "08:48"), "MORNING")
        XCTAssertNoDiff(makeTimePeriods().period(for: "12:28"), "DAY")
        XCTAssertNoDiff(makeTimePeriods().period(for: "22:28"), "EVENING")
    }
    
    // MARK: - Helpers
    
    private typealias TimePeriod = RemoteServices.ResponseMapper.SplashScreenTimePeriod
    
    private func makeTimePeriods() -> [TimePeriod] {
        
        return [
            .init(timePeriod: "MORNING", startTime: "04:00", endTime: "11:59"),
            .init(timePeriod: "DAY", startTime: "12:00", endTime: "17:59"),
            .init(timePeriod: "EVENING", startTime: "18:00", endTime: "23:59"),
            .init(timePeriod: "NIGHT", startTime: "00:00", endTime: "03:59"),
        ]
    }
}
