//
//  UtilityPaymentFlowReducerTests.swift
//
//
//  Created by Igor Malyarov on 08.03.2024.
//

import PrePaymentPicker
import UtilityPayment
import XCTest

final class UtilityPaymentFlowReducerTests: XCTestCase {
    
    func test_init_shouldNotCallCollaborators() {
        
        let (_, ppoReducer, prePaymentReducer) = makeSUT()
        
        XCTAssertEqual(ppoReducer.callCount, 0)
        XCTAssertEqual(prePaymentReducer.callCount, 0)
    }
    
    // MARK: - PrePaymentOptions
    
    func test_prePaymentOptionsEvent_shouldCallPrePaymentOptionsReducerOnPrePaymentOptionsState_didScrollTo() {
        
        let prePaymentOptions = makePrePaymentOptionsState()
        let state = makeState(.prePaymentOptions(prePaymentOptions))
        let prePaymentOptionsEvent: PPOEvent = .didScrollTo("abc")
        let (sut, ppoReducer, _) = makeSUT()
        
        _ = sut.reduce(state, .prePaymentOptions(prePaymentOptionsEvent))
        
        XCTAssertNoDiff(ppoReducer.messages.map(\.state), [prePaymentOptions])
        XCTAssertNoDiff(ppoReducer.messages.map(\.event), [prePaymentOptionsEvent])
    }
    
    func test_prePaymentOptionsEvent_shouldCallPrePaymentOptionsReducerOnPrePaymentOptionsState_initiate() {
        
        let prePaymentOptions = makePrePaymentOptionsState()
        let state = makeState(.prePaymentOptions(prePaymentOptions))
        let prePaymentOptionsEvent: PPOEvent = .initiate
        let (sut, ppoReducer, _) = makeSUT()
        
        _ = sut.reduce(state, .prePaymentOptions(prePaymentOptionsEvent))
        
        XCTAssertNoDiff(ppoReducer.messages.map(\.state), [prePaymentOptions])
        XCTAssertNoDiff(ppoReducer.messages.map(\.event), [prePaymentOptionsEvent])
    }
    
    func test_prePaymentOptionsEvent_shouldCallPrePaymentOptionsReducerOnPrePaymentOptionsState_loaded() {
        
        let prePaymentOptions = makePrePaymentOptionsState()
        let state = makeState(.prePaymentOptions(prePaymentOptions))
        let prePaymentOptionsEvent: PPOEvent = .loaded(
            .failure(.connectivityError),
            .failure(.connectivityError)
        )
        let (sut, ppoReducer, _) = makeSUT()
        
        _ = sut.reduce(state, .prePaymentOptions(prePaymentOptionsEvent))
        
        XCTAssertNoDiff(ppoReducer.messages.map(\.state), [prePaymentOptions])
        XCTAssertNoDiff(ppoReducer.messages.map(\.event), [prePaymentOptionsEvent])
    }
    
    func test_prePaymentOptionsEvent_shouldCallPrePaymentOptionsReducerOnPrePaymentOptionsState_paginated() {
        
        let prePaymentOptions = makePrePaymentOptionsState()
        let state = makeState(.prePaymentOptions(prePaymentOptions))
        let prePaymentOptionsEvent: PPOEvent = .paginated(
            .failure(.connectivityError)
        )
        let (sut, ppoReducer, _) = makeSUT()
        
        _ = sut.reduce(state, .prePaymentOptions(prePaymentOptionsEvent))
        
        XCTAssertNoDiff(ppoReducer.messages.map(\.state), [prePaymentOptions])
        XCTAssertNoDiff(ppoReducer.messages.map(\.event), [prePaymentOptionsEvent])
    }
    
    func test_prePaymentOptionsEvent_shouldCallPrePaymentOptionsReducerOnPrePaymentOptionsState_search() {
        
        let prePaymentOptions = makePrePaymentOptionsState()
        let state = makeState(.prePaymentOptions(prePaymentOptions))
        let prePaymentOptionsEvent: PPOEvent = .search(.entered(""))
        let (sut, ppoReducer, _) = makeSUT()
        
        _ = sut.reduce(state, .prePaymentOptions(prePaymentOptionsEvent))
        
        XCTAssertNoDiff(ppoReducer.messages.map(\.state), [prePaymentOptions])
        XCTAssertNoDiff(ppoReducer.messages.map(\.event), [prePaymentOptionsEvent])
    }
    
    func test_prePaymentOptionsEvent_shouldNotCallPrePaymentOptionsReducerOnPrePaymentState_addingCompany() {
        
        let state = makeState(.prePaymentState(.addingCompany))
        let prePaymentOptionsEvent: PPOEvent = .initiate
        let (sut, ppoReducer, _) = makeSUT()
        
        _ = sut.reduce(state, .prePaymentOptions(prePaymentOptionsEvent))
        
        XCTAssertEqual(ppoReducer.callCount, 0)
    }
    
    func test_prePaymentOptionsEvent_shouldChangePrePaymentOptionsStateToPrePaymentOptionsReduceResult() {
        
        let prePaymentOptions = makePrePaymentOptionsState()
        let state = makeState(.prePaymentOptions(prePaymentOptions))
        let ppoState = makePrePaymentOptionsState(
            lastPayments: [makeLastPayment()],
            operators: [makeOperator(), makeOperator()],
            searchText: "abc"
        )
        let ppoEffect: PPOEffect = .search("abc")
        let (sut, _,_) = makeSUT(ppoStub: [(ppoState, ppoEffect)])
        
        let (newState, newEffect) = sut.reduce(state, .prePaymentOptions(.initiate))

        XCTAssertNoDiff(newState, makeState(.prePaymentOptions(ppoState)))
        XCTAssertNoDiff(newEffect, .prePaymentOptions(ppoEffect))
    }
    
    // MARK: - Helpers
    
    private typealias SUT = UtilityPaymentFlowReducer<LastPayment, Operator>
    
    private typealias State = SUT.State
    private typealias Event = SUT.Event
    private typealias Effect = SUT.Effect
    
    private typealias Flow = SUT.State.Flow
    
    private typealias PPOState = SUT.PPOState
    private typealias PPOEvent = SUT.PPOEvent
    private typealias PPOEffect = SUT.PPOEffect
    private typealias PPOReducer = ReducerSpy<PPOState, PPOEvent, PPOEffect>
    
    private typealias PrePaymentReducer = ReducerSpy<PrePaymentState, PrePaymentEvent, PrePaymentEffect>
    
    private func makeSUT(
        ppoStub: [(PPOState, PPOEffect?)] = [(.init(), nil)],
        prePaymentStub: [(PrePaymentState, PrePaymentEffect?)] = [],
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        ppoReducer: PPOReducer,
        prePaymentReducer: PrePaymentReducer
    ) {
        let ppoReducer = PPOReducer(stub: ppoStub)
        let prePaymentReducer = PrePaymentReducer(stub: prePaymentStub)
        let sut = SUT(
            prePaymentOptionsReduce: ppoReducer.reduce,
            prePaymentReduce: prePaymentReducer.reduce
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(ppoReducer, file: file, line: line)
        trackForMemoryLeaks(prePaymentReducer, file: file, line: line)
        
        return (sut, ppoReducer, prePaymentReducer)
    }
    
    private func makeLastPayment(
        value: String = UUID().uuidString
    ) -> LastPayment {
        
        .init(value: value)
    }
    
    private func makeOperator(
        value: String = UUID().uuidString
    ) -> Operator {
        
        .init(value: value)
    }
    
    private func makePrePaymentOptionsState(
        lastPayments: [LastPayment]? = nil,
        operators: [Operator]? = nil,
        searchText: String = "",
        isInflight: Bool = false
    ) -> PPOState {
        
        .init(
            lastPayments: lastPayments,
            operators: operators,
            searchText: searchText,
            isInflight: isInflight
        )
    }
    
    private func makeState(
        _ flow: Flow
    ) -> State {
        
        .init(initialFlow: flow)
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
        let sut = sut ?? makeSUT(file: file, line: line).sut
        
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
    
    private func assert(
        sut: SUT? = nil,
        _ event: Event,
        on state: State,
        effect expectedEffect: Effect?,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let sut = sut ?? makeSUT(file: file, line: line).sut
        let (_, receivedEffect) = sut.reduce(state, event)
        
        XCTAssertNoDiff(
            receivedEffect,
            expectedEffect,
            "\nExpected \(String(describing: expectedEffect)), but got \(String(describing: receivedEffect)) instead.",
            file: file, line: line
        )
    }
}

private struct LastPayment: Equatable {
    
    var value: String
}

private struct Operator: Equatable, Identifiable {
    
    var value: String
    
    var id: String { value }
}
