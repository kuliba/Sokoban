//
//  DefaultPaymentReducerTests.swift
//
//
//  Created by Igor Malyarov on 21.03.2024.
//

import XCTest

final class DefaultPaymentReducerTests: XCTestCase {
    
    // MARK: InputParameter
    
    func test_inputParameterEvent_edit_shouldNotChangeStateOnMissingInputParameter() {
        
        let (state, event) = (makeState(), inputEvent())
        
        assertState(.parameter(event), on: state)
        XCTAssertNil(parameter(withID: .input, in: state))
    }
    
    func test_inputParameterEvent_edit_shouldNotDeliverEffectOnMissingInputParameter() {
        
        let (state, event) = (makeState(), inputEvent())
        
        assert(.parameter(event), on: state, effect: nil)
        XCTAssertNil(parameter(withID: .input, in: state))
    }
    
    func test_inputParameterEvent_edit_shouldChangeInputParameterOnPresentInputParameter() {
        
        let state = makeState(.input(makeInputParameter()))
        let event = inputEvent()
        let sut = makeSUT()
        
        assertState(sut: sut, .parameter(event), on: state)
        XCTAssertNotNil(parameter(withID: .input, in: state))
    }
    
    func test_inputParameterEvent_edit_shouldNotDeliverEffectOnPresentInputParameter_nonNil() {
        
        let state = makeState(.input(makeInputParameter()))
        let event = inputEvent()
        let sut = makeSUT()
        
        assert(sut: sut, .parameter(event), on: state, effect: nil)
        XCTAssertNotNil(parameter(withID: .input, in: state))
    }
    
    func test_inputParameterEvent_edit_shouldNotDeliverEffectOnPresentInputParameter_nil() {
        
        let state = makeState(.input(makeInputParameter()))
        let event = inputEvent()
        let sut = makeSUT()
        
        assert(sut: sut, .parameter(event), on: state, effect: nil)
        XCTAssertNotNil(parameter(withID: .input, in: state))
    }
    
    // MARK: SelectParameter
    
    func test_selectParameterEvent_toggleChevron_shouldNotChangeStateOnMissingSelectParameter() {
        
        let (state, event) = (makeState(), selectEvent())
        
        assertState(.parameter(event), on: state)
        XCTAssertNil(parameter(withID: .select, in: state))
    }
    
    func test_selectParameterEvent_toggleChevron_shouldNotDeliverEffectOnMissingSelectParameter() {
        
        let (state, event) = (makeState(), selectEvent())
        
        assert(.parameter(event), on: state, effect: nil)
        XCTAssertNil(parameter(withID: .select, in: state))
    }
    
    func test_selectParameterEvent_toggleChevron_shouldNotChangeSelectParameterOnPresentSelectParameter() {
        
        let state = makeState(.select(makeSelectParameter()))
        let event = selectEvent()
        let sut = makeSUT()
        
        assertState(sut: sut, .parameter(event), on: state)
        XCTAssertNotNil(parameter(withID: .select, in: state))
    }
    
    func test_selectParameterEvent_toggleChevron_shouldNotDeliverEffectOnPresentSelectParameter_nonNil() {
        
        let state = makeState(.select(makeSelectParameter()))
        let event = selectEvent()
        let sut = makeSUT()
        
        assert(sut: sut, .parameter(event), on: state, effect: nil)
        XCTAssertNotNil(parameter(withID: .select, in: state))
    }
    
    func test_selectParameterEvent_toggleChevron_shouldNotDeliverEffectOnPresentSelectParameter_nil() {
        
        let state = makeState(.select(makeSelectParameter()))
        let event = selectEvent()
        let sut = makeSUT()
        
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
    
    private typealias InputParameterReduceStub = (InputParameter, InputParameterEffect?)
    
    private typealias SelectParameterReduceStub = (SelectParameter, SelectParameterEffect?)
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> SUT {
        
        let sut = SUT(parameterReduce: .default)
        
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return sut
    }
    
    private func makeInputParameterReduceStub(
        _ effect: InputParameterEffect? = nil
    ) -> InputParameterReduceStub {
        
        (makeInputParameter(), effect)
    }
    
    private func makeSelectParameterReduceStub(
        _ effect: SelectParameterEffect? = nil
    ) -> SelectParameterReduceStub {
        
        (makeSelectParameter(), effect)
    }
    
    private func makeState(
        _ parameters: PaymentParameter...
    ) -> SUT.State {
        
        .init(parameters: parameters)
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
    
    private func assert(
        sut: SUT? = nil,
        _ event: Event,
        on state: State,
        effect expectedEffect: Effect?,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let sut = sut ?? makeSUT()
        
        let (_, receivedEffect) = sut.reduce(state, event)
        
        XCTAssertNoDiff(
            receivedEffect,
            expectedEffect,
            "\nExpected \(String(describing: expectedEffect)), but got \(String(describing: receivedEffect)) instead.",
            file: file, line: line
        )
    }
}
