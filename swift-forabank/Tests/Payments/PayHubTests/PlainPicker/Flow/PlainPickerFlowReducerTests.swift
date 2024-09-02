//
//  PlainPickerFlowReducerTests.swift
//
//
//  Created by Igor Malyarov on 30.08.2024.
//

import PayHub
import XCTest

final class PlainPickerFlowReducerTests: PlainPickerFlowTests {
    
    // MARK: - dismiss
    
    func test_dismiss_shouldResetNavigation() {
        
        let state = makeState(navigation: makeNavigation())
        
        assert(state, event: .dismiss) {
            
            $0.navigation = nil
        }
    }
    
    func test_dismiss_shouldNotDeliverEffect() {
        
        assert(makeState(), event: .dismiss, delivers: nil)
    }
    
    func test_navigation_shouldSetNavigation() {
        
        let navigation = makeNavigation()
        
        assert(makeState(), event: .navigation(navigation)) {
            
            $0.navigation = navigation
        }
    }
    
    func test_navigation_shouldNotDeliverEffect() {
        
        assert(makeState(), event: .navigation(makeNavigation()), delivers: nil)
    }
    
    func test_select_shouldNotChangeState() {
        
        assert(makeState(), event: .select(makeElement()))
    }
    
    func test_select_shouldDeliverEffect() {
        
        let element = makeElement()
        
        assert(makeState(), event: .select(element), delivers: .select(element))
    }
    
    // MARK: - Helpers
    
    private typealias SUT = PlainPickerFlowReducer<Element, Navigation>
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> SUT {
        
        let sut = SUT()
        
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return sut
    }
    
    private func makeState(
        navigation: Navigation? = nil
    ) -> SUT.State {
        
        return .init(navigation: navigation)
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
