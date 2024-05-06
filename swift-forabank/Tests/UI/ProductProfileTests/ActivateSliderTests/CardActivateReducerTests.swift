//
//  CardActivateReducerTests.swift
//
//
//  Created by Andryusina Nataly on 28.02.2024.
//

import XCTest
@testable import ActivateSlider
import RxViewModel

final class CardActivateReducerTestsTests: XCTestCase {
    
    // MARK: - card events
    
    func test_activateCard_shouldSetEffectNone() {
        
        assert(.card(.activateCard), on: .initialState, effect: .none)
    }
    
    func test_activateCard_shouldSetStatusOnConfirmActivate() {
                
        assert(.card(.activateCard), on: .initialState) {
            
            $0.cardState = .status(.confirmActivate)
        }
    }

    func test_activateCardResponseConnectivityError_shouldSetEffectNone() {
        
        assert(.card(.activateCardResponse(.connectivityError)), on: .initialState, effect: .none)
    }
    
    func test_activateCardResponseConnectivityError_shouldSetStatusOnNil() {
        
        assert(.card(.activateCardResponse(.connectivityError)), on: .initialState) {
            
            $0.cardState = .status(nil)
        }
    }
    
    func test_activateCardResponseServerError_shouldSetEffectNone() {
        
        assert(.card(.activateCardResponse(.serverError("error"))), on: .initialState, effect: .none)
    }
    
    func test_activateCardResponseServerError_shouldSetStatusOnNil() {
        
        assert(.card(.activateCardResponse(.serverError("message"))), on: .initialState) {
            
            $0.cardState = .status(nil)
        }
    }

    func test_activateCardResponseSuccess_shouldSetEffectDismiss() {
        
        assert(.card(.activateCardResponse(.success)), on: .initialState, effect: .card(.dismiss(.seconds(1))))
    }

    func test_activateCardResponseSuccess_shouldSetStatusOnActivated() {
        
        assert(.card(.activateCardResponse(.success)), on: .initialState) {
            
            $0.cardState = .status(.activated)
        }
    }

    func test_confirmActivateActivate_shouldSetEffectCardActivate() {
        
        assert(.card(.confirmActivate(.activate)), on: .initialState, effect: .card(.activate))
    }
    
    func test_confirmActivateActivate_shouldSetStatusOnInflight() {
        
        assert(.card(.confirmActivate(.activate)), on: .initialState) {
            
            $0.cardState = .status(.inflight)
        }
    }

    func test_confirmActivateCancel_shouldSetEffectNone() {
        
        assert(.card(.confirmActivate(.cancel)), on: .initialState, effect: .none)
    }
    
    func test_confirmActivateCancel_shouldSetStatusOnNil() {
        
        assert(.card(.confirmActivate(.cancel)), on: .initialState) {
            
            $0.cardState = .status(nil)
        }
    }

    func test_dismissActivate_shouldSetEffectNone() {
        
        assert(.card(.dismissActivate), on: .initialState, effect: .none)
    }
    
    func test_dismissActivate_shouldSetStatusOnActive() {
        
        assert(.card(.dismissActivate), on: .initialState) {
            
            $0.cardState = .active
        }
    }

    // MARK: - slider events

    func test_drag_shouldSetEffectNone() {
        
        assert(.slider(.drag(19)), on: .initialState, effect: .none)
    }
    
    func test_drag_shouldSetOffsetToNewValue() {
        
        assert(.slider(.drag(19)), on: .initialState) {
            
            $0.offsetX = 19
        }
    }

    func test_dragEndedOffsetLessThanHalfMaxOffset_shouldSetEffectNone() {
        
        let sut = makeSUT(maxOffset: 60)
        
        assert(sut: sut, .slider(.dragEnded(15)), on: .initialState, effect: .none)
    }

    func test_dragEndedOffsetLessThanHalfMaxOffset_shouldSetOffsetToZero() {
        
        assert(.slider(.dragEnded(15)), on: .initialState) {
            
            $0.offsetX = 0
        }
    }

    func test_dragEndedOffsetMoreThanHalfMaxOffset_shouldSetEffectConfirmation() {
        
        let sut = makeSUT(maxOffset: 90)
        
        assert(sut: sut, .slider(.dragEnded(75)), on: .initialState, effect: .card(.confirmation(.milliseconds(200))))
    }
    
    func test_dragEndedOffsetMoreThanHalfMaxOffset_shouldSetOffsetToMaxOffset() {
        
        let maxOffset: CGFloat = 90
        let sut = makeSUT(maxOffset: maxOffset)

        assert(sut: sut, .slider(.dragEnded(75)), on: .initialState) {
            
            $0.offsetX = maxOffset
        }
    }

    func test_dragEndedOffsetMoreThanMaxOffset_shouldSetEffectConfirmation() {
        
        let sut = makeSUT(maxOffset: 90)
        
        assert(sut: sut, .slider(.dragEnded(95)), on: .initialState, effect: .card(.confirmation(.milliseconds(200))))
    }
    
    func test_dragEndedOffsetMoreThanMaxOffset_shouldSetOffsetToMaxOffset() {
        
        let maxOffset: CGFloat = 90
        let sut = makeSUT(maxOffset: maxOffset)

        assert(sut: sut, .slider(.dragEnded(95)), on: .initialState) {
            
            $0.offsetX = maxOffset
        }
    }

    private typealias SUT = CardActivateReducer
    private typealias State = SUT.State
    private typealias Event = SUT.Event
    private typealias Effect = SUT.Effect
    private typealias Result = (State, Effect?)
    
    private func makeSUT(
        activate: @escaping () -> Void = {},
        maxOffset: CGFloat = 100,
        file: StaticString = #file,
        line: UInt = #line
    ) -> SUT {
        
        let cardReduce = CardReducer(activate: activate).reduce
        let sliderReduce = SliderReducer(
            maxOffsetX: maxOffset
        ).reduce

        let sut = SUT(
            cardReduce: cardReduce,
            sliderReduce: sliderReduce,
            maxOffset: maxOffset)
        
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut)
    }
    
    private func reduce(
        _ sut: SUT,
        _ state: State = .initialState,
        event: Event
    ) -> (state: State, effect: Effect?) {
        
        return sut.reduce(state, event)
    }
    
    private func assert(
        sut: SUT? = nil,
        _ event: Event,
        on state: State,
        effect expectedEffect: Effect?,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        
        let receivedEffect = reduce(sut ?? makeSUT(), state, event: event).1
        
        XCTAssertNoDiff(
            receivedEffect,
            expectedEffect,
            "\nExpected \(String(describing: expectedEffect)) state, but got \(String(describing: receivedEffect)) instead.",
            file: file, line: line
        )
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

extension CardActivateReducer: Reducer { }
extension CardReducer: Reducer { }
extension SliderReducer: Reducer { }
