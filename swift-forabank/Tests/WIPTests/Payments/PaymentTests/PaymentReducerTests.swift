//
//  PaymentReducerTests.swift
//
//
//  Created by Igor Malyarov on 21.03.2024.
//

import XCTest

final class PaymentReducerTests: XCTestCase {
    
    // MARK: InputParameter
    
    func test_inputParameterEvent_edit_shouldNotCallParameterReduceWithParameterAndEventOnMissingInputParameter() {
        
        let (state, event) = (makeState(), inputEvent())
        let (sut, inputSpy, _) = makeSUT()
        
        _ = sut.reduce(state, event)
        
        XCTAssertNoDiff(inputSpy.payloads.map(\.0), [])
        XCTAssertNoDiff(inputSpy.payloads.map(\.1), [])
        XCTAssertNil(parameter(withID: .input, in: state))
    }
    
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
    
    func test_inputParameterEvent_edit_shouldCallParameterReduceWithParameterAndEventOnPresentInputParameter() {
        
        let input = makeInputParameter()
        let state = makeState(.input(input))
        let event = InputParameterEvent.edit("abc123")
        let (sut, inputSpy, _) = makeSUT()
        
        _ = sut.reduce(state, .parameter(.input(event)))
        
        XCTAssertNoDiff(inputSpy.payloads.map(\.0), [input])
        XCTAssertNoDiff(inputSpy.payloads.map(\.1), [event])
        XCTAssertNotNil(parameter(withID: .input, in: state))
    }
    
    func test_inputParameterEvent_edit_shouldChangeInputParameterOnPresentInputParameter() {
        
        let newInput = makeInputParameter()
        let state = makeState(.input(makeInputParameter()))
        let event = inputEvent()
        let (sut, _,_) = makeSUT(inputParameterReduceStub: (newInput, .none))
        
        assertState(sut: sut, .parameter(event), on: state) {
            
            $0 = .init(parameters: [.input(newInput)])
        }
        XCTAssertNotNil(parameter(withID: .input, in: state))
    }
    
    func test_inputParameterEvent_edit_shouldDeliverEffectOnPresentInputParameter_nonNil() {
        
        let state = makeState(.input(makeInputParameter()))
        let event = inputEvent()
        let effect = InputParameterEffect.effect
        let (sut, _,_) = makeSUT(
            inputParameterReduceStub: (makeInputParameter(), effect)
        )
        
        assert(sut: sut, .parameter(event), on: state, effect: .parameter(.input(effect)))
        XCTAssertNotNil(parameter(withID: .input, in: state))
    }
    
    func test_inputParameterEvent_edit_shouldNotDeliverEffectOnPresentInputParameter_nil() {
        
        let state = makeState(.input(makeInputParameter()))
        let event = inputEvent()
        let (sut, _,_) = makeSUT(
            inputParameterReduceStub: (makeInputParameter(), nil)
        )
        
        assert(sut: sut, .parameter(event), on: state, effect: nil)
        XCTAssertNotNil(parameter(withID: .input, in: state))
    }
    
    // MARK: SelectParameter
    
    func test_selectParameterEvent_toggleChevron_shouldNotCallParameterReduceWithParameterAndEventOnMissingSelectParameter() {
        
        let (state, event) = (makeState(), selectEvent())
        let (sut, _, selectSpy) = makeSUT()
        
        _ = sut.reduce(state, event)
        
        XCTAssertNoDiff(selectSpy.payloads.map(\.0), [])
        XCTAssertNoDiff(selectSpy.payloads.map(\.1), [])
        XCTAssertNil(parameter(withID: .select, in: state))
    }
    
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
    
    func test_selectParameterEvent_toggleChevron_shouldCallParameterReduceWithParameterAndEventOnPresentSelectParameter() {
        
        let select = makeSelectParameter()
        let state = makeState(.select(select))
        let event = SelectParameterEvent.toggleChevron
        let (sut, _, selectSpy) = makeSUT()
        
        _ = sut.reduce(state, .parameter(.select(event)))
        
        XCTAssertNoDiff(selectSpy.payloads.map(\.0), [select])
        XCTAssertNoDiff(selectSpy.payloads.map(\.1), [event])
        XCTAssertNotNil(parameter(withID: .select, in: state))
    }
    
    func test_selectParameterEvent_toggleChevron_shouldChangeSelectParameterOnPresentSelectParameter() {
        
        let newSelect = makeSelectParameter()
        let state = makeState(.select(makeSelectParameter()))
        let event = selectEvent()
        let (sut, _,_) = makeSUT(selectParameterReduceStub: (newSelect, .none))
        
        assertState(sut: sut, .parameter(event), on: state) {
            
            $0 = .init(parameters: [.select(newSelect)])
        }
        XCTAssertNotNil(parameter(withID: .select, in: state))
    }
    
    func test_selectParameterEvent_toggleChevron_shouldDeliverEffectOnPresentSelectParameter_nonNil() {
        
        let state = makeState(.select(makeSelectParameter()))
        let event = selectEvent()
        let effect = SelectParameterEffect.effect
        let (sut, _,_) = makeSUT(
            selectParameterReduceStub: (makeSelectParameter(), effect)
        )
        
        assert(sut: sut, .parameter(event), on: state, effect: .parameter(.select(effect)))
        XCTAssertNotNil(parameter(withID: .select, in: state))
    }
    
    func test_selectParameterEvent_toggleChevron_shouldNotDeliverEffectOnPresentSelectParameter_nil() {
        
        let state = makeState(.select(makeSelectParameter()))
        let event = selectEvent()
        let (sut, _,_) = makeSUT(
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
    
    private typealias InputParameterReduceSpy = Spy<(InputParameter, InputParameterEvent), Void>
    private typealias InputParameterReduceStub = (InputParameter, InputParameterEffect?)
    
    private typealias SelectParameterReduceSpy = Spy<(SelectParameter, SelectParameterEvent), Void>
    private typealias SelectParameterReduceStub = (SelectParameter, SelectParameterEffect?)
    
    private func makeSUT(
        inputParameterReduceStub: InputParameterReduceStub? = nil,
        selectParameterReduceStub: SelectParameterReduceStub? = nil,
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        inputParameterReduceSpy: InputParameterReduceSpy,
        selectParameterReduceSpy: SelectParameterReduceSpy
    ) {
        let inputParameterReduceStub = inputParameterReduceStub ?? makeInputParameterReduceStub()
        let inputParameterReduceSpy = InputParameterReduceSpy()
        
        let selectParameterReduceStub = selectParameterReduceStub ?? makeSelectParameterReduceStub()
        let selectParameterReduceSpy = SelectParameterReduceSpy()
        
        let sut = SUT(
            parameterReduce: .init(
                inputReduce: {
                    
                    inputParameterReduceSpy.process(($0, $1)) { _ in }
                    return inputParameterReduceStub
                },
                selectReduce: {
                    
                    selectParameterReduceSpy.process(($0, $1)) { _ in }
                    return selectParameterReduceStub
                }
            )
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(inputParameterReduceSpy, file: file, line: line)
        trackForMemoryLeaks(selectParameterReduceSpy, file: file, line: line)
        
        return (sut, inputParameterReduceSpy, selectParameterReduceSpy)
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
    
    private func inputEvent(
        _ value: String = UUID().uuidString
    ) -> PaymentParameterEvent {
        
        .input(.edit(value))
    }
    
    private func selectEvent(
    ) -> PaymentParameterEvent {
        
        .select(.toggleChevron)
    }
    
    private func makeInputParameter(
        value: String = UUID().uuidString
    ) -> InputParameter {
        
        .init(value: value)
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
