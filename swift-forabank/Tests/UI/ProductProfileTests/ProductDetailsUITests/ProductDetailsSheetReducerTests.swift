//
//  ProductDetailsSheetReducerTests.swift
//  
//
//  Created by Andryusina Nataly on 12.03.2024.
//

import XCTest
@testable import ProductDetailsUI
import RxViewModel

final class ProductDetailsSheetReducerTests: XCTestCase {

    func test_appear_shouldSetEffectNone() {
        
        assert(.appear, on: .initialStateRegular, effect: .none)
    }
    
    func test_appear_shouldUpdateEventOnAppear() {
                
        assert(.appear, on: .initialStateRegular) {
            
            $0.event = .appear
        }
    }
    
    func test_buttonTappedSendAll_shouldSetEffectNone() {
                
        assert(.buttonTapped(.sendAll), on: .initialStateRegular, effect: .none)
    }
    
    func test_buttonTappedSendAll_shouldUpdateEventOnButtonTap() {
         
        assert(.buttonTapped(.sendAll), on: .initialStateRegular) {
            
            $0.event = .buttonTapped(.sendAll)
        }
    }

    func test_buttonTappedSendSelect_shouldSetEffectNone() {
                
        assert(.buttonTapped(.sendSelect), on: .initialStateRegular, effect: .none)
    }
    
    func test_buttonTappedSendSelect_shouldUpdateEventOnButtonTap() {
         
        assert(.buttonTapped(.sendSelect), on: .initialStateRegular) {
            
            $0.event = .buttonTapped(.sendSelect)
        }
    }

    // MARK: - Helpers
    
    private typealias SUT = ProductDetailsSheetReducer
    private typealias State = SUT.State
    private typealias Event = SUT.Event
    private typealias Effect = SUT.Effect
    private typealias Result = (State, Effect?)
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> SUT {
        
        let sut = SUT()
        
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut)
    }
    
    private func reduce(
        _ sut: SUT,
        _ state: State = .initialStateRegular,
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

extension ProductDetailsSheetReducer: Reducer { }
