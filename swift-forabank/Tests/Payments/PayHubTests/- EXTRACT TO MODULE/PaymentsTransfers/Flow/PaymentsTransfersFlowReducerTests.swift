//
//  PaymentsTransfersFlowReducerTests.swift
//
//
//  Created by Igor Malyarov on 17.08.2024.
//

import PayHub
import XCTest

final class PaymentsTransfersFlowReducerTests: PaymentsTransfersFlowTests {
    
    // MARK: - dismiss
    
    func test_dismiss_shouldNotChangeNilNavigationState() {
        
        assert(makeState(), event: .dismiss)
    }
    
    func test_dismiss_shouldNotDeliverEffectOnNilNavigation() {
        
        assert(makeState(), event: .dismiss, delivers: nil)
    }
    
    func test_dismiss_shouldSetProfileDestinationToNil() {
        
        assert(makeState(destination: .profile(makeProfile())), event: .dismiss) {
            
            $0.navigation = nil
        }
    }
    
    func test_dismiss_shouldNotDeliverEffectOnProfileDestination() {
        
        assert(makeState(destination: .profile(makeProfile())), event: .dismiss, delivers: nil)
    }
    
    func test_dismiss_shouldSetQRDestinationToNil() {
        
        assert(makeState(fullScreen: .qr(makeQR())), event: .dismiss) {
            
            $0.navigation = nil
        }
    }
    
    func test_dismiss_shouldNotDeliverEffectOnQRDestination() {
        
        assert(makeState(fullScreen: .qr(makeQR())), event: .dismiss, delivers: nil)
    }
    
    // MARK: - open
    
    func test_open_profile_shouldNotChangeNilNavigationState() {
        
        assert(makeState(), event: .open(.profile))
    }
    
    func test_open_profile_shouldDeliverProfileEffectOnNilNavigationState() {
        
        assert(makeState(), event: .open(.profile), delivers: .profile)
    }
    
    func test_open_profile_shouldNotChangeDestinationState() {
        
        assert(makeState(destination: .profile(makeProfile())), event: .open(.profile))
    }
    
    func test_open_profile_shouldNotDeliverProfileEffectOnDestinationState() {
        
        assert(makeState(destination: .profile(makeProfile())), event: .open(.profile), delivers: nil)
    }
    
    func test_open_profile_shouldNotChangeFullScreenState() {
        
        assert(makeState(fullScreen: .qr(makeQR())), event: .open(.profile))
    }
    
    func test_open_profile_shouldNotDeliverProfileEffectOnFullScreenState() {
        
        assert(makeState(fullScreen: .qr(makeQR())), event: .open(.profile), delivers: nil)
    }
    
    func test_open_qr_shouldNotChangeNilNavigationState() {
        
        assert(makeState(), event: .open(.qr))
    }
    
    func test_open_qr_shouldDeliverProfileEffectOnNilNavigationState() {
        
        assert(makeState(), event: .open(.qr), delivers: .qr)
    }
    
    func test_open_qr_shouldNotChangeDestinationState() {
        
        assert(makeState(destination: .profile(makeProfile())), event: .open(.qr))
    }
    
    func test_open_qr_shouldNotDeliverEffectOnDestinationState() {
        
        assert(makeState(destination: .profile(makeProfile())), event: .open(.qr), delivers: nil)
    }
    
    func test_open_qr_shouldNotChangeFullScreenState() {
        
        assert(makeState(fullScreen: .qr(makeQR())), event: .open(.qr))
    }
    
    func test_open_qr_shouldNotDeliverEffectOnFullScreenState() {
        
        assert(makeState(fullScreen: .qr(makeQR())), event: .open(.qr), delivers: nil)
    }
    
    // MARK: - profile
    
    func test_profile_shouldChangeNilNavigationState() {
        
        let profile = makeProfile()
        
        assert(makeState(), event: .profile(profile)) {
            
            $0.navigation = .destination(.profile(profile))
        }
    }
    
    func test_profile_shouldNotDeliverEffectOnNilNavigationState() {
        
        assert(makeState(), event: .profile(makeProfile()), delivers: nil)
    }
    
    // MARK: - QR
    
    func test_qr_shouldChangeNilNavigationState() {
        
        let qr = makeQR()
        
        assert(makeState(), event: .qr(qr)) {
            
            $0.navigation = .fullScreen(.qr(qr))
        }
    }
    
    func test_qr_shouldNotDeliverEffectOnNilNavigationState() {
        
        assert(makeState(), event: .qr(makeQR()), delivers: nil)
    }
    
    // MARK: - Helpers
    
    private typealias SUT = PaymentsTransfersFlowReducer<Profile, QR>
    private typealias Navigation = SUT.State.Navigation
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> SUT {
        
        let sut = SUT()
        
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return sut
    }
    
    private func makeState(
        destination: Navigation.Destination? = nil
    ) -> SUT.State {
        
        return .init(
            navigation: destination.map { .destination($0) }
        )
    }
    
    private func makeState(
        fullScreen: Navigation.FullScreen
    ) -> SUT.State {
        
        return .init(navigation: .fullScreen(fullScreen))
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
