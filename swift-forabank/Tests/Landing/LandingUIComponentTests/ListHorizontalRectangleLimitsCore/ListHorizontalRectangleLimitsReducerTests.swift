//
//  ListHorizontalRectangleLimitsReducerTests.swift
//
//
//  Created by Andryusina Nataly on 18.07.2024.
//

@testable import LandingUIComponent
import RxViewModel
import XCTest

final class ListHorizontalRectangleLimitsReducerTests: XCTestCase {
      
    func test_updateLimits_failure_shouldSetStatusFailure() {
        
        assert(.updateLimits(.failure), on: initialState()) {
            $0.limitsLoadingStatus = .failure
        }
    }
    
    func test_updateLimits_success_shouldSetStatusSuccess() {
        
        let limits: SVCardLimits = .init(limitsList: [.init(type: "Debit", limits: .default)])
        
        assert(.updateLimits(.success(limits)), on: initialState()) {
            $0.limitsLoadingStatus = .limits(limits)
        }
    }

    private typealias SUT = ListHorizontalRectangleLimitsReducer
    private typealias State = SUT.State
    private typealias Event = SUT.Event
    private typealias Effect = SUT.Effect

    private func initialState(
        _ list: UILanding.List.HorizontalRectangleLimits = .default,
        _ status: LimitsLoadingStatus = .inflight
    ) -> ListHorizontalRectangleLimitsState {
        .init(list: list, limitsLoadingStatus: status)
    }
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> SUT {
        
        let sut = SUT()
        
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return sut
    }
        
    private func reduce(
        _ sut: SUT,
        _ state: State,
        _ event: Event
    ) -> (state: State, effect: Effect?) {
        
        sut.reduce(state, event)
    }
        
    private func assert(
        sut: SUT? = nil,
        _ event: Event,
        on state: State,
        updateStateToExpected: UpdateStateToExpected<State>? = nil,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let sut = sut ?? makeSUT()
        
        _assertState(
            sut,
            event,
            on: state,
            updateStateToExpected: updateStateToExpected,
            file: file, line: line
        )
    }
}

extension ListHorizontalRectangleLimitsReducer: Reducer { }
