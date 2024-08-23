//
//  PaymentsTransfersToolbarReducerTests.swift
//
//
//  Created by Igor Malyarov on 22.08.2024.
//

import PayHub
import XCTest

final class PaymentsTransfersToolbarReducerTests: XCTestCase {
    
    // MARK: - select
    
    func test_deselect_shouldChangeNonNilState() {
        
        let state = makeState(selection: anyNavigation())
        
        assert(state, event: .select(nil)) {
            
            $0.selection = nil
        }
    }
    
    func test_deselect_shouldNotDeliverEffectOnNonNilState() {
        
        let state = makeState(selection: anyNavigation())
        
        assert(state, event: .select(nil), delivers: nil)
    }
    
    func test_select_profile_shouldChangeNilState() {
        
        let state = makeState(selection: nil)
        
        assert(state, event: .select(.qr)) {
            
            $0.selection = .qr
        }
    }
    
    func test_select_profile_shouldNotDeliverEffectOnNilState() {
        
        let state = makeState(selection: nil)
        
        assert(state, event: .select(.profile), delivers: nil)
    }
    
    func test_select_profile_shouldChangeNonNilState() {
        
        let state = makeState(selection: anyNavigation())
        
        assert(state, event: .select(.profile)) {
            
            $0.selection = .profile
        }
    }
    
    func test_select_profile_shouldNotDeliverEffectOnNonNilState() {
        
        let state = makeState(selection: nil)
        
        assert(state, event: .select(.profile), delivers: nil)
    }
    
    func test_select_qr_shouldChangeNilState() {
        
        let state = makeState(selection: nil)
        
        assert(state, event: .select(.qr)) {
            
            $0.selection = .qr
        }
    }
    
    func test_select_qr_shouldNotDeliverEffectOnNilState() {
        
        let state = makeState(selection: nil)
        
        assert(state, event: .select(.qr), delivers: nil)
    }
    
    func test_select_qr_shouldChangeNonNilState() {
        
        let state = makeState(selection: anyNavigation())
        
        assert(state, event: .select(.qr)) {
            
            $0.selection = .qr
        }
    }
    
    func test_select_qr_shouldNotDeliverEffectOnNonNilState() {
        
        let state = makeState(selection: nil)
        
        assert(state, event: .select(.qr), delivers: nil)
    }
    
    // MARK: - Helpers
    
    private typealias SUT = PaymentsTransfersToolbarReducer
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> SUT {
        
        let sut = SUT()
        
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return sut
    }
    
    private func makeState(
        selection: SUT.State.Selection? = nil
    ) -> SUT.State {
        
        return .init(selection: selection)
    }
    
    private func anyNavigation(
    ) -> SUT.State.Selection {
        
        return .profile
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
