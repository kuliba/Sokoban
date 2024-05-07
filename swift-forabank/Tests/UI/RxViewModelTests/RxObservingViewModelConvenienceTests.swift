//
//  RxObservingViewModelTests.swift
//
//
//  Created by Igor Malyarov on 20.04.2024.
//

import RxViewModel
import XCTest

final class RxObservingViewModelConvenienceTests: XCTestCase {
    
    func test_init_shouldSetInitialState() {
        
        let value = anyMessage()
        let (_, spy) = makeSUT(
            initialState: .init(value: value),
            stub: makeStub()
        )
        
        XCTAssertNoDiff(spy.values, [.init(value: value)])
    }
    
    func test_event_shouldDeliverStateChange() {
        
        let value = anyMessage()
        let newValue = anyMessage()
        let (sut, spy) = makeSUT(
            initialState: .init(value: value),
            stub: (.init(value: newValue), nil)
        )
        
        sut.event(.changeValueTo("abc"))
        
        XCTAssertNoDiff(spy.values, [
            .init(value: value),
            .init(value: newValue),
        ])
    }
    
    func test_event_shouldObserveStateChange() {
        
        let newValue = anyMessage()
        var values = [State]()
        let (sut, _) = makeSUT(
            initialState: .init(value: anyMessage()),
            stub: (.init(value: newValue), nil),
            observe: { values.append($0) }
        )
        
        sut.event(.changeValueTo("abc"))
        
        XCTAssertNoDiff(values, [.init(value: newValue)])
    }
    
    // MARK: - Helpers
    
    private typealias SUT = RxObservingViewModel<State, Event, Effect>
    private typealias Spy = ValueSpy<State>
    private typealias ReduceSpy = ReducerSpy<State, Event, Effect>
    private typealias EffectHandleSpy = EffectHandlerSpy<Event, Effect>
    
    private func makeSUT(
        initialState: State = makeState(),
        stub: (State, Effect?)...,
        observe: @escaping (State) -> Void = { _ in },
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        spy: Spy
    ) {
        let reducer = ReduceSpy(stub: stub)
        let effectHandler = EffectHandleSpy()
        let sut = SUT(
            initialState: initialState,
            reduce: reducer.reduce(_:_:),
            handleEffect: effectHandler.handleEffect(_:_:),
            observe: observe,
            scheduler: .immediate
        )
        let spy = ValueSpy(sut.$state)
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(spy, file: file, line: line)
        
        return (sut, spy)
    }
    
    fileprivate struct State: Equatable {
        
        let value: String
    }
    
    private enum Event: Equatable {
        
        case changeValueTo(String)
        case resetValue
    }
    
    private enum Effect: Equatable {
        
        case load
    }
    
    private func makeStub(
        _ effect: Effect? = nil
    ) -> (State, Effect?) {
        
        (makeState(), effect)
    }
}

private func makeState(
    value: String = UUID().uuidString
) -> RxObservingViewModelConvenienceTests.State {
    
    .init(value: value)
}
