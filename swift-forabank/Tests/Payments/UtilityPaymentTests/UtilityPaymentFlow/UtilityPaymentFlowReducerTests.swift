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
    
    // MARK: - PrePaymentOptionsEvent
    
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
        let event: Event = .prePaymentOptions(.initiate)
        let (ppoStateStub, ppoEffectStub) = makePPOStub(
            lastPaymentsCount: 1,
            operatorsCount: 3,
            searchText: "abc",
            ppoEffect: .search("abc")
        )
        let (sut, _,_) = makeSUT(ppoStub: [(ppoStateStub, ppoEffectStub)])
        
        assertState(sut: sut, event, on: state) {
            
            $0 = self.makeState(.prePaymentOptions(ppoStateStub))
        }
    }
    
    func test_prePaymentOptionsEvent_shouldDeliverPrePaymentOptionsReduceEffect() {
        
        let prePaymentOptions = makePrePaymentOptionsState()
        let state = makeState(.prePaymentOptions(prePaymentOptions))
        let event: Event = .prePaymentOptions(.initiate)
        let ppoStateStub = makePrePaymentOptionsState(
            lastPaymentsCount: 1,
            operatorsCount: 3,
            searchText: "abc"
        )
        let ppoEffectStub: PPOEffect = .search("abc")
        let (sut, _,_) = makeSUT(ppoStub: [(ppoStateStub, ppoEffectStub)])
        
        assert(sut: sut, event, on: state, effect: .prePaymentOptions(ppoEffectStub))
    }
    
    func test_prePaymentOptionsEvent_shouldChangeInflightOnPrePaymentOptionsInlight() {
        
        let prePaymentOptions = makePrePaymentOptionsState()
        let state = makeState(.prePaymentOptions(prePaymentOptions))
        let event: Event = .prePaymentOptions(.initiate)
        let ppoStateStub = makePrePaymentOptionsState(
            lastPaymentsCount: 1,
            operatorsCount: 3,
            searchText: "abc",
            isInflight: true
        )
        let ppoEffectStub: PPOEffect = .search("abc")
        let (sut, _,_) = makeSUT(ppoStub: [(ppoStateStub, ppoEffectStub)])
        
        assertState(sut: sut, event, on: state) {
            
            $0 = self.makeState(.prePaymentOptions(ppoStateStub), isInflight: true)
        }
    }
    
    // MARK: - addCompany
    
    func test_prePaymentEvent_addCompany_shouldChangePrePaymentOptionsStateToPrePaymentStateAddingCompany() {
        
        let state = makeState(.prePaymentOptions(makePrePaymentOptionsState()))
        
        assertState(.prePayment(.addCompany), on: state) {
            
            $0.current = .prePaymentState(.addingCompany)
        }
    }
    
    func test_prePaymentEvent_addCompany_shouldNotDeliverEffectOnPrePaymentOptionsState() {
        
        let state = makeState(.prePaymentOptions(makePrePaymentOptionsState()))
        
        assert(.prePayment(.addCompany), on: state, effect: nil)
    }
    
    func test_prePaymentEvent_addCompany_shouldNotChangePrePaymentState_addingCompany() {
        
        let state = makeState(
            .prePaymentOptions(makePrePaymentOptionsState()),
            .prePaymentState(.addingCompany)
        )
        
        assertState(.prePayment(.addCompany), on: state)
    }
    
    func test_prePaymentEvent_addCompany_shouldNotDeliverEffectOnPrePaymentState_addingCompany() {
        
        let state = makeState(
            .prePaymentOptions(makePrePaymentOptionsState()),
            .prePaymentState(.addingCompany)
        )
        
        assert(.prePayment(.addCompany), on: state, effect: nil)
    }
    
    func test_prePaymentEvent_addCompany_shouldNotChangePrePaymentState_payingByInstruction() {
        
        let state = makeState(
            .prePaymentOptions(makePrePaymentOptionsState()),
            .prePaymentState(.payingByInstruction)
        )
        
        assertState(.prePayment(.addCompany), on: state)
    }
    
    func test_prePaymentEvent_addCompany_shouldNotDeliverEffectOnPrePaymentState_payingByInstruction() {
        
        let state = makeState(
            .prePaymentOptions(makePrePaymentOptionsState()),
            .prePaymentState(.payingByInstruction)
        )
        
        assert(.prePayment(.addCompany), on: state, effect: nil)
    }
    
    func test_prePaymentEvent_addCompany_shouldNotChangePrePaymentState_scanning() {
        
        let state = makeState(
            .prePaymentOptions(makePrePaymentOptionsState()),
            .prePaymentState(.scanning)
        )
        
        assertState(.prePayment(.addCompany), on: state)
    }
    
    func test_prePaymentEvent_addCompany_shouldNotDeliverEffectOnPrePaymentState_scanning() {
        
        let state = makeState(
            .prePaymentOptions(makePrePaymentOptionsState()),
            .prePaymentState(.scanning)
        )
        
        assert(.prePayment(.addCompany), on: state, effect: nil)
    }
    
    // MARK: - back
    
    func test_prePaymentEvent_back_shouldChangeStateToEmptyOnPrePaymentOptions() {
        
        let state = makeState(.prePaymentOptions(makePrePaymentOptionsState()))
        
        assertState(.prePayment(.back), on: state) {
            
            $0.current = nil
        }
    }
    
    func test_prePaymentEvent_back_shouldNotDeliverEffectOnPrePaymentOptionsState() {
        
        let state = makeState(.prePaymentOptions(makePrePaymentOptionsState()))
        
        assert(.prePayment(.back), on: state, effect: nil)
    }
    
    func test_prePaymentEvent_back_shouldNotChangePrePaymentState_addingCompany() {
        
        let state = makeState(
            .prePaymentOptions(makePrePaymentOptionsState()),
            .prePaymentState(.addingCompany)
        )
        
        assertState(.prePayment(.back), on: state)
    }
    
    func test_prePaymentEvent_back_shouldNotDeliverEffectOnPrePaymentState_addingCompany() {
        
        let state = makeState(
            .prePaymentOptions(makePrePaymentOptionsState()),
            .prePaymentState(.addingCompany)
        )
        
        assert(.prePayment(.back), on: state, effect: nil)
    }
    
    func test_prePaymentEvent_back_shouldChangePrePaymentStateToPrePaymentOptions_payingByInstruction() {
        
        let prePaymentOptions: Flow = .prePaymentOptions(makePrePaymentOptionsState())
        let state = makeState(
            prePaymentOptions,
            .prePaymentState(.payingByInstruction)
        )
        
        assertState(.prePayment(.back), on: state) {
            
            $0 = .init([prePaymentOptions])
        }
    }
    
    func test_prePaymentEvent_back_shouldNotDeliverEffectOnPrePaymentState_payingByInstruction() {
        
        let state = makeState(
            .prePaymentOptions(makePrePaymentOptionsState()),
            .prePaymentState(.payingByInstruction)
        )
        
        assert(.prePayment(.back), on: state, effect: nil)
    }
    
    func test_prePaymentEvent_back_shouldChangePrePaymentStateToPrePaymentOptions_scanning() {
        
        let prePaymentOptions: Flow = .prePaymentOptions(makePrePaymentOptionsState())
        let state = makeState(
            prePaymentOptions,
            .prePaymentState(.scanning)
        )
        
        assertState(.prePayment(.back), on: state){
            
            $0 = .init([prePaymentOptions])
        }
    }
    
    func test_prePaymentEvent_back_shouldNotDeliverEffectOnPrePaymentState_scanning() {
        
        let state = makeState(
            .prePaymentOptions(makePrePaymentOptionsState()),
            .prePaymentState(.scanning)
        )
        
        assert(.prePayment(.back), on: state, effect: nil)
    }
    
    // MARK: - payByInstruction
    
    func test_prePaymentEvent_payByInstruction_shouldChangePrePaymentOptionsStateToPrePaymentStatePayingByInstruction() {
        
        let state = makeState(.prePaymentOptions(makePrePaymentOptionsState()))
        
        assertState(.prePayment(.payByInstruction), on: state) {
            
            $0.current = .prePaymentState(.payingByInstruction)
        }
    }
    
    func test_prePaymentEvent_payByInstruction_shouldNotDeliverEffectOnPrePaymentOptionsState() {
        
        let state = makeState(.prePaymentOptions(makePrePaymentOptionsState()))
        
        assert(.prePayment(.payByInstruction), on: state, effect: nil)
    }
    
    func test_prePaymentEvent_payByInstruction_shouldNotChangePrePaymentState_addingCompany() {
        
        let state = makeState(
            .prePaymentOptions(makePrePaymentOptionsState()),
            .prePaymentState(.addingCompany)
        )
        
        assertState(.prePayment(.payByInstruction), on: state)
    }
    
    func test_prePaymentEvent_payByInstruction_shouldNotDeliverEffectOnPrePaymentState_addingCompany() {
        
        let state = makeState(
            .prePaymentOptions(makePrePaymentOptionsState()),
            .prePaymentState(.addingCompany)
        )
        
        assert(.prePayment(.payByInstruction), on: state, effect: nil)
    }
    
    func test_prePaymentEvent_payByInstruction_shouldNotChangePrePaymentState_payingByInstruction() {
        
        let state = makeState(
            .prePaymentOptions(makePrePaymentOptionsState()),
            .prePaymentState(.payingByInstruction)
        )
        
        assertState(.prePayment(.payByInstruction), on: state)
    }
    
    func test_prePaymentEvent_payByInstruction_shouldNotDeliverEffectOnPrePaymentState_payingByInstruction() {
        
        let state = makeState(
            .prePaymentOptions(makePrePaymentOptionsState()),
            .prePaymentState(.payingByInstruction)
        )
        
        assert(.prePayment(.payByInstruction), on: state, effect: nil)
    }
    
    func test_prePaymentEvent_payByInstruction_shouldNotChangePrePaymentState_scanning() {
        
        let state = makeState(
            .prePaymentOptions(makePrePaymentOptionsState()),
            .prePaymentState(.scanning)
        )
        
        assertState(.prePayment(.payByInstruction), on: state)
    }
    
    func test_prePaymentEvent_payByInstruction_shouldNotDeliverEffectOnPrePaymentState_scanning() {
        
        let state = makeState(
            .prePaymentOptions(makePrePaymentOptionsState()),
            .prePaymentState(.scanning)
        )
        
        assert(.prePayment(.payByInstruction), on: state, effect: nil)
    }
    
    // MARK: - scan
    
    func test_prePaymentEvent_scan_shouldNotChangePrePaymentState_addingCompany() {
        
        let state = makeState(
            .prePaymentOptions(makePrePaymentOptionsState()),
            .prePaymentState(.addingCompany)
        )
        
        assertState(.prePayment(.scan), on: state)
    }
    
    func test_prePaymentEvent_scan_shouldNotDeliverEffectOnPrePaymentState_addingCompany() {
        
        let state = makeState(
            .prePaymentOptions(makePrePaymentOptionsState()),
            .prePaymentState(.addingCompany)
        )
        
        assert(.prePayment(.scan), on: state, effect: nil)
    }
    
    func test_prePaymentEvent_scan_shouldNotChangePrePaymentState_payingByInstruction() {
        
        let state = makeState(
            .prePaymentOptions(makePrePaymentOptionsState()),
            .prePaymentState(.payingByInstruction)
        )
        
        assertState(.prePayment(.scan), on: state)
    }
    
    func test_prePaymentEvent_scan_shouldNotDeliverEffectOnPrePaymentState_payingByInstruction() {
        
        let state = makeState(
            .prePaymentOptions(makePrePaymentOptionsState()),
            .prePaymentState(.payingByInstruction)
        )
        
        assert(.prePayment(.scan), on: state, effect: nil)
    }
    
    func test_prePaymentEvent_scan_shouldNotChangePrePaymentState_scanning() {
        
        let state = makeState(
            .prePaymentOptions(makePrePaymentOptionsState()),
            .prePaymentState(.scanning)
        )
        
        assertState(.prePayment(.scan), on: state)
    }
    
    func test_prePaymentEvent_scan_shouldNotDeliverEffectOnPrePaymentState_scanning() {
        
        let state = makeState(
            .prePaymentOptions(makePrePaymentOptionsState()),
            .prePaymentState(.scanning)
        )
        
        assert(.prePayment(.scan), on: state, effect: nil)
    }
    
    func test_prePaymentEvent_scan_shouldChangePrePaymentOptionsStateTo_____() {
        
        let state = makeState(.prePaymentOptions(makePrePaymentOptionsState()))
        
        assertState(.prePayment(.scan), on: state) {
            
            $0.current = .prePaymentState(.scanning)
        }
    }
    
    func test_prePaymentEvent_scan_shouldNotDeliverEffectOnPrePaymentOptionsState() {
        
        let state = makeState(.prePaymentOptions(makePrePaymentOptionsState()))
        
        assert(.prePayment(.scan), on: state, effect: nil)
    }
    
    // MARK: - select
    
    func test_prePaymentEvent_selectLastPayment_shouldChangeStateToInflightOnPrePaymentOptionsState() {
        
        let state = makeState(.prePaymentOptions(makePrePaymentOptionsState()))
        
        assertState(selectLastPayment(), on: state) { $0.isInflight = true }
    }
    
    func test_prePaymentEvent_selectLastPayment_shouldDeliverStartPaymentEffectOnPrePaymentOptionsState() {
        
        let state = makeState(.prePaymentOptions(makePrePaymentOptionsState()))
        
        assert(selectLastPayment(), on: state, effect: .prePayment(.startPayment))
    }
    
    func test_prePaymentEvent_selectOperator_shouldChangeStateToInflightOnPrePaymentOptionsState() {
        
        let state = makeState(.prePaymentOptions(makePrePaymentOptionsState()))
        
        assertState(selectOperator(), on: state) { $0.isInflight = true }
    }
    
    func test_prePaymentEvent_selectOperator_shouldDeliverStartPaymentEffectOnPrePaymentOptionsState() {
        
        let state = makeState(.prePaymentOptions(makePrePaymentOptionsState()))
        
        assert(selectOperator(), on: state, effect: .prePayment(.startPayment))
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
    
    private typealias PPState = SUT.PPState
    private typealias PPEvent = SUT.PPEvent
    private typealias PPEffect = SUT.PPEffect
    private typealias PrePaymentReducer = ReducerSpy<PPState, PPEvent, PPEffect>
    
    private func makeSUT(
        ppoStub: [(PPOState, PPOEffect?)] = [(.init(), nil)],
        prePaymentStub: [(PPState, PPEffect?)] = [],
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
    
    private func makePPOStub(
        lastPaymentsCount: Int? = nil,
        operatorsCount: Int? = nil,
        searchText: String = "",
        isInflight: Bool = false,
        ppoEffect: PPOEffect? = nil
    ) -> (PPOState, PPOEffect?) {
        
        let ppoState = makePrePaymentOptionsState(
            lastPaymentsCount: lastPaymentsCount,
            operatorsCount: operatorsCount,
            searchText: searchText,
            isInflight: isInflight
        )
        
        return (ppoState, ppoEffect)
    }
    
    private func makePrePaymentOptionsState(
        lastPaymentsCount: Int? = nil,
        operatorsCount: Int? = nil,
        searchText: String = "",
        isInflight: Bool = false
    ) -> PPOState {
        
        .init(
            lastPayments: lastPaymentsCount.map {
                (0..<$0).map { _ in makeLastPayment() }
            },
            operators: operatorsCount.map {
                (0..<$0).map { _ in makeOperator() }
            },
            searchText: searchText,
            isInflight: isInflight
        )
    }
    
    private func makeState(
        _ flows: Flow...,
        isInflight: Bool = false
    ) -> State {
        
        .init(flows, isInflight: isInflight)
    }
    
    private func selectLastPayment(
        _ lastPayment: LastPayment? = nil
    ) -> Event {
        
        .prePayment(.select(.last(lastPayment ?? makeLastPayment())))
    }
    
    private func selectOperator(
        _ `operator`: Operator? = nil
    ) -> Event {
        
        .prePayment(.select(.operator(`operator` ?? makeOperator())))
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
