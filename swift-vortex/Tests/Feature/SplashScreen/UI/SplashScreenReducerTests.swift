//
//  SplashScreenReducerTests.swift
//
//
//  Created by Igor Malyarov on 13.03.2025.
//

import SplashScreenUI
import SwiftUI
import XCTest

final class SplashScreenReducerTests: XCTestCase {
    
    // MARK: - hide
    
    func test_hide_shouldChangePhaseToHidden_onCover() {
        
        assert(cover(), event: .hide) { $0.phase = .hidden }
    }
    
    func test_hide_shouldNotDeliverEffect_onCover() {
        
        assert(cover(), event: .hide, delivers: nil)
    }
    
    func test_hide_shouldChangePhaseToHidden_onWarm() {
        
        assert(warm(), event: .hide) { $0.phase = .hidden }
    }
    
    func test_hide_shouldNotDeliverEffect_onWarm() {
        
        assert(warm(), event: .hide, delivers: nil)
    }
    
    func test_hide_shouldChangePhaseToHidden_onPresented() {
        
        assert(presented(), event: .hide) { $0.phase = .hidden }
    }
    
    func test_hide_shouldNotDeliverEffect_onPresented() {
        
        assert(presented(), event: .hide, delivers: nil)
    }
    
    func test_hide_shouldNotChangeState_onHidden() {
        
        assert(hidden(), event: .hide)
    }
    
    func test_hide_shouldNotDeliverEffect_onHidden() {
        
        assert(hidden(), event: .hide, delivers: nil)
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
        phase: SplashScreenState.Phase,
        settings: SplashScreenState.Settings? = nil
    ) -> SUT.State {
        
        return .init(phase: phase, settings: settings ?? makeSettings())
    }
    
    private func cover(
        settings: SplashScreenState.Settings? = nil
    ) -> SUT.State {
        
        return makeState(phase: .cover, settings: settings)
    }
    
    private func warm(
        settings: SplashScreenState.Settings? = nil
    ) -> SUT.State {
        
        return makeState(phase: .warm, settings: settings)
    }
    
    private func presented(
        settings: SplashScreenState.Settings? = nil
    ) -> SUT.State {
        
        return makeState(phase: .presented, settings: settings)
    }
    
    private func hidden(
        settings: SplashScreenState.Settings? = nil
    ) -> SUT.State {
        
        return makeState(phase: .hidden, settings: settings)
    }
    
    private func makeSettings(
        image: Image = .init(systemName: "star"),
        bank: SUT.State.Settings.Logo? = nil,
        text: SUT.State.Settings.Text? = nil,
        subtext: SUT.State.Settings.Text? = nil,
        footer: SUT.State.Settings.Logo? = nil
    ) -> SUT.State.Settings {
        
        return .init(
            image: image,
            bank: bank ?? makeBank(),
            text: text ?? makeText(),
            subtext: subtext,
            footer: footer ?? makeFooter()
        )
    }
    
    private func makeBank(
        color: Color = .red,
        shadow: SplashScreenState.Settings.Shadow? = nil
    ) -> SUT.State.Settings.Logo {
        
        return .init(color: color, shadow: shadow ?? makeShadow())
    }
    
    private func makeFooter(
        color: Color = .red,
        shadow: SplashScreenState.Settings.Shadow? = nil
    ) -> SUT.State.Settings.Logo {
        
        return .init(color: color, shadow: shadow ?? makeShadow())
    }
    
    private func makeText(
        color: Color = .primary,
        size: CGFloat = .random(in: 1..<100),
        value: String = anyMessage(),
        shadow: SplashScreenState.Settings.Shadow? = nil
    ) -> SUT.State.Settings.Text {
        
        return .init(
            color: color,
            size: size,
            value: value,
            shadow: shadow ?? makeShadow()
        )
    }
    
    private func makeShadow(
        color: Color = .primary,
        opacity: Double = .random(in: 1..<100),
        radius: CGFloat = .random(in: 1..<100),
        x: CGFloat = .random(in: 1..<100),
        y: CGFloat = .random(in: 1..<100)
    ) -> SUT.State.Settings.Shadow {
     
        return .init(color: color, opacity: opacity, radius: radius, x: x, y: y)
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
