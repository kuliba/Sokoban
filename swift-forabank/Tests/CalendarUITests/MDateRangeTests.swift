//
//  MDateRangeTests.swift
//
//
//  Created by Дмитрий Савушкин on 18.06.2024.
//

import Foundation
import CalendarUI
import XCTest

final class MDateRangeTests: XCTestCase {

    func test_init_mDateRange_shouldReturnLowerAndUpperDate() {
        
        let sut = makeSUT()
        
        XCTAssertEqual(sut.lowerDate, .init(timeIntervalSince1970: 0))
        XCTAssertEqual(sut.upperDate, .init(timeIntervalSince1970: 0))
    }
    
    func test_addToRange_shouldReturnUpdatedDate() {
        
        let sut = makeSUT()

        XCTAssertEqual(sut.lowerDate, .init(timeIntervalSince1970: 0))
        XCTAssertEqual(sut.upperDate, .init(timeIntervalSince1970: 0))
        
        sut.addToRange(.init(timeIntervalSince1970: 1000))
        
        XCTAssertEqual(sut.lowerDate, .init(timeIntervalSince1970: 1000))
        XCTAssertEqual(sut.upperDate, nil)
    }
    
    func test_addToRange_shouldReturnUpdatedUpperDate() {
        
        let sut = makeSUT(endDate: nil)

        XCTAssertEqual(sut.lowerDate, .init(timeIntervalSince1970: 0))
        XCTAssertEqual(sut.upperDate, nil)
        
        sut.addToRange(.init(timeIntervalSince1970: 1000))
        
        XCTAssertEqual(sut.lowerDate, .init(timeIntervalSince1970: 0))
        XCTAssertEqual(sut.upperDate, .init(timeIntervalSince1970: 0))
    }
    
    func test_addToRange_shouldReturnUpdatedLowerDate() {
        
        let sut = makeSUT(startDate: nil, endDate: nil)

        XCTAssertEqual(sut.lowerDate, nil)
        XCTAssertEqual(sut.upperDate, nil)
        
        sut.addToRange(.init(timeIntervalSince1970: 1000))
        
        XCTAssertEqual(sut.lowerDate, .init(timeIntervalSince1970: 1000))
        XCTAssertEqual(sut.upperDate, nil)
    }
    
    //Helpers
    
    func makeSUT(
        startDate: Date? = .init(timeIntervalSince1970: 0),
        endDate: Date? = .init(timeIntervalSince1970: 0),
        file: StaticString = #file,
        line: UInt = #line
    ) -> MDateRange {
        
        let range = MDateRange(
            startDate: startDate,
            endDate: endDate
        )
        
        return range
    }
}
