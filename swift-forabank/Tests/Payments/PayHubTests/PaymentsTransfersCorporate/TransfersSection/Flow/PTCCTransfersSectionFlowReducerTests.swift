//
//  PTCCTransfersSectionFlowReducerTests.swift
//
//
//  Created by Igor Malyarov on 04.09.2024.
//

struct PTCCTransfersSectionFlowState: Equatable {}

enum PTCCTransfersSectionFlowEvent<Select> {
    
    case select(Select)
}

extension PTCCTransfersSectionFlowEvent: Equatable where Select: Equatable {}

enum PTCCTransfersSectionFlowEffect<Select> {
    
    case select(Select)
}

extension PTCCTransfersSectionFlowEffect: Equatable where Select: Equatable {}

final class PTCCTransfersSectionFlowReducer<Select> {
    
    init() {}
}

extension PTCCTransfersSectionFlowReducer {
    
    func reduce(
        _ state: State,
        _ event: Event
    ) -> (State, Effect?) {
        
        var state = state
        var effect: Effect?
        
        switch event {
        case let .select(select):
            effect = .select(select)
        }
        
        return (state, effect)
    }
}

extension PTCCTransfersSectionFlowReducer {
    
    typealias State = PTCCTransfersSectionFlowState
    typealias Event = PTCCTransfersSectionFlowEvent<Select>
    typealias Effect = PTCCTransfersSectionFlowEffect<Select>
}

import XCTest

final class PTCCTransfersSectionFlowReducerTests: PTCCTransfersSectionFlowTests {
    
    // MARK: - select
    
    func test_select_shouldNotChangeState() {
        
        assert(makeState(), event: .select(makeSelect()))
    }
    
    func test_select_shouldDeliverSelectEffectWithSelection() {
        
        let selection = makeSelect()
        
        assert(makeState(), event: .select(selection), delivers: .select(selection))
    }
    
    // MARK: - Helpers
    
    private typealias SUT = PTCCTransfersSectionFlowReducer<Select>
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> SUT {
        
        let sut = SUT()
        
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return sut
    }
    
    private func makeState() -> SUT.State {
        
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
