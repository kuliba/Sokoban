//
//  ListHorizontalRectangleLimitsReducerTests.swift
//
//
//  Created by Andryusina Nataly on 18.07.2024.
//

@testable import LandingUIComponent
import RxViewModel
import SVCardLimitAPI
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
    
    func test_limitChanging_valueIsChanged_newValueLessThenMaxValue_shouldSetSaveButtonEnableTrue() {
        
        let limits: SVCardLimits = .init(limitsList: [.init(type: "Debit", limits: .default)])
        
        assert(.limitChanging([.init(id: "1", value: 10)], false), on: initialState(.default, .limits(limits))) {
            $0.saveButtonEnable = true
        }
    }
    
    func test_limitChanging_valueIsChanged_newValueMoreThenMaxValue_shouldSetSaveButtonEnableFalse() {
        
        let limits: SVCardLimits = .init(limitsList: [.init(type: "Debit", limits: .default)])
        
        assert(.limitChanging([.init(id: "1", value: 10)], true), on: initialState(.default, .limits(limits))) {
            $0.saveButtonEnable = false
        }
    }

    func test_limitChanging_valueNoChanged_shouldSetSaveButtonEnableFalse() {
        
        let limits: SVCardLimits = .init(limitsList: [.init(type: "Debit", limits: .default)])
        
        assert(.limitChanging([.init(id: "1", value: 100)], false), on: initialState(.default, .limits(limits))) {
            $0.saveButtonEnable = false
        }
    }
    
    func test_informerWithLimits_shouldSetSaveButtonEnableFalseUpdateLimits() {
        
        let newLimits: [GetSVCardLimitsResponse.LimitItem] = [
            .init(type: "Debit", limits: [.init(currency: 810, currentValue: 90, name: "1", value: 1001)])
        ]
        let limits: SVCardLimits = .init(limitsList: [.init(type: "Debit", limits: .default)])

        assert(.informerWithLimits("Test", newLimits), on: initialState(.default, .limits(limits))) {
            $0.saveButtonEnable = false
            $0.limitsLoadingStatus = .limits(.init(newLimits, getCurrencySymbol: { _ in "₽" }))
        }
    }
    
    func test_dismissDestination_shouldSetSaveButtonEnableFalseDestinationNil() {
        
        let limits: SVCardLimits = .init(limitsList: [.init(type: "Debit", limits: .default)])
        
        assert(.dismissDestination, on: initialState(.default, .limits(limits))) {
            $0.saveButtonEnable = false
            $0.destination = nil
        }
    }

    private typealias SUT = ListHorizontalRectangleLimitsReducer
    private typealias State = SUT.State
    private typealias Event = SUT.Event
    private typealias Effect = SUT.Effect

    private func initialState(
        _ list: UILanding.List.HorizontalRectangleLimits = .default,
        _ status: LimitsLoadingStatus = .inflight(.loadingSVCardLimits)
    ) -> ListHorizontalRectangleLimitsState {
        .init(list: list, limitsLoadingStatus: status)
    }
    private func makeSUT(
        makeInformer: @escaping (String) -> Void = { _ in },
        getCurrencySymbol: @escaping SUT.GetCurrencySymbol = { _ in "₽" },
        file: StaticString = #file,
        line: UInt = #line
    ) -> SUT {
        
        let sut = SUT(makeInformer: makeInformer, getCurrencySymbol: getCurrencySymbol)
        
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
