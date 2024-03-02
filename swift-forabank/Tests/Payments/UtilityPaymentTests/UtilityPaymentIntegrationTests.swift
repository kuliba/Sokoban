//
//  UtilityPaymentIntegrationTests.swift
//
//
//  Created by Igor Malyarov on 02.03.2024.
//

import RxViewModel
import UtilityPayment
import XCTest

final class UtilityPaymentIntegrationTests: XCTestCase {
    
    func test_init_shouldNotCallCollaborators() {
        
        _ = makeSUT()
    }
    
    // MARK: - Helpers
    
    private typealias State = UtilityPaymentState
    private typealias Event = UtilityPaymentEvent
    private typealias Effect = UtilityPaymentEffect
    
    private typealias SUT = RxViewModel<State, Event, Effect>
    private typealias StateSpy = ValueSpy<State>
    
    private func makeSUT(
        initialState: State = .init(),
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        stateSpy: StateSpy
    ) {
        let reducer = UtilityPaymentReducer()
        let effectHandler = UtilityPaymentEffectHandler()
        
        let sut = SUT(
            initialState: initialState,
            reduce: reducer.reduce,
            handleEffect: effectHandler.handleEffect,
            scheduler: .immediate
        )
        let stateSpy = StateSpy(sut.$state)
        
        trackForMemoryLeaks(stateSpy, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(reducer, file: file, line: line)
        trackForMemoryLeaks(effectHandler, file: file, line: line)
        
        return (sut, stateSpy)
    }
    
    private func assert(
        _ spy: StateSpy,
        _ initialState: State,
        _ updates: ((inout State) -> Void)...,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        var state = initialState
        var values = [State]()
        
        for update in updates {
            
            update(&state)
            values.append(state)
        }
        
        XCTAssertNoDiff(spy.values, values, file: file, line: line)
    }
}
