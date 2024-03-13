//
//  ProductDetailsReducerTests.swift
//
//
//  Created by Andryusina Nataly on 06.03.2024.
//

import XCTest
@testable import ProductDetailsUI
import RxViewModel

final class ProductDetailsReducerTests: XCTestCase {

    func test_appear_shouldSetEffectNone() {
        
        assert(.appear, on: .initialState, effect: .none)
    }
    
    func test_appear_shouldUpdateEventOnAppear() {
                
        assert(.appear, on: .initialState) {
            
            $0.event = .appear
        }
    }
    
    func test_itemTappedLongPress_shouldSetEffectNone() {
                
        assert(.itemTapped(.longPress("111","text")), on: .initialState, effect: .none)
    }
    
    func test_itemTappedLongPress_shouldUpdateEventOnItemTap() {
         
        assert(.itemTapped(.longPress("111","text")), on: .initialState) {
            
            $0.event = .itemTapped(.longPress("111","text"))
        }
    }

    func test_itemTappedIconTap_shouldSetEffectNone() {
                
        assert(.itemTapped(.iconTap(.cvv)), on: .initialState, effect: .none)
    }
    
    func test_buttonTappedIconTap_shouldUpdateEventOnItemTap() {
         
        assert(.itemTapped(.iconTap(.cvv)), on: .initialState) {
            
            $0.event = .itemTapped(.iconTap(.cvv))
        }
    }

    // MARK: - Helpers
    
    private typealias SUT = ProductDetailsReducer
    private typealias State = SUT.State
    private typealias Event = SUT.Event
    private typealias Effect = SUT.Effect
    private typealias Result = (State, Effect?)
    
    private func makeSUT(
        shareAction: @escaping SUT.ShareAction = {_ in },
        file: StaticString = #file,
        line: UInt = #line
    ) -> SUT {
        
        let sut = SUT(shareInfo: shareAction)
        
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
        
        let receivedEffect: Effect? = reduce(sut ?? makeSUT(), state, event: event).1
        
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

extension ProductDetailsReducer: Reducer { }
