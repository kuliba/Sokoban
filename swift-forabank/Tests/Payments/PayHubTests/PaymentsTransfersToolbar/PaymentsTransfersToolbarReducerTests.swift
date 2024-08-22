//
//  PaymentsTransfersToolbarReducerTests.swift
//
//
//  Created by Igor Malyarov on 22.08.2024.
//

import PayHub
import XCTest

final class PaymentsTransfersToolbarReducerTests: PaymentsTransfersToolbarTests {
    
    // MARK: - dismiss
    
    func test_dismiss_shouldSetNavigationToNil() {
        
        let state = makeState(navigation: anyNavigation())
        
        assert(state, event: .dismiss) {
            
            $0.navigation = nil
        }
    }
    
    func test_dismiss_shouldNotDeliverEffect() {
        
        let state = makeState(navigation: anyNavigation())
        
        assert(state, event: .dismiss, delivers: nil)
    }
    
    func test_dismiss_shouldNotChangeNilNavigation() {
        
        let state = makeState(navigation: nil)
        
        assert(state, event: .dismiss) {
            
            $0.navigation = nil
        }
    }
    
    func test_dismiss_shouldNotDeliverEffectOnNilNavigation() {
        
        let state = makeState(navigation: nil)
        
        assert(state, event: .dismiss, delivers: nil)
    }
    
    // MARK: - profile
    
    func test_profile_shouldChangeNilNavigation() {
        
        let profile = makeProfile()
        let state = makeState(navigation: nil)
        
        assert(state, event: .profile(profile)) {
            
            $0.navigation = .profile(profile)
        }
    }
    
    func test_profile_shouldNotDeliverEffectOnNilNavigation() {
        
        let state = makeState(navigation: nil)
        
        assert(state, event: .profile(makeProfile()), delivers: nil)
    }
    
    func test_profile_shouldChangeNonNilNavigation() {
        
        let profile = makeProfile()
        let state = makeState(navigation: anyNavigation())
        
        assert(state, event: .profile(profile)) {
            
            $0.navigation = .profile(profile)
        }
    }
    
    func test_profile_shouldNotDeliverEffectOnNonNilNavigation() {
        
        let state = makeState(navigation: anyNavigation())
        
        assert(state, event: .profile(makeProfile()), delivers: nil)
    }
    
    // MARK: - qr
    
    func test_qr_shouldChangeNilNavigation() {
        
        let qr = makeQR()
        let state = makeState(navigation: nil)
        
        assert(state, event: .qr(qr)) {
            
            $0.navigation = .qr(qr)
        }
    }
    
    func test_qr_shouldNotDeliverEffectOnNilNavigation() {
        
        let state = makeState(navigation: nil)
        
        assert(state, event: .qr(makeQR()), delivers: nil)
    }
    
    func test_qr_shouldChangeNonNilNavigation() {
        
        let qr = makeQR()
        let state = makeState(navigation: anyNavigation())
        
        assert(state, event: .qr(qr)) {
            
            $0.navigation = .qr(qr)
        }
    }
    
    func test_qr_shouldNotDeliverEffectOnNonNilNavigation() {
        
        let state = makeState(navigation: anyNavigation())
        
        assert(state, event: .qr(makeQR()), delivers: nil)
    }
    
    // MARK: - select
    
    func test_select_profile_shouldNotChangeNilState() {
        
        let state = makeState(navigation: nil)
        
        assert(state, event: .select(.qr))
    }
    
    func test_select_profile_shouldDeliverEffectOnNilState() {
        
        let state = makeState(navigation: nil)
        
        assert(state, event: .select(.profile), delivers: .select(.profile))
    }
    
    func test_select_profile_shouldResetNonNilState() {
        
        let state = makeState(navigation: anyNavigation())
        
        assert(state, event: .select(.profile)) {
            
            $0.navigation = nil
        }
    }
    
    func test_select_profile_shouldDeliverEffectOnNonNilState() {
        
        let state = makeState(navigation: nil)
        
        assert(state, event: .select(.profile), delivers: .select(.profile))
    }
    
    func test_select_qr_shouldNotChangeNilState() {
        
        let state = makeState(navigation: nil)
        
        assert(state, event: .select(.qr))
    }
    
    func test_select_qr_shouldDeliverEffectOnNilState() {
        
        let state = makeState(navigation: nil)
        
        assert(state, event: .select(.qr), delivers: .select(.qr))
    }
    
    func test_select_qr_shouldResetNonNilState() {
        
        let state = makeState(navigation: anyNavigation())
        
        assert(state, event: .select(.qr)) {
            
            $0.navigation = nil
        }
    }
    
    func test_select_qr_shouldDeliverEffectOnNonNilState() {
        
        let state = makeState(navigation: nil)
        
        assert(state, event: .select(.qr), delivers: .select(.qr))
    }
    
    // MARK: - Helpers
    
    private typealias SUT = PaymentsTransfersToolbarReducer<Profile, QR>
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> SUT {
        
        let sut = SUT()
        
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return sut
    }
    
    private func makeState(
        navigation: SUT.State.Navigation? = nil
    ) -> SUT.State {
        
        return .init(navigation: navigation)
    }
    
    private func anyNavigation(
    ) -> SUT.State.Navigation {
        
        return .profile(makeProfile())
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
        
        let (_, receivedEffect) = sut.reduce(state, event)
        
        XCTAssertNoDiff(
            receivedEffect,
            expectedEffect,
            "\nExpected \(String(describing: expectedEffect)), but got \(String(describing: receivedEffect)) instead.",
            file: file, line: line
        )
        
        return receivedEffect
    }
}
