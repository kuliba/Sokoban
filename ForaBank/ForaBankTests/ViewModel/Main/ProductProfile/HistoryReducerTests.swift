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
        
        assertState(
            .button(.calendar),
            on: .init(buttonAction: .calendar, showSheet: false)
        ) {
            $0?.showSheet = true
        }
    }
    
    func test_history_reduce_button_filterEvent_shouldReturnShowSheetTrue() {
        
        assertState(
            .button(.filter),
            on: .init(buttonAction: .filter, showSheet: false)
        ) {
            $0?.showSheet = true
        }
    }
    
    func test_history_reduce_filter_shouldReturnShowSheetTrue() {
        
        assertState(
            .filter([.debit]),
            on: .init(filters: [.debit], buttonAction: .filter, showSheet: true)
        ) {
            $0?.showSheet = false
        }
    }
    
    func test_history_reduce_calendar_shouldReturnShowSheetTrue() {
        
        assertState(
            .calendar(nil),
            on: .init(date: nil, buttonAction: .calendar, showSheet: true)
        ) {
            $0?.showSheet = false
        }
    }
    
    //MARK: Helpers
    
    typealias SUT = HistoryReducer
    
    typealias State = SUT.State
    typealias Event = SUT.Event
    typealias Effect = SUT.Effect
    
    private func makeSUT(
    ) -> HistoryReducer {
        
        .init()
    }
    
    private typealias UpdateStateToExpected<State> = (_ state: inout State) -> Void
    
    private func assertState(
        sut: SUT? = nil,
        _ event: Event,
        on state: State,
        updateStateToExpected: UpdateStateToExpected<State>? = nil,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let sut = sut ?? makeSUT()
        
        var expectedState = state
        updateStateToExpected?(&expectedState)
        
        let (receivedState, _) = sut.reduce(state, event)
        
        XCTAssertNoDiff(
            receivedState,
            expectedState,
            "\nExpected \(expectedState), but got \(receivedState) instead.",
            file: file, line: line
        )
    }
}

extension ProductProfileFlowEffect {
    
    var effectTest: EffectTest {
        
        switch self {
        case .delayAlert:
            return .delayAlert
        case .delayBottomSheet:
            return .delayBottomSheet
        }
    }
    
    enum EffectTest: Equatable {
        
        case delayAlert
        case delayBottomSheet
    }
}
