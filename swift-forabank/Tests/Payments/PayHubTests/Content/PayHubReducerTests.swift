//
//  PayHubReducerTests.swift
//
//
//  Created by Igor Malyarov on 15.08.2024.
//

typealias PayHubState<Latest> = Optional<[PayHubItem<Latest>]>

final class PayHubReducer<Latest> {}

extension PayHubReducer {
    
    func reduce(
        _ state: State,
        _ event: Event
    ) -> (State, Effect?) {
        
        var state = state
        var effect: Effect?
        
        switch event {
        case let .loaded(loaded):
            state = [.templates, .exchange] + loaded.map { .latest($0) }
        }
        
        return (state, effect)
    }
}

extension PayHubReducer {
    
    typealias State = PayHubState<Latest>
    typealias Event = PayHubEvent<Latest>
    typealias Effect = PayHubEffect
}


import PayHub
import XCTest

final class PayHubReducerTests: PayHubTests {
    
    // MARK: - loaded
        
    func test_loaded_shouldSetTemplatesWithExchangeOnEmpty() {
        
        assert(.none, event: .loaded([])) {
            
            $0 = [.templates, .exchange]
        }
    }
        
    func test_loaded_shouldNotDeliverEffectOnEmpty() {
        
        assert(.none, event: .loaded([]), delivers: nil)
    }
        
    func test_loaded_shouldSetTemplatesWithExchangeAndOneLatestOnOneLatest() {
        
        let latest = makeLatest()
        
        assert(.none, event: .loaded([latest])) {
            
            $0 = [.templates, .exchange, .latest(latest)]
        }
    }
        
    func test_loaded_shouldNotDeliverEffectOnOneLatest() {
        
        let latest = makeLatest()
        
        assert(.none, event: .loaded([latest]), delivers: nil)
    }
        
    func test_loaded_shouldSetTemplatesWithExchangeAndTwoLatestOnTwoLatest() {
        
        let (latest1, latest2) = (makeLatest(), makeLatest())
        
        assert(.none, event: .loaded([latest1, latest2])) {
            
            $0 = [.templates, .exchange, .latest(latest1), .latest(latest2)]
        }
    }
        
    func test_loaded_shouldNotDeliverEffectOnTwoLatest() {
        
        let (latest1, latest2) = (makeLatest(), makeLatest())
        
        assert(.none, event: .loaded([latest1, latest2]), delivers: nil)
    }
        
    // MARK: - Helpers
    
    private typealias SUT = PayHubReducer<Latest>
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> SUT {
        
        let sut = SUT()
        
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return sut
    }
    
    @discardableResult
    private func assert(
        sut: SUT? = nil,
        _ state: SUT.State,
        event: SUT.Event,
        updateStateToExpected: ((inout SUT.State) -> Void)? = nil,
        file: StaticString = #file,
        line: UInt = #line
    ) -> SUT.State {
        
        let sut = sut ?? makeSUT(file: file, line: line)
        
        var expectedState = state
        updateStateToExpected?(&expectedState)
        
        let (receivedState, _) = sut.reduce(state, event)
        
        XCTAssertNoDiff(
            receivedState,
            expectedState,
            "\nExpected \(String(describing: expectedState)), but got \(String(describing: receivedState)) instead.",
            file: file, line: line
        )
        
        return receivedState
    }
    
    @discardableResult
    private func assert(
        sut: SUT? = nil,
        _ state: SUT.State,
        event: SUT.Event,
        delivers expectedEffect: SUT.Effect?,
        file: StaticString = #file,
        line: UInt = #line
    ) -> SUT.Effect? {
        
        let sut = sut ?? makeSUT(file: file, line: line)
        
        let (_, receivedEffect) = sut.reduce(state, event)
        
        XCTAssertNoDiff(
            receivedEffect,
            expectedEffect,
            "\nExpected \(String(describing: expectedEffect)), but got \(String(describing: receivedEffect)) instead.",
            file: file, line: line
        )
        
        return receivedEffect
    }
}
