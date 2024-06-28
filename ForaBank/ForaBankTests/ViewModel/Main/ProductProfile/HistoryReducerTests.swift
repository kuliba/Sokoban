//
//  HistoryReducerTests.swift
//  ForaBankTests
//
//  Created by Дмитрий Савушкин on 27.06.2024.
//

import Foundation
@testable import ForaBank
import XCTest

final class HistoryReducerTests: XCTestCase {
    
    func test_history_reduce_button_calendarEvent_shouldReturnShowSheetTrue() {
        
        let sut = makeSUT(
            state: makeState(showSheet: false),
            event: .button(.calendar)
        )
        XCTAssertNoDiff(sut.0?.showSheet, true)
        XCTAssertNoDiff(sut.0?.buttonAction, .calendar)
    }
    
    func test_history_reduce_button_filterEvent_shouldReturnShowSheetTrue() {
        
        let sut = makeSUT(
            state: makeState(showSheet: false),
            event: .button(.filter)
        )
        XCTAssertNoDiff(sut.0?.showSheet, true)
        XCTAssertNoDiff(sut.0?.buttonAction, .filter)
    }
    
    func test_history_reduce_filter_shouldReturnShowSheetTrue() {
        
        let sut = makeSUT(
            state: makeState(showSheet: true),
            event: .filter([.debit])
        )
        XCTAssertNoDiff(sut.0?.showSheet, false)
        XCTAssertNoDiff(sut.0?.buttonAction, .filter)
        XCTAssertNoDiff(sut.0?.filters, [.debit])
    }
    
    func test_history_reduce_calendar_shouldReturnShowSheetTrue() {
        
        let sut = makeSUT(
            state: makeState(showSheet: true),
            event: .calendar(nil)
        )
        XCTAssertNoDiff(sut.0?.showSheet, false)
        XCTAssertNoDiff(sut.0?.buttonAction, .calendar)
        XCTAssertNoDiff(sut.0?.date, nil)
    }
    
    //MARK: Helpers
    
    private func makeSUT(
        state: HistoryReducer.State,
        event: HistoryReducer.Event
    ) -> (HistoryReducer.State, HistoryReducer.Effect?) {
        
        HistoryReducer().reduce(state, event)
    }
    
    private func makeState(showSheet: Bool) -> HistoryReducer.State {
        .init(buttonAction: .calendar, showSheet: showSheet)
    }
}
