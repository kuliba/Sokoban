//
//  CalendarViewModelTests.swift
//  
//
//  Created by Дмитрий Савушкин on 16.05.2024.
//

import Foundation
import CalendarUI
import XCTest

final class CalendarViewModelTests: XCTestCase {

    func test_init_calendarViewModel_shouldReturnDateAndRage() {
        
        let date = Date(timeIntervalSince1970: 0)
        let viewModel = CalendarViewModel(
            date, .init(startDate: date, endDate: date)
        )
        
        XCTAssertEqual(viewModel.date, .init(timeIntervalSince1970: 0))
        XCTAssertEqual(viewModel.range?.lowerDate, .init(timeIntervalSince1970: 0))
        XCTAssertEqual(viewModel.range?.upperDate, .init(timeIntervalSince1970: 0))
    }
    
    func test_init_calendarViewModel_shouldReturnDateNil() {
        
        let startDate = Date(timeIntervalSince1970: 0)
        let endDate = Date(timeIntervalSince1970: 1000)
        
        let viewModel = CalendarViewModel(
            nil, .init(startDate: startDate, endDate: endDate)
        )
        
        XCTAssertEqual(viewModel.date, nil)
        XCTAssertEqual(viewModel.range?.lowerDate, .init(timeIntervalSince1970: 0))
        XCTAssertEqual(viewModel.range?.upperDate, .init(timeIntervalSince1970: 1000))
    }
    
    func test_init_calendarViewModel_shouldReturnRangeDateNil() {
        
        let date = Date(timeIntervalSince1970: 0)
        
        let viewModel = CalendarViewModel(date, nil)
        
        XCTAssertEqual(viewModel.date, .init(timeIntervalSince1970: 0))
        XCTAssertEqual(viewModel.range?.lowerDate, nil)
        XCTAssertEqual(viewModel.range?.upperDate, nil)
    }
}

