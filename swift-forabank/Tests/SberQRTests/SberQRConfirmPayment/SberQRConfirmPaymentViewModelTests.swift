//
//  SberQRConfirmPaymentViewModelTests.swift
//
//
//  Created by Igor Malyarov on 08.12.2023.
//

import CombineSchedulers
import SberQR
import XCTest

final class SberQRConfirmPaymentViewModelTests: XCTestCase {
    
    func test_init_shouldSetInitialState_fixed() {
        
        let initialState: SUT.State = .init(
            confirm: .fixedAmount(makeFixedAmount(
                productSelect: .compact(.test2)
            ))
        )
        let (_, spy, _) = makeSUT(initialState: initialState)
        
        XCTAssertNoDiff(spy.values, [initialState])
    }
    
    func test_init_shouldSetInitialState_editable() {
        
        let initialState: SUT.State = .init(
            confirm: .editableAmount(makeEditableAmount(
                productSelect: .compact(.test2)
            ))
        )
        let (_, spy, _) = makeSUT(initialState: initialState)
        
        XCTAssertNoDiff(spy.values, [initialState])
    }
    
    func test_event_pay_shouldCallReducerWithEvent_fixed() {
        
        let event: SUT.Event = .pay
        let initialState: SUT.State = .init(confirm: .fixedAmount(makeFixedAmount()))
        let (sut, _, reducerSpy) = makeSUT(initialState: initialState)
        
        sut.event(event)
        
        XCTAssertNoDiff(reducerSpy.states, [initialState])
        XCTAssertNoDiff(reducerSpy.events, [event])
    }
    
    func test_event_pay_shouldCallReducerWithEvent_editable() {
        
        let event: SUT.Event = .pay
        let initialState: SUT.State = .init(confirm: .editableAmount(makeEditableAmount()))
        let (sut, _, reducerSpy) = makeSUT(initialState: initialState)
        
        sut.event(event)
        
        XCTAssertNoDiff(reducerSpy.states, [initialState])
        XCTAssertNoDiff(reducerSpy.events, [event])
    }
    
    func test_event_pay_shouldChangeStateByReducer_fixed() {
        
        let event: SUT.Event = .pay
        let initialState: SUT.State = .init(confirm: .fixedAmount(makeFixedAmount()))
        let newState: SUT.State = .init(confirm: .editableAmount(makeEditableAmount()))
        let (sut, spy, _) = makeSUT(
            initialState: initialState,
            reducerStub: newState
        )
        
        sut.event(event)
        
        XCTAssertNoDiff(spy.values, [initialState, newState])
    }
    
    func test_event_pay_shouldChangeStateByReducer_editable() {
        
        let event: SUT.Event = .pay
        let initialState: SUT.State = .init(confirm: .editableAmount(makeEditableAmount()))
        let newState: SUT.State = .init(confirm: .editableAmount(makeEditableAmount()))
        let (sut, spy, _) = makeSUT(
            initialState: initialState,
            reducerStub: newState
        )
        
        sut.event(event)
        
        XCTAssertNoDiff(spy.values, [initialState, newState])
    }
    
    func test_event_pay_shouldNotChangeStateTwice_fixed() {
        
        let event: SUT.Event = .pay
        let initialState: SUT.State = .init(confirm: .fixedAmount(makeFixedAmount()))
        let newState: SUT.State = .init(confirm: .editableAmount(makeEditableAmount()))
        let (sut, spy, _) = makeSUT(
            initialState: initialState,
            reducerStub: newState
        )
        
        sut.event(event)
        sut.event(event)
        
        XCTAssertNoDiff(spy.values, [initialState, newState])
    }
    
    func test_event_pay_shouldNotChangeStateTwice_editable() {
        
        let event: SUT.Event = .pay
        let initialState: SUT.State = .init(confirm: .editableAmount(makeEditableAmount()))
        let newState: SUT.State = .init(confirm: .editableAmount(makeEditableAmount()))
        let (sut, spy, _) = makeSUT(
            initialState: initialState,
            reducerStub: newState
        )
        
        sut.event(event)
        sut.event(event)
        
        XCTAssertNoDiff(spy.values, [initialState, newState])
    }
    
    // MARK: - Helpers
    
    private typealias SUT = SberQRConfirmPaymentViewModel
    private typealias Spy = ValueSpy<SUT.State>
    private typealias ReduceSpy = ReducerSpy<SUT.State, SUT.Event>
    
    private func makeSUT(
        initialState: SUT.State = .init(confirm: .fixedAmount(makeFixedAmount())),
        reducerStub: SUT.State = .init(confirm: .fixedAmount(makeFixedAmount())),
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        spy: Spy,
        reducerSpy: ReduceSpy
    ) {
        let reducerSpy = ReduceSpy(stub: reducerStub)
        let sut = SUT(
            initialState: initialState,
            reduce: reducerSpy.reduce(state:event:),
            scheduler: .immediate
        )
        let spy = ValueSpy(sut.$state)
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(spy, file: file, line: line)
        
        return (sut, spy, reducerSpy)
    }
}
