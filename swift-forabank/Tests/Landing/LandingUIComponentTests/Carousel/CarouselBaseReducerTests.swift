//
//  CarouselBaseReducerTests.swift
//  
//
//  Created by Andryusina Nataly on 08.10.2024.
//

import XCTest
import RxViewModel
import Combine
import LandingUIComponent

final class CarouselBaseReducerTests: XCTestCase {
    
    func test_reduce_card_goToMain_shouldNotChangeStated() {
        
        assertState(.card(.goToMain), on: .test)
    }
    
    func test_reduce_card_goToMain_shouldDeliverGoToMainEffect
    () {
        
        assert(.card(.goToMain), on: .test, effect: .goToMain)
    }
    
    func test_reduce_card_openUrl_shouldNotChangeStated() {
        
        let link = anyMessage()
        
        assertState(.card(.openUrl(link)), on: .test)
    }
    
    func test_reduce_card_openUrl_shouldDeliverGoToMainEffect
    () {
        
        let link = anyMessage()

        assert(.card(.openUrl(link)), on: .test, effect: .openUrl(link))
    }

    // MARK: - Helpers
    
    private typealias SUT = CarouselBaseReducer
    private typealias State = SUT.State
    private typealias Event = SUT.Event
    private typealias Effect = SUT.Effect
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> SUT {
        
        let sut = SUT()
        
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return sut
    }
    
    private typealias UpdateStateToExpected<State> = (_ state: inout State) -> Void
    
    private func assertState(
        _ event: Event,
        on state: State,
        updateStateToExpected: UpdateStateToExpected<State>? = nil,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let sut = makeSUT()
        
        var expectedState = state
        updateStateToExpected?(&expectedState)
        
        let (receivedState, _) = sut.reduce(state, event)
        
        XCTAssertNoDiff(
            receivedState,
            expectedState,
            "\nExpected \(expectedState), but got \(receivedState) instead.",
            file: file, line: line
        )
    }
    
    private func assert(
        sut: SUT? = nil,
        _ event: Event,
        on state: State,
        effect expectedEffect: Effect?,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let sut = sut ?? makeSUT()
        
        let (_, receivedEffect) = sut.reduce(state, event)
        
        XCTAssertNoDiff(
            receivedEffect,
            expectedEffect,
            "\nExpected \(String(describing: expectedEffect)), but got \(String(describing: receivedEffect)) instead.",
            file: file, line: line
        )
    }
}

private extension CarouselBaseState {
    
    static let test: Self = .init(
        data: .init(
            title: "Title",
            size: .init(width: 10, height: 10),
            loopedScrolling: false,
            list: []))
}
