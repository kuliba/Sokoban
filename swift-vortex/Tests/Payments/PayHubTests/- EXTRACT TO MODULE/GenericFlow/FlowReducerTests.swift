//
//  FlowReducerTests.swift
//
//
//  Created by Igor Malyarov on 23.08.2024.
//

import PayHub
import XCTest

final class FlowReducerTests: FlowTests {
    
    // MARK: - dismiss
    
    func test_dismiss_shouldSetNavigationToNil() {
        
        assert(makeState(isLoading: true, navigation: makeNavigation()), event: .dismiss) {
            
            $0.navigation = nil
        }
    }
    
    func test_dismiss_shouldResetDestination() {
        
        assert(makeState(navigation: makeNavigation()), event: .dismiss) {
            
            $0.navigation = nil
        }
    }
    
    func test_dismiss_shouldNotNotDeliverEffect() {
        
        assert(
            makeState(navigation: makeNavigation()),
            event: .dismiss,
            delivers: nil
        )
    }
    
    // MARK: - isLoading
    
    func test_receive_shouldSetIsLoadingToFalseOnIsLoadingFalse() {
        
        assert(makeState(isLoading: true, navigation:  makeNavigation()), event: .isLoading(false)) {
            
            $0.isLoading = false
        }
    }
    
    func test_receive_shouldSetIsLoadingToTrueOnIsLoadingTrue() {
        
        assert(makeState(isLoading: false, navigation:  makeNavigation()), event: .isLoading(true)) {
            
            $0.isLoading = true
        }
    }
    
    // MARK: - receive
    
    func test_receive_shouldSetIsLoadingToFalseSetDestinationToCategory() {
        
        let navigation = makeNavigation()
        
        assert(makeState(isLoading: true, navigation: nil), event: .navigation(navigation)) {
            
            $0.isLoading = false
            $0.navigation = navigation
        }
    }
    
    func test_receive_shouldNotDeliverEffect() {
        
        assert(
            makeState(navigation: nil),
            event: .navigation(makeNavigation()),
            delivers: nil
        )
    }
    
    // MARK: - select
    
    func test_select_shouldSetIsLoadingToTrueNotResetDestination() {
        
        let select = makeSelect()
        
        assert(
            makeState(isLoading: true, navigation: nil),
            event: .select(select)
        ) {
            $0.isLoading = true
        }
    }
    
    func test_select_shouldDeliverEffect() {
        
        let select = makeSelect()
        
        assert(
            makeState(isLoading: true, navigation: makeNavigation()),
            event: .select(select),
            delivers: .select(select)
        )
    }
    
    // MARK: - Helpers
    
    private typealias SUT = FlowReducer<Select, Navigation>
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> SUT {
        
        let sut = SUT()
        
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return sut
    }
    
    private func makeState(
        isLoading: Bool = false,
        navigation: Navigation? = nil
    ) -> SUT.State {
        
        return .init(isLoading: isLoading, navigation: navigation)
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
