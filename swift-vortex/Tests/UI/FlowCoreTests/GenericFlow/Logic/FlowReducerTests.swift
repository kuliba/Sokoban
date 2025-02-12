//
//  FlowReducerTests.swift
//
//
//  Created by Igor Malyarov on 23.08.2024.
//

import FlowCore
import XCTest

final class FlowReducerTests: FlowTests {
    
    // MARK: - dismiss
    
    func test_dismiss_shouldFlipIsLoadingToFalse() {
        
        assert(
            isLoading: true,
            navigation: nil,
            event: .dismiss
        ) {
            $0.isLoading = false
        }
    }
    
    func test_dismiss_shouldNotDeliverEffect_onIsLoadingTrue() {
        
        assert(
            isLoading: true,
            navigation: nil,
            event: .dismiss,
            delivers: nil
        )
    }
    
    func test_dismiss_shouldSetNavigationToNil() {
        
        assert(
            isLoading: true,
            navigation: makeNavigation(),
            event: .dismiss
        ) {
            $0.isLoading = false
            $0.navigation = nil
        }
    }
    
    func test_dismiss_shouldResetDestination() {
        
        assert(
            navigation: makeNavigation(),
            event: .dismiss
        ) {
            $0.navigation = nil
        }
    }
    
    func test_dismiss_shouldNotDeliverEffect() {
        
        assert(
            navigation: makeNavigation(),
            event: .dismiss,
            delivers: nil
        )
    }
    
    // MARK: - isLoading
    
    func test_isLoading_shouldNotChangeIsLoadingFalseNilNavigationState_onIsLoadingFalseEvent() {
        
        assert(
            isLoading: false,
            navigation: nil,
            event: .isLoading(false)
        )
    }
    
    func test_isLoading_shouldNotDeliverEffect_onIsLoadingFalseNilNavigationState_onIsLoadingFalseEvent() {
        
        assert(
            isLoading: false,
            navigation: nil,
            event: .isLoading(false),
            delivers: nil
        )
    }
    
    func test_isLoading_shouldNotChangeIsLoadingFalseNonNilNavigationState_onIsLoadingFalseEvent() {
        
        assert(
            isLoading: false,
            navigation: makeNavigation(),
            event: .isLoading(false)
        )
    }
    
    func test_isLoading_shouldNotDeliverEffect_onIsLoadingFalseNonNilNavigationState_onIsLoadingFalseEvent() {
        
        assert(
            isLoading: false,
            navigation: makeNavigation(),
            event: .isLoading(false),
            delivers: nil
        )
    }
    
    func test_isLoading_shouldNotChangeIsLoadingTrueNilNavigationState_onIsLoadingTrueEvent() {
        
        assert(
            isLoading: true,
            navigation: nil,
            event: .isLoading(true)
        )
    }
    
    func test_isLoading_shouldNotDeliverEffect_onIsLoadingTrueNilNavigationState_onIsLoadingTrueEvent() {
        
        assert(
            isLoading: true,
            navigation: nil,
            event: .isLoading(true),
            delivers: nil
        )
    }
    
    func test_isLoading_shouldNotChangeIsLoadingTrueNonNilNavigationState_onIsLoadingTrueEvent() {
        
        assert(
            isLoading: true,
            navigation: makeNavigation(),
            event: .isLoading(true)
        )
    }
    
    func test_isLoading_shouldNotDeliverEffect_onIsLoadingTrueNonNilNavigationState_onIsLoadingTrueEvent() {
        
        assert(
            isLoading: true,
            navigation: makeNavigation(),
            event: .isLoading(true),
            delivers: nil
        )
    }
    
    func test_isLoading_shouldChangeIsLoadingFalseNilNavigationState_onIsLoadingTrueEvent() {
        
        assert(
            isLoading: false,
            navigation: nil,
            event: .isLoading(true)
        ) {
            $0.isLoading = true
        }
    }
    
    func test_isLoading_shouldNotDeliverEffect_onIsLoadingFalseNilNavigationState_onIsLoadingTrueEvent() {
        
        assert(
            isLoading: false,
            navigation: nil,
            event: .isLoading(true),
            delivers: nil
        )
    }
    
    func test_isLoading_shouldChangeIsLoadingFalseNonNilNavigationState_onIsLoadingTrueEvent() {
        
        assert(
            isLoading: false,
            navigation: makeNavigation(),
            event: .isLoading(true)
        ) {
            $0.isLoading = true
        }
    }
    
    func test_isLoading_shouldNotDeliverEffect_onIsLoadingFalseNonNilNavigationState_onIsLoadingTrueEvent() {
        
        assert(
            isLoading: false,
            navigation: makeNavigation(),
            event: .isLoading(true),
            delivers: nil
        )
    }
    
    func test_isLoading_shouldChangeIsLoadingTrueNilNavigationState_onIsLoadingFalseEvent() {
        
        assert(
            isLoading: true,
            navigation: nil,
            event: .isLoading(false)
        ) {
            $0.isLoading = false
        }
    }
    
    func test_isLoading_shouldNotDeliverEffect_onIsLoadingTrueNilNavigationState_onIsLoadingFalseEvent() {
        
        assert(
            isLoading: true,
            navigation: nil,
            event: .isLoading(false),
            delivers: nil
        )
    }
    
    func test_isLoading_shouldChangeIsLoadingTrueNonNilNavigationState_onIsLoadingFalseEvent() {
        
        assert(
            isLoading: true,
            navigation: makeNavigation(),
            event: .isLoading(false)
        ) {
            $0.isLoading = false
        }
    }
    
    func test_isLoading_shouldNotDeliverEffect_onIsLoadingTrueNonNilNavigationState_onIsLoadingFalseEvent() {
        
        assert(
            isLoading: true,
            navigation: makeNavigation(),
            event: .isLoading(false),
            delivers: nil
        )
    }
    
    // MARK: - receive
    
    func test_receive_shouldSetIsLoadingToFalseSetNavigation() {
        
        let navigation = makeNavigation()
        
        assert(
            isLoading: true,
            navigation: nil,
            event: .navigation(navigation)
        ) {
            $0.isLoading = false
            $0.navigation = navigation
        }
    }
    
    func test_receive_shouldNotDeliverEffect() {
        
        assert(
            navigation: nil,
            event: .navigation(makeNavigation()),
            delivers: nil
        )
    }
    
    func test_receive_shouldNotChangeNavigation_onIsLoadingTrueSameNavigation() {
        
        let navigation = makeNavigation()
        
        assert(
            isLoading: true,
            navigation: navigation,
            event: .navigation(navigation)
        ) {
            $0.isLoading = false
        }
    }
    
    func test_receive_shouldNotDeliverEffect_onIsLoadingTrueSameNavigation() {
    
        let navigation = makeNavigation()
        
        assert(
            isLoading: true,
            navigation: navigation,
            event: .navigation(navigation),
            delivers: nil
        )
    }
    
    func test_receive_shouldNotChangeState_onIsLoadingFalseSameNavigation() {
        
        let navigation = makeNavigation()
        
        assert(
            isLoading: false,
            navigation: navigation,
            event: .navigation(navigation)
        ) {
            $0.isLoading = false
        }
    }
    
    func test_receive_shouldNotDeliverEffect_onIsLoadingFalseSameNavigation() {
    
        let navigation = makeNavigation()
        
        assert(
            isLoading: false,
            navigation: navigation,
            event: .navigation(navigation),
            delivers: nil
        )
    }
    
    // MARK: - select
    
    func test_select_shouldSetIsLoadingToTrue_onIsLoadingFalseNilNavigation() {
        
        let select = makeSelect()
        
        assert(
            isLoading: false,
            navigation: nil,
            event: .select(select)
        ) {
            $0.isLoading = true
        }
    }
    
    func test_select_shouldNotChangeState_onIsLoadingTrueNilNavigation() {
        
        let select = makeSelect()
        
        assert(
            isLoading: true,
            navigation: nil,
            event: .select(select)
        ) {
            $0.isLoading = true
        }
    }
    
    func test_select_shouldSetIsLoadingToTrue_onIsLoadingFalseNonNilNavigation() {
        
        let select = makeSelect()
        
        assert(
            isLoading: false,
            navigation: makeNavigation(),
            event: .select(select)
        ) {
            $0.isLoading = true
        }
    }
    
    func test_select_shouldNotResetNavigation_onIsLoadingTrueNonNilNavigation() {
        
        let select = makeSelect()
        
        assert(
            isLoading: true,
            navigation: makeNavigation(),
            event: .select(select)
        ) {
            $0.isLoading = true
        }
    }
    
    func test_select_shouldDeliverEffect_onIsLoadingFalseNilNavigation() {
        
        let select = makeSelect()
        
        assert(
            isLoading: false,
            navigation: nil,
            event: .select(select),
            delivers: .select(select)
        )
    }
    
    func test_select_shouldDeliverEffect_onIsLoadingTrueNilNavigation() {
        
        let select = makeSelect()
        
        assert(
            isLoading: true,
            navigation: nil,
            event: .select(select),
            delivers: .select(select)
        )
    }
    
    func test_select_shouldDeliverEffect_onIsLoadingFalseNonNilNavigation() {
        
        let select = makeSelect()
        
        assert(
            isLoading: false,
            navigation: makeNavigation(),
            event: .select(select),
            delivers: .select(select)
        )
    }
    
    func test_select_shouldDeliverEffect_onIsLoadingTrueNonNilNavigation() {
        
        let select = makeSelect()
        
        assert(
            isLoading: true,
            navigation: makeNavigation(),
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
        isLoading: Bool = false,
        navigation: Navigation? = nil,
        event: SUT.Event,
        updateStateToExpected: ((inout SUT.State) -> Void)? = nil,
        file: StaticString = #file,
        line: UInt = #line
    ) -> SUT.State {
        
        let sut = sut ?? makeSUT(file: file, line: line)
        
        var expectedState = SUT.State(
            isLoading: isLoading,
            navigation: navigation
        )
        
        let (receivedState, _) = sut.reduce(expectedState, event)
        updateStateToExpected?(&expectedState)
        
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
        isLoading: Bool = false,
        navigation: Navigation? = nil,
        event: SUT.Event,
        delivers expectedEffect: SUT.Effect?,
        file: StaticString = #file,
        line: UInt = #line
    ) -> SUT.Effect? {
        
        let state = SUT.State(
            isLoading: isLoading,
            navigation: navigation
        )
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
