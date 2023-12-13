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
        
        let initialState: SUT.State = .fixedAmount(makeFixedAmount(
            productSelect: .compact(.test2)
        ))
        let (_, spy, _) = makeSUT(initialState: initialState)
        
        XCTAssertNoDiff(spy.values, [initialState])
    }
    
    func test_init_shouldSetInitialState_editable() {
        
        let initialState: SUT.State = .editableAmount(makeEditableAmount(
            productSelect: .compact(.test2)
        ))
        let (_, spy, _) = makeSUT(initialState: initialState)
        
        XCTAssertNoDiff(spy.values, [initialState])
    }
    
    func test_event_pay_shouldCallReducerWithEvent_fixed() {
        
        let initialState: SUT.State = .fixedAmount(makeFixedAmount())
        let event: SUT.Event = .fixed(.pay)
        let (sut, _, reducerSpy) = makeSUT(initialState: initialState)
        
        sut.event(event)
        
        XCTAssertNoDiff(reducerSpy.states, [initialState])
        XCTAssertNoDiff(reducerSpy.events, [event])
    }
    
    func test_event_pay_shouldCallReducerWithEvent_editable() {
        
        let initialState: SUT.State = .editableAmount(makeEditableAmount())
        let event: SUT.Event = .editable(.pay)
        let (sut, _, reducerSpy) = makeSUT(initialState: initialState)
        
        sut.event(event)
        
        XCTAssertNoDiff(reducerSpy.states, [initialState])
        XCTAssertNoDiff(reducerSpy.events, [event])
    }
    
    func test_event_pay_shouldChangeStateByReducer_fixed() {
        
        let initialState: SUT.State = .fixedAmount(makeFixedAmount())
        let newState: SUT.State = .editableAmount(makeEditableAmount())
        let event: SUT.Event = .fixed(.pay)
        let (sut, spy, _) = makeSUT(
            initialState: initialState,
            reducerStub: newState
        )
        
        sut.event(event)
        
        XCTAssertNoDiff(spy.values, [initialState, newState])
    }
    
    func test_event_pay_shouldChangeStateByReducer_editable() {
        
        let initialState: SUT.State = .editableAmount(makeEditableAmount())
        let newState: SUT.State = .editableAmount(makeEditableAmount())
        let event: SUT.Event = .editable(.pay)
        let (sut, spy, _) = makeSUT(
            initialState: initialState,
            reducerStub: newState
        )
        
        sut.event(event)
        
        XCTAssertNoDiff(spy.values, [initialState, newState])
    }
    
    func test_event_pay_shouldNorChangeStateTwice_fixed() {
        
        let initialState: SUT.State = .fixedAmount(makeFixedAmount())
        let newState: SUT.State = .editableAmount(makeEditableAmount())
        let event: SUT.Event = .fixed(.pay)
        let (sut, spy, _) = makeSUT(
            initialState: initialState,
            reducerStub: newState
        )
        
        sut.event(event)
        sut.event(event)
        
        XCTAssertNoDiff(spy.values, [initialState, newState])
    }
    
    func test_event_pay_shouldNorChangeStateTwice_editable() {
        
        let initialState: SUT.State = .editableAmount(makeEditableAmount())
        let newState: SUT.State = .editableAmount(makeEditableAmount())
        let event: SUT.Event = .editable(.pay)
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
    
    private func makeSUT(
        initialState: SUT.State = .fixedAmount(makeFixedAmount()),
        reducerStub: SUT.State = .fixedAmount(makeFixedAmount()),
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        spy: Spy,
        reducerSpy: ReducerSpy
    ) {
        let reducerSpy = ReducerSpy(stub: reducerStub)
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
    
    private final class ReducerSpy {
        
        private(set) var payloads = [(state: SUT.State, event: SUT.Event)]()
        private let stub: SUT.State
        
        var states: [SUT.State] { payloads.map(\.state) }
        var events: [SUT.Event] { payloads.map(\.event) }
        
        init(stub: SUT.State) {
            
            self.stub = stub
        }
        
        func reduce(
            state: SUT.State,
            event: SUT.Event
        ) -> SUT.State {
            
            payloads.append((state, event))
            
            return stub
        }
    }
}
