//
//  SplashScreenReducerTests.swift
//
//
//  Created by Igor Malyarov on 13.03.2025.
//

import SplashScreenUI
import SwiftUI
import XCTest

final class SplashScreenReducerTests: SplashScreenTests {
    
    // MARK: - hide
    
    func test_hide_shouldChangePhaseToHidden_onCover() {
        
        assert(cover(), event: .hide) { $0.phase = .hidden }
    }
    
    func test_hide_shouldDeliverRequestUpdateEffect_onCover() {
        
        assert(cover(), event: .hide, delivers: .requestUpdate)
    }
    
    func test_hide_shouldChangePhaseToHidden_onWarm() {
        
        assert(warm(), event: .hide) { $0.phase = .hidden }
    }
    
    func test_hide_shouldDeliverRequestUpdateEffect_onWarm() {
        
        assert(warm(), event: .hide, delivers: .requestUpdate)
    }
    
    func test_hide_shouldChangePhaseToHidden_onPresented() {
        
        assert(presented(), event: .hide) { $0.phase = .hidden }
    }
    
    func test_hide_shouldDeliverRequestUpdateEffect_onPresented() {
        
        assert(presented(), event: .hide, delivers: .requestUpdate)
    }
    
    func test_hide_shouldNotChangeState_onHidden() {
        
        assert(hidden(), event: .hide)
    }
    
    func test_hide_shouldDeliverRequestUpdateEffect_onHidden() {
        
        assert(hidden(), event: .hide, delivers: .requestUpdate)
    }
    
    // MARK: - prepare
    
    func test_prepare_shouldChangePhaseToWarm_onCover() {
        
        assert(cover(), event: .prepare) { $0.phase = .warm }
    }
    
    func test_prepare_shouldNotDeliverEffect_onCover() {
        
        assert(cover(), event: .prepare, delivers: nil)
    }

    func test_prepare_shouldNotChangeState_onWarm() {
        
        assert(warm(), event: .prepare)
    }
    
    func test_prepare_shouldNotDeliverEffect_onWarm() {
        
        assert(warm(), event: .prepare, delivers: nil)
    }

    func test_prepare_shouldChangePhaseToWarm_onPresented() {
        
        assert(presented(), event: .prepare) { $0.phase = .warm }
    }
    
    func test_prepare_shouldNotDeliverEffect_onPresented() {
        
        assert(presented(), event: .prepare, delivers: nil)
    }

    func test_prepare_shouldChangePhaseToWarm_onHidden() {
        
        assert(hidden(), event: .prepare) { $0.phase = .warm }
    }
    
    func test_prepare_shouldNotDeliverEffect_onHidden() {
        
        assert(hidden(), event: .prepare, delivers: nil)
    }

    // MARK: - start
    
    func test_start_shouldChangePhaseToPresented_onCover() {
        
        assert(cover(), event: .start) { $0.phase = .presented }
    }
    
    func test_start_shouldNotDeliverEffect_onCover() {
        
        assert(cover(), event: .start, delivers: nil)
    }

    func test_start_shouldChangePhaseToPresented_onWarm() {
        
        assert(warm(), event: .start) { $0.phase = .presented }
    }
    
    func test_start_shouldNotDeliverEffect_onWarm() {
        
        assert(warm(), event: .start, delivers: nil)
    }

    func test_start_shouldNotChangeState_onPresented() {
        
        assert(presented(), event: .start)
    }
    
    func test_start_shouldNotDeliverEffect_onPresented() {
        
        assert(presented(), event: .start, delivers: nil)
    }

    func test_start_shouldChangePhaseToPresented_onHidden() {
        
        assert(hidden(), event: .start) { $0.phase = .presented }
    }
    
    func test_start_shouldNotDeliverEffect_onHidden() {
        
        assert(hidden(), event: .start, delivers: nil)
    }

    // MARK: - update
    
    func test_update_shouldChangeSettings_onCover() {
        
        let settings = makeSettings()
        
        assert(cover(), event: .update(settings)) { $0.settings = settings }
    }
    
    func test_update_shouldNotDeliverEffect_onCover() {
        
        let settings = makeSettings()
        
        assert(cover(), event: .update(settings), delivers: nil)
    }
    
    func test_update_shouldChangeSettings_onWarm() {
        
        let settings = makeSettings()
        
        assert(warm(), event: .update(settings)) { $0.settings = settings }
    }
    
    func test_update_shouldNotDeliverEffect_onWarm() {
        
        let settings = makeSettings()
        
        assert(warm(), event: .update(settings), delivers: nil)
    }
    
    func test_update_shouldChangeSettings_onPresented() {
        
        let settings = makeSettings()
        
        assert(presented(), event: .update(settings)) { $0.settings = settings }
    }
    
    func test_update_shouldNotDeliverEffect_onPresented() {
        
        let settings = makeSettings()
        
        assert(presented(), event: .update(settings), delivers: nil)
    }
    
    func test_update_shouldChangeSettings_onHidden() {
        
        let settings = makeSettings()
        
        assert(hidden(), event: .update(settings)) { $0.settings = settings }
    }
    
    func test_update_shouldNotDeliverEffect_onHidden() {
        
        let settings = makeSettings()
        
        assert(hidden(), event: .update(settings), delivers: nil)
    }
    
    // MARK: - update nil
    
    func test_update_nil_shouldNotChangeSettings_onCover() {
                
        assert(cover(), event: .update(nil))
    }
    
    func test_update_nil_shouldNotDeliverEffect_onCover() {
                
        assert(cover(), event: .update(nil), delivers: nil)
    }
    
    func test_update_nil_shouldNotChangeSettings_onWarm() {
                
        assert(warm(), event: .update(nil))
    }
    
    func test_update_nil_shouldNotDeliverEffect_onWarm() {
                
        assert(warm(), event: .update(nil), delivers: nil)
    }
    
    func test_update_nil_shouldNotChangeSettings_onPresented() {
                
        assert(presented(), event: .update(nil))
    }
    
    func test_update_nil_shouldNotDeliverEffect_onPresented() {
                
        assert(presented(), event: .update(nil), delivers: nil)
    }
    
    func test_update_nil_shouldNotChangeSettings_onHidden() {
                
        assert(hidden(), event: .update(nil))
    }
    
    func test_update_nil_shouldNotDeliverEffect_onHidden() {
                
        assert(hidden(), event: .update(nil), delivers: nil)
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
    
    private func makeState(
        phase: State.Phase,
        settings: State.Settings? = nil
    ) -> State {
        
        return .init(phase: phase, settings: settings ?? makeSettings())
    }
    
    private func cover(
        settings: State.Settings? = nil
    ) -> State {
        
        return makeState(phase: .cover, settings: settings)
    }
    
    private func warm(
        settings: State.Settings? = nil
    ) -> State {
        
        return makeState(phase: .warm, settings: settings)
    }
    
    private func presented(
        settings: State.Settings? = nil
    ) -> State {
        
        return makeState(phase: .presented, settings: settings)
    }
    
    private func hidden(
        settings: State.Settings? = nil
    ) -> State {
        
        return makeState(phase: .hidden, settings: settings)
    }
    
    @discardableResult
    private func assert(
        sut: SUT? = nil,
        _ state: State,
        event: Event,
        updateStateToExpected: ((inout State) -> Void)? = nil,
        file: StaticString = #file,
        line: UInt = #line
    ) -> State {
        
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
        _ state: State,
        event: Event,
        delivers expectedEffect: SUT.Effect?,
        file: StaticString = #file,
        line: UInt = #line
    ) -> SUT.Effect? {
        
        let sut = sut ?? makeSUT(file: file, line: line)
        
        let (_, receivedEffect): (State, SUT.Effect?) = sut.reduce(state, event)
        
        XCTAssertNoDiff(
            receivedEffect,
            expectedEffect,
            "\nExpected \(String(describing: expectedEffect)), but got \(String(describing: receivedEffect)) instead.",
            file: file, line: line
        )
        
        return receivedEffect
    }
}
