//
//  PaymentsTransfersFlowReducerTests.swift
//
//
//  Created by Igor Malyarov on 17.08.2024.
//

struct PaymentsTransfersFlowState<Profile, QR> {
    
    var destination: Destination?
}

extension PaymentsTransfersFlowState {
    
    enum Destination {
        
        case profile(Profile)
    }
}

extension PaymentsTransfersFlowState: Equatable where Profile: Equatable, QR: Equatable {}
extension PaymentsTransfersFlowState.Destination: Equatable where Profile: Equatable, QR: Equatable {}

final class PaymentsTransfersFlowReducer<Profile, QR> {}

extension PaymentsTransfersFlowReducer {
    
    func reduce(
        _ state: State,
        _ event: Event
    ) -> (State, Effect?) {
        
        var state = state
        var effect: Effect?
        
        switch event {
        case let .profile(profile):
            state.destination = .profile(profile)
            
        default:
            break
        }
        
        return (state, effect)
    }
}

extension PaymentsTransfersFlowReducer {
    
    typealias State = PaymentsTransfersFlowState<Profile, QR>
    typealias Event = PaymentsTransfersFlowEvent<Profile, QR>
    typealias Effect = PaymentsTransfersFlowEffect
}


import XCTest

final class PaymentsTransfersFlowReducerTests: PaymentsTransfersFlowTests {
    
    func test_profile_shouldChangeState() {
        
        let profile = makeProfile()
        
        assert(makeState(), event: .profile(profile)) {
            
            $0.destination = .profile(profile)
        }
    }
    
    func test_profile_shouldNotDeliverEffect() {
        
        assert(makeState(), event: .profile(makeProfile()), delivers: nil)
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
    ) -> SUT.State {
        
        return .init()
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
