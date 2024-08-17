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
    
    func test_dismiss_shouldNotChangeNilDestinationState() {
        
        assert(makeState(), event: .dismiss)
    }
    
    func test_dismiss_shouldNotDeliverEffectOnNilDestination() {
        
        assert(makeState(), event: .dismiss, delivers: nil)
    }
    
    func test_dismiss_shouldSetProfileDestinationToNil() {
        
        assert(makeState(destination: .profile(makeProfile())), event: .dismiss) {
            
            $0.destination = nil
        }
    }
    
    func test_dismiss_shouldNotDeliverEffectOnProfileDestination() {
        
        assert(makeState(destination: .profile(makeProfile())), event: .dismiss, delivers: nil)
    }
    
    func test_dismiss_shouldSetQRDestinationToNil() {
        
        assert(makeState(destination: .qr(makeQR())), event: .dismiss) {
            
            $0.destination = nil
        }
    }
    
    func test_dismiss_shouldNotDeliverEffectOnQRDestination() {
        
        assert(makeState(destination: .qr(makeQR())), event: .dismiss, delivers: nil)
    }
    
    // MARK: - open
    
    func test_open_profile_shouldNotChangeState() {
        
        assert(makeState(), event: .open(.profile))
    }
    
    func test_open_profile_shouldDeliverProfileEffect() {
        
        assert(makeState(), event: .open(.profile), delivers: .profile)
    }
    
    func test_open_qr_shouldNotChangeState() {
        
        assert(makeState(), event: .open(.qr))
    }
    
    func test_open_qr_shouldDeliverProfileEffect() {
        
        assert(makeState(), event: .open(.qr), delivers: .qr)
    }
    
    // MARK: - profile
    
    func test_profile_shouldChangeState() {
        
        let profile = makeProfile()
        
        assert(makeState(), event: .profile(profile)) {
            
            $0.destination = .profile(profile)
        }
    }
    
    func test_profile_shouldNotDeliverEffect() {
        
        assert(makeState(), event: .profile(makeProfile()), delivers: nil)
    }
    
    // MARK: - QR
    
    func test_qr_shouldChangeState() {
        
        let qr = makeQR()
        
        assert(makeState(), event: .qr(qr)) {
            
            $0.destination = .qr(qr)
        }
    }
    
    func test_qr_shouldNotDeliverEffect() {
        
        assert(makeState(), event: .qr(makeQR()), delivers: nil)
    }
    
    // MARK: - Helpers
    
    private typealias SUT = PaymentsTransfersFlowReducer<Profile, QR>
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> SUT {
        
        let sut = SUT()
        
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return sut
    }
    
    private func makeState(
        destination: SUT.State.Destination? = nil
    ) -> SUT.State {
        
        return .init(destination: destination)
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
