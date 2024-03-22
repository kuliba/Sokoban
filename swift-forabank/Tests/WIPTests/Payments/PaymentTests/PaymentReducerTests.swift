//
//  PaymentReducerTests.swift
//
//
//  Created by Igor Malyarov on 21.03.2024.
//

import XCTest

final class PaymentReducerTests: XCTestCase {
    
    // MARK: SelectParameter
    
    func test_selectParameterEvent_toggleChevron_shouldNotCallParameterReduceWithParameterAndEventOnMissingSelectParameter() {
        
        let state = makeState()
        let event = selectEvent()
        let (sut, spy) = makeSUT()
        
        _ = sut.reduce(state, event)
        
        XCTAssertNoDiff(spy.payloads.map(\.0), [])
        XCTAssertNoDiff(spy.payloads.map(\.1), [])
        XCTAssertNil(parameter(withID: .select, in: state))
    }
    
    func test_selectParameterEvent_toggleChevron_shouldNotChangeStateOnMissingSelectParameter() {
        
        let state = makeState()
        let event = selectEvent()
        
        assertState(.parameter(event), on: state)
        XCTAssertNil(parameter(withID: .select, in: state))
        
    }
    
    func test_selectParameterEvent_toggleChevron_shouldNotDeliverEffectOnMissingSelectParameter() {
        
        let state = makeState()
        let event = selectEvent()
        
        assert(.parameter(event), on: state, effect: nil)
        XCTAssertNil(parameter(withID: .select, in: state))
    }
    
    func test_selectParameterEvent_toggleChevron_shouldCallParameterReduceWithParameterAndEventOnPresentSelectParameter() {
        
        let select = makeSelectParameter()
        let state = makeState(.select(select))
        let event = SelectParameterEvent.toggleChevron
        let (sut, spy) = makeSUT()
        
        _ = sut.reduce(state, .parameter(.select(event)))
        
        XCTAssertNoDiff(spy.payloads.map(\.0), [select])
        XCTAssertNoDiff(spy.payloads.map(\.1), [event])
        XCTAssertNotNil(parameter(withID: .select, in: state))
    }
    
    func test_selectParameterEvent_toggleChevron_shouldChangeSelectParameterOnPresentSelectParameter() {
        
        let newSelect = makeSelectParameter()
        let state = makeState(.select(makeSelectParameter()))
        let event = selectEvent()
        let (sut, _) = makeSUT(selectParameterReduceStub: (newSelect, .none))
        
        assertState(sut: sut, .parameter(event), on: state) {
            
            $0 = .init(parameters: [.select(newSelect)])
        }
        XCTAssertNotNil(parameter(withID: .select, in: state))
    }
    
    func test_selectParameterEvent_toggleChevron_shouldDeliverEffectOnPresentSelectParameter_nonNil() {
        
        let state = makeState(.select(makeSelectParameter()))
        let event = selectEvent()
        let effect = SelectParameterEffect.effect
        let (sut, _) = makeSUT(
            selectParameterReduceStub: (makeSelectParameter(), effect)
        )
        
        assert(sut: sut, .parameter(event), on: state, effect: .parameter(.select(effect)))
        XCTAssertNotNil(parameter(withID: .select, in: state))
    }
    
    func test_selectParameterEvent_toggleChevron_shouldNotDeliverEffectOnPresentSelectParameter_nil() {
        
        let state = makeState(.select(makeSelectParameter()))
        let event = selectEvent()
        let (sut, _) = makeSUT(
            selectParameterReduceStub: (makeSelectParameter(), nil)
        )
        
        assert(sut: sut, .parameter(event), on: state, effect: nil)
        XCTAssertNotNil(parameter(withID: .select, in: state))
    }
    
    // MARK: - Helpers
    
    private typealias SUT = PaymentReducer
    
    private typealias State = SUT.State
    private typealias Event = SUT.Event
    private typealias Effect = SUT.Effect
    
    private typealias ParameterReduceSpy = Spy<(PaymentParameter, PaymentParameterEvent), Void>
    private typealias ParameterReduceStub = (PaymentParameter, PaymentParameterEffect?)
    
    private typealias SelectParameterReduceSpy = Spy<(SelectParameter, SelectParameterEvent), Void>
    private typealias SelectParameterReduceStub = (SelectParameter, SelectParameterEffect?)
    
    private func makeSUT(
        selectParameterReduceStub: SelectParameterReduceStub? = nil,
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        selectParameterReduceSpy: SelectParameterReduceSpy
    ) {
        let parameterReduceStub = selectParameterReduceStub ?? makeParameterReduceStub()
        let selectParameterReduceSpy = SelectParameterReduceSpy()
        let sut = SUT(
            parameterReduce: .init(
                selectReduce: {
                    
                    selectParameterReduceSpy.process(($0, $1)) { _ in }
                    return parameterReduceStub
                }
            )
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(selectParameterReduceSpy, file: file, line: line)
        
        return (sut, selectParameterReduceSpy)
    }
    
    private func makeParameterReduceStub(
        _ parameter: PaymentParameter? = nil,
        _ effect: SelectParameterEffect? = nil
    ) -> SelectParameterReduceStub {
        
        (makeSelectParameter(), effect)
    }
    
    private func makeState(
        _ parameters: PaymentParameter...
    ) -> SUT.State {
        
        .init(parameters: parameters)
    }
    
    private func selectEvent(
        _ paymentParameterEvent: PaymentParameterEvent? = nil
    ) -> PaymentParameterEvent {
        
        paymentParameterEvent ?? .select(.toggleChevron)
    }
    
    private func makeSelectParameter(
        id: String = UUID().uuidString
    ) -> SelectParameter {
        
        .init(id: id)
    }
    
    private func parameter(
        withID id: PaymentParameter.ID,
        in state: SUT.State
    ) -> PaymentParameter? {
        
        state.parameters.first { $0.id == id }
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
        let sut = sut ?? makeSUT().sut
        
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
        let sut = sut ?? makeSUT().sut
        
        let (_, receivedEffect) = sut.reduce(state, event)
        
        XCTAssertNoDiff(
            receivedEffect,
            expectedEffect,
            "\nExpected \(String(describing: expectedEffect)), but got \(String(describing: receivedEffect)) instead.",
            file: file, line: line
        )
    }
}
