//
//  SplashScreenReducerTests.swift
//
//
//  Created by Igor Malyarov on 13.03.2025.
//

import SplashScreenUI
import XCTest

final class SplashScreenReducerTests: XCTestCase {
    
    // MARK: - hide
    
    func test_hide_shouldSetStateToHidden_onCover() {
        
        assert(.cover, event: .hide) {
            
            $0 = .hidden
        }
    }
    
    func test_hide_shouldNotDeliverEffect_onCover() {
        
        assert(.cover, event: .hide, delivers: nil)
    }
    
    func test_hide_shouldSetStateToHidden_onWarm() {
        
        assert(.warm, event: .hide) {
            
            $0 = .hidden
        }
    }
    
    func test_hide_shouldNotDeliverEffect_onWarm() {
        
        assert(.warm, event: .hide, delivers: nil)
    }
    
    func test_hide_shouldSetStateToHidden_onPresented() {
        
        assert(.presented, event: .hide) {
            
            $0 = .hidden
        }
    }
    
    func test_hide_shouldNotDeliverEffect_onPresented() {
        
        assert(.presented, event: .hide, delivers: nil)
    }
    
    func test_hide_shouldNotChangeState_onHidden() {
        
        assert(.hidden, event: .hide)
    }
    
    func test_hide_shouldNotDeliverEffect_onHidden() {
        
        assert(.hidden, event: .hide, delivers: nil)
    }
    
    // MARK: - prepare
    
    func test_prepare_shouldSetStateToWarm_onCover() {
        
        assert(.cover, event: .prepare) {
            
            $0 = .warm
        }
    }
    
    func test_prepare_shouldNotDeliverEffect_onCover() {
        
        assert(.cover, event: .prepare, delivers: nil)
    }

    func test_prepare_shouldNotChangeState_onWarm() {
        
        assert(.warm, event: .prepare)
    }
    
    func test_prepare_shouldNotDeliverEffect_onWarm() {
        
        assert(.warm, event: .prepare, delivers: nil)
    }

    func test_prepare_shouldSetStateToWarm_onPresented() {
        
        assert(.presented, event: .prepare) {
            
            $0 = .warm
        }
    }
    
    func test_prepare_shouldNotDeliverEffect_onPresented() {
        
        assert(.presented, event: .prepare, delivers: nil)
    }

    func test_prepare_shouldSetStateToWarm_onHidden() {
        
        assert(.hidden, event: .prepare) {
            
            $0 = .warm
        }
    }
    
    func test_prepare_shouldNotDeliverEffect_onHidden() {
        
        assert(.hidden, event: .prepare, delivers: nil)
    }

    // MARK: - Helpers
    
    private typealias SUT = SplashScreenReducer
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> SUT {
        
        let sut = SUT()
        
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return sut
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
        
        let (_, receivedEffect): (SUT.State, SUT.Effect?) = sut.reduce(state, event)
        
        XCTAssertNoDiff(
            receivedEffect,
            expectedEffect,
            "\nExpected \(String(describing: expectedEffect)), but got \(String(describing: receivedEffect)) instead.",
            file: file, line: line
        )
        
        return receivedEffect
    }
}
