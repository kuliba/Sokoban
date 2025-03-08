//
//  SplashScreenTimePeriodTests.swift
//
//
//  Created by Igor Malyarov on 08.03.2025.
//

public struct SplashScreenTimePeriod: Equatable {
    
    let timePeriod: String
    let startTime: String
    let endTime: String
}

public extension Array where Element == SplashScreenTimePeriod {
    
    @inlinable
    func period(for timeString: String) -> Element? {
        
        first { $0.isMatch(for: timeString) }
    }
}

extension SplashScreenTimePeriod {
    
    @usableFromInline
    func isMatch(for timeString: String) -> Bool {
        
        (startTime...endTime).contains(timeString)
    }
}

#warning("move to Composition Root")
extension Array where Element == SplashScreenTimePeriod {
    
    static let `default`: Self = [
        .init(timePeriod: "MORNING", startTime: "04:00", endTime: "11:59"),
        .init(timePeriod: "DAY",     startTime: "12:00", endTime: "17:59"),
        .init(timePeriod: "EVENING", startTime: "18:00", endTime: "23:59"),
        .init(timePeriod: "NIGHT",   startTime: "00:00", endTime: "03:59"),
    ]
}

import XCTest

final class SplashScreenTimePeriodTests: XCTestCase {
    
    func test() {
        
        XCTAssertNoDiff(defaultPeriod(for: "00:00"), .night)
        XCTAssertNoDiff(defaultPeriod(for: "00:01"), .night)
        XCTAssertNoDiff(defaultPeriod(for: "03:58"), .night)
        XCTAssertNoDiff(defaultPeriod(for: "03:59"), .night)
        XCTAssertNoDiff(defaultPeriod(for: "04:00"), .morning)
        XCTAssertNoDiff(defaultPeriod(for: "04:01"), .morning)
        XCTAssertNoDiff(defaultPeriod(for: "11:58"), .morning)
        XCTAssertNoDiff(defaultPeriod(for: "11:59"), .morning)
        XCTAssertNoDiff(defaultPeriod(for: "12:00"), .day)
        XCTAssertNoDiff(defaultPeriod(for: "12:01"), .day)
        XCTAssertNoDiff(defaultPeriod(for: "17:58"), .day)
        XCTAssertNoDiff(defaultPeriod(for: "17:59"), .day)
        XCTAssertNoDiff(defaultPeriod(for: "18:00"), .evening)
        XCTAssertNoDiff(defaultPeriod(for: "18:01"), .evening)
        XCTAssertNoDiff(defaultPeriod(for: "23:58"), .evening)
        XCTAssertNoDiff(defaultPeriod(for: "23:59"), .evening)
        
        XCTAssertNil(defaultPeriod(for: ""))
        XCTAssertNil(defaultPeriod(for: "abc"))
        
        XCTAssertNil(defaultPeriod(for: "23:60"))
        XCTAssertNil(defaultPeriod(for: "03:60"))
        XCTAssertNil(defaultPeriod(for: "11:60"))
        XCTAssertNil(defaultPeriod(for: "17:60"))
        
        XCTAssertNoDiff(defaultPeriod(for: "01:62"), .night)
        XCTAssertNoDiff(defaultPeriod(for: "04:62"), .morning)
        XCTAssertNoDiff(defaultPeriod(for: "12:62"), .day)
        XCTAssertNoDiff(defaultPeriod(for: "18:62"), .evening)
    }
    
    // MARK: - Helpers
    
    private func defaultPeriod(
        for timeString: String
    ) -> String? {
        
        defaultPeriods().period(for: timeString)?.timePeriod
    }
    
    private func defaultPeriods() -> [SplashScreenTimePeriod] {
        
        return [
            .init(timePeriod: "MORNING", startTime: "04:00", endTime: "11:59"),
            .init(timePeriod: "DAY",     startTime: "12:00", endTime: "17:59"),
            .init(timePeriod: "EVENING", startTime: "18:00", endTime: "23:59"),
            .init(timePeriod: "NIGHT",   startTime: "00:00", endTime: "03:59"),
        ]
    }
}

private extension String {
    
    static let morning = "MORNING"
    static let day = "DAY"
    static let evening = "EVENING"
    static let night = "NIGHT"
}
