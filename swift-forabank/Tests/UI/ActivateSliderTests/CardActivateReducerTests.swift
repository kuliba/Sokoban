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
        
        let expectedState: State = .init(
            cardState: .status(.confirmActivate),
            offsetX: 0)
        
        assert(
            .initialState,
            .card(.activateCard),
            reducedTo: expectedState
        )
    }

    func test_activateCardResponseConnectivityError_shouldSetEffectNone() {
        
        assert(.card(.activateCardResponse(.connectivityError)), on: .initialState, effect: .none)
    }
    
    func test_activateCardResponseConnectivityError_shouldSetStatusOnNil() {
        
        let expectedState: State = .init(
            cardState: .status(nil),
            offsetX: 0)
        
        assert(
            .initialState,
            .card(.activateCardResponse(.connectivityError)),
            reducedTo: expectedState
        )
    }
    
    func test_activateCardResponseServerError_shouldSetEffectNone() {
        
        assert(.card(.activateCardResponse(.serverError("error"))), on: .initialState, effect: .none)
    }
    
    func test_activateCardResponseServerError_shouldSetStatusOnNil() {
        
        let expectedState: State = .init(
            cardState: .status(nil),
            offsetX: 0)
        
        assert(
            .initialState,
            .card(.activateCardResponse(.serverError("error"))),
            reducedTo: expectedState
        )
    }

    func test_activateCardResponseSuccess_shouldSetEffectDismiss() {
        
        assert(.card(.activateCardResponse(.success)), on: .initialState, effect: .card(.dismiss(.seconds(1))))
    }

    func test_activateCardResponseSuccess_shouldSetStatusOnActivated() {
        
        let expectedState: State = .init(
            cardState: .status(.activated),
            offsetX: 0)
        
        assert(
            .initialState,
            .card(.activateCardResponse(.success)),
            reducedTo: expectedState
        )
    }

    func test_confirmActivateActivate_shouldSetEffectCardActivate() {
        
        assert(.card(.confirmActivate(.activate)), on: .initialState, effect: .card(.activate))
    }
    
    func test_confirmActivateActivate_shouldSetStatusOnInflight() {
        
        let expectedState: State = .init(
            cardState: .status(.inflight),
            offsetX: 0)
        
        assert(
            .initialState,
            .card(.confirmActivate(.activate)),
            reducedTo: expectedState
        )
    }

    func test_confirmActivateCancel_shouldSetEffectNone() {
        
        assert(.card(.confirmActivate(.cancel)), on: .initialState, effect: .none)
    }
    
    func test_confirmActivateCancel_shouldSetStatusOnNil() {
        
        let expectedState: State = .init(
            cardState: .status(nil),
            offsetX: 0)
        
        assert(
            .initialState,
            .card(.confirmActivate(.cancel)),
            reducedTo: expectedState
        )
    }

    func test_dismissActivate_shouldSetEffectNone() {
        
        assert(.card(.dismissActivate), on: .initialState, effect: .none)
    }
    
    func test_dismissActivate_shouldSetStatusOnActive() {
        
        let expectedState: State = .init(
            cardState: .active,
            offsetX: 0)
        
        assert(
            .initialState,
            .card(.dismissActivate),
            reducedTo: expectedState
        )
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

    private typealias SUT = CardActivateReducer
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
    
    private func assert(
        sut: SUT? = nil,
        _ currentState: State,
        _ event: Event,
        reducedTo expectedState: State,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        
        let sut = sut ?? makeSUT()
        let (receivedState, _) = sut.reduce(currentState, event)
        
        XCTAssertNoDiff(
            receivedState,
            expectedState,
            "\nExpected \(expectedState), but got \(receivedState) instead.",
            file: file, line: line
        )
    }
}

extension CardActivateReducer: Reducer { }
extension CardReducer: Reducer { }
extension SliderReducer: Reducer { }
