//
//  GlobalReducerTests.swift
//
//
//  Created by Andryusina Nataly on 28.02.2024.
//

import XCTest
import ActivateSlider
import RxViewModel

final class GlobalReducerTestsTests: XCTestCase {
    
    // MARK: - card events
    
    func test_activateCard_shouldSetEffectNone() {
        
        assert(.card(.activateCard), on: .initialState, effect: .none)
    }

    func test_activateCardResponseConnectivityError_shouldSetEffectNone() {
        
        assert(.card(.activateCardResponse(.connectivityError)), on: .initialState, effect: .none)
    }
    
    func test_activateCardResponseServerError_shouldSetEffectNone() {
        
        assert(.card(.activateCardResponse(.serverError("error"))), on: .initialState, effect: .none)
    }
    
    func test_activateCardResponseSuccess_shouldSetEffectDismiss() {
        
        assert(.card(.activateCardResponse(.success)), on: .initialState, effect: .card(.dismiss(.seconds(1))))
    }

    func test_confirmActivateActivate_shouldSetEffectCardActivate() {
        
        assert(.card(.confirmActivate(.activate)), on: .initialState, effect: .card(.activate))
    }

    func test_confirmActivateCancel_shouldSetEffectNone() {
        
        assert(.card(.confirmActivate(.cancel)), on: .initialState, effect: .none)
    }

    func test_dismissActivate_shouldSetEffectNone() {
        
        assert(.card(.dismissActivate), on: .initialState, effect: .none)
    }
    
    // MARK: - slider events

    func test_drag_shouldSetEffectNone() {
        
        assert(.slider(.drag(19)), on: .initialState, effect: .none)
    }
    
    func test_dragEndedOffsetLessThanHalfMaxOffset_shouldSetEffectNone() {
        
        let sut = makeSUT(maxOffset: 60)
        
        assert(sut: sut, .slider(.dragEnded(15)), on: .initialState, effect: .none)
    }

    func test_dragEndedOffsetMoreThanHalfMaxOffset_shouldSetEffectConfirmation() {
        
        let sut = makeSUT(maxOffset: 90)
        
        assert(sut: sut, .slider(.dragEnded(75)), on: .initialState, effect: .card(.confirmation(.milliseconds(200))))
    }
    
    func test_dragEndedOffsetMoreThanMaxOffset_shouldSetEffectConfirmation() {
        
        let sut = makeSUT(maxOffset: 90)
        
        assert(sut: sut, .slider(.dragEnded(95)), on: .initialState, effect: .card(.confirmation(.milliseconds(200))))
    }

    private typealias SUT = GlobalReducer
    private typealias State = SUT.State
    private typealias Event = SUT.Event
    private typealias Effect = SUT.Effect
    private typealias Result = (State, Effect?)
    
    private func makeSUT(
        maxOffset: CGFloat = 100,
        file: StaticString = #file,
        line: UInt = #line
    ) -> SUT {
        
        let cardReduce = CardReducer().reduce
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
}

extension GlobalReducer: Reducer { }
extension CardReducer: Reducer { }
extension SliderReducer: Reducer { }
