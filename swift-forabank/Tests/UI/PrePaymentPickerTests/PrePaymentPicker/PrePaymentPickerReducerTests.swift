//
//  PrePaymentPickerReducerTests.swift
//
//
//  Created by Igor Malyarov on 02.03.2024.
//

import PrePaymentPicker
import XCTest

final class PrePaymentPickerReducerTests: XCTestCase {
    
    func test_init_shouldNotCallCollaborators() {
        
        let (_, spy) = makeSUT(stub: (.init(), nil))
        
        XCTAssertEqual(spy.callCount, 0)
    }
    
    func test_optionsEvent_shouldCallOptionsReduceOnOptionsState() {
        
        let optionsState: SUT.OptionsState = .init()
        let optionsEvents: [SUT.OptionsEvent] = [
            .didScrollTo("abc"),
            .initiate,
            .loaded(.failure(.connectivityError), .failure(.connectivityError)),
            .loaded(.success([]), .success([])),
            .paginated(.failure(.connectivityError)),
            .paginated(.success([])),
            .search(.entered("123")),
            .search(.updated("456")),
        ]
        let (sut, spy) = makeSUT(stub: (.init(), nil))
        
        for optionsEvent in optionsEvents {
            
            _ = sut.reduce(.options(optionsState), .options(optionsEvent))
        }
        
        XCTAssertNoDiff(spy.states, .init(repeating: optionsState, count: optionsEvents.count))
        XCTAssertNoDiff(spy.events, optionsEvents)
    }
    
    func test_optionsEvent_shouldDeliverOptionsReduceResult() {
        
        let optionsState = makeOptionsState(lastPayments: [
            makeLastPayment(), makeLastPayment()
        ])
        let optionsEffect: SUT.OptionsEffect = .initiate
        let (sut, _) = makeSUT(stub: (optionsState, optionsEffect))
        
        let (state, effect) = sut.reduce(.options(makeOptionsState()), .options(.initiate))
        
        XCTAssertNoDiff(state, .options(optionsState))
        XCTAssertNoDiff(effect, .options(optionsEffect))
    }
    
    func test_optionsEvent_shouldNotChangeSelectedState() {
        
        let selectedState = selectedState()
        let optionsState = makeOptionsState(lastPayments: [makeLastPayment()])
        let optionsEffect: SUT.OptionsEffect = .initiate
        let (sut, _) = makeSUT(stub: (optionsState, optionsEffect))

        let (state, effect) = sut.reduce(selectedState, .options(.initiate))
        
        XCTAssertNoDiff(state, selectedState)
        XCTAssertNil(effect)
    }
    
    func test_selectEvent_shouldNotChangeSelectedState_lastPayment() {
        
        let selectedState = selectedState()
        let selectedEvent = SUT.Event.select(.lastPayment(makeLastPayment()))
        let optionsState = makeOptionsState(lastPayments: [makeLastPayment()])
        let optionsEffect: SUT.OptionsEffect = .initiate
        let (sut, _) = makeSUT(stub: (optionsState, optionsEffect))

        let (state, effect) = sut.reduce(selectedState, selectedEvent)
        
        XCTAssertNoDiff(state, selectedState)
        XCTAssertNil(effect)
    }
    
    func test_selectEvent_shouldNotChangeSelectedState_operator() {
        
        let selectedState = selectedState()
        let selectedEvent = SUT.Event.select(.operator(makeOperator()))
        let optionsState = makeOptionsState(lastPayments: [makeLastPayment()])
        let optionsEffect: SUT.OptionsEffect = .initiate
        let (sut, _) = makeSUT(stub: (optionsState, optionsEffect))

        let (state, effect) = sut.reduce(selectedState, selectedEvent)
        
        XCTAssertNoDiff(state, selectedState)
        XCTAssertNil(effect)
    }
    
    func test_selectEvent_shouldChangeOptionsStateToSelectedLastPayment() {
        
        let lastPayment = makeLastPayment()
        let (sut, _) = makeSUT(stub: (makeOptionsState(), .initiate))
        
        let (state, effect) = sut.reduce(.options(makeOptionsState()), .select(.lastPayment(lastPayment)))

        XCTAssertNoDiff(state, .selected(.lastPayment(lastPayment)))
        XCTAssertNil(effect)
    }
    
    func test_selectEvent_shouldChangeOptionsStateToSelectedOperator() {
        
        let `operator` = makeOperator()
        let (sut, _) = makeSUT(stub: (makeOptionsState(), .initiate))
        
        let (state, effect) = sut.reduce(.options(makeOptionsState()), .select(.operator(`operator`)))

        XCTAssertNoDiff(state, .selected(.operator(`operator`)))
        XCTAssertNil(effect)
    }
    
    // MARK: - Helpers
    
    private typealias SUT = PrePaymentPickerReducer<TestLastPayment, TestOperator>
    private typealias Spy = ReducerSpy<SUT.OptionsState, SUT.OptionsEvent, SUT.OptionsEffect>
    
    private func makeSUT(
        stub: Spy.Stub,
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        spy: Spy
    ) {
        let spy = Spy(stub: stub)
        let sut = SUT(optionsReduce: spy.reduce)
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(spy, file: file, line: line)
        
        return (sut, spy)
    }
    
    private func selectedState(
        _ selection: SUT.State.Selection? = nil
    ) -> SUT.State {
        
        .selected(selection ?? .lastPayment(makeLastPayment()))
    }
    
    private func makeLastPayment(
        id: String = UUID().uuidString
    ) -> TestLastPayment {
        
        .init(id: id)
    }
    
    private func makeOperator(
        id: String = UUID().uuidString
    ) -> TestOperator {
        
        .init(id: id)
    }
    
    private func makeOptionsState(
        lastPayments: [TestLastPayment]? = nil,
        operators: [TestOperator]? = nil,
        searchText: String = "",
        isInflight: Bool = false
    ) -> SUT.OptionsState {
        
        .init(
            lastPayments: lastPayments,
            operators: operators,
            searchText: searchText,
            isInflight: isInflight
        )
    }
}
