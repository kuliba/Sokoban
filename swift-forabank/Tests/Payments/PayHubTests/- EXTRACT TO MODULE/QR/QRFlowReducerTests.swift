//
//  QRFlowReducerTests.swift
//
//
//  Created by Igor Malyarov on 18.08.2024.
//

import XCTest

final class QRFlowReducerTests: QRFlowTests {
    
    // MARK: - cancel
    
    func test_cancel_shouldSetNavigationToCancel() {
        
        assert(makeState(), event: .cancel) {
            
            $0.navigation = .cancel
        }
    }
    
    func test_cancel_shouldNotDeliverEffect() {
        
        assert(makeState(), event: .cancel, delivers: nil)
    }
    
    // MARK: - destination
    
    func test_destination_shouldSetDestination() {
        
        let destination = makeDestination()
        
        assert(makeState(), event: .destination(destination)) {
            
            $0.navigation = .destination(destination)
        }
    }
    
    func test_destination_shouldNotDeliverEffect() {
        
        assert(makeState(), event: .destination(makeDestination()), delivers: nil)
    }
    
    // MARK: - dismissDestination
    
    func test_dismissDestination_shouldSetNavigationToCancel() {
        
        assert(makeState(), event: .dismissDestination) {
            
            $0.navigation = nil
        }
    }
    
    func test_dismissDestination_shouldNotDeliverEffect() {
        
        assert(makeState(), event: .dismissDestination, delivers: nil)
    }
    
    // MARK: - Helpers
    
    private typealias SUT = QRFlowReducer<Destination, ScanResult>
    
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
