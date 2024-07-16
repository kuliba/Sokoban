//
//  MDateFormatterTests.swift
//
//
//  Created by Дмитрий Савушкин on 18.06.2024.
//

import Foundation
import CalendarUI
import XCTest

final class MDateFormatterTests: XCTestCase {

    func test_mDateFormatter_getString_shouldReturnFormattedDate() {
        
        let dateFormatter = MDateFormatter.getString(
            from: .init(timeIntervalSince1970: 0),
            format: "MMMM y"
        )
        
        XCTAssertEqual(dateFormatter, "Январь 1970")
    }
    
    func test_mDateFormatter_getString_weekDay_shouldReturnFullDateString() {
        
        let dateString = MDateFormatter.getString(for: .friday, format: .full)
        
        XCTAssertEqual(dateString, "Friday")
    }
    
    func test_mDateFormatter_getString_weekDay_shouldReturnShortDateString() {
        
        let dateString = MDateFormatter.getString(for: .friday, format: .short)
        
        XCTAssertEqual(dateString, "Fr")
    }
    
    func test_mDateFormatter_getString_weekDay_shouldReturnVeryShortDateString() {
        
        let dateString = MDateFormatter.getString(for: .friday, format: .veryShort)
        
        XCTAssertEqual(dateString, "F")
    }
}


