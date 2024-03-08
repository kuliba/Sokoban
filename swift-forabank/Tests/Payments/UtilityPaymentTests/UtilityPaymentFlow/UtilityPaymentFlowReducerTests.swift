//
//  UtilityPaymentFlowReducerTests.swift
//
//
//  Created by Igor Malyarov on 08.03.2024.
//

import PrePaymentPicker
import UtilityPayment
import XCTest

final class UtilityPaymentFlowReducerTests: XCTestCase {
    
    func test_init_shouldNotCallCollaborators() {
        
        let (_, ppoReducer, prePaymentReducer) = makeSUT()
        
        XCTAssertEqual(ppoReducer.callCount, 0)
        XCTAssertEqual(prePaymentReducer.callCount, 0)
    }
    
    // MARK: - Helpers
    
    private typealias SUT = UtilityPaymentFlowReducer<LastPayment, Operator>
    
    private typealias PPOState = PrePaymentOptionsState<LastPayment, Operator>
    private typealias PPOEvent = PrePaymentOptionsEvent<LastPayment, Operator>
    private typealias PPOEffect = PrePaymentOptionsEffect<Operator>
    private typealias PPOReducer = ReducerSpy<PPOState, PPOEvent, PPOEffect>
    
    private typealias PrePaymentReducer = ReducerSpy<PrePaymentState, PrePaymentEvent, PrePaymentEffect>
    
    private func makeSUT(
        ppoStub: [(PPOState, PPOEffect?)] = [],
        prePaymentStub: [(PrePaymentState, PrePaymentEffect?)] = [],
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        ppoReducer: PPOReducer,
        prePaymentReducer: PrePaymentReducer
    ) {
        let ppoReducer = PPOReducer(stub: ppoStub)
        let prePaymentReducer = PrePaymentReducer(stub: prePaymentStub)
        let sut = SUT(
            prePaymentOptionsReduce: ppoReducer.reduce,
            prePaymentReduce: prePaymentReducer.reduce
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(ppoReducer, file: file, line: line)
        trackForMemoryLeaks(prePaymentReducer, file: file, line: line)
        
        return (sut, ppoReducer, prePaymentReducer)
    }
}

private struct LastPayment: Equatable {
    
    var value: String
}

private struct Operator: Equatable, Identifiable {
    
    var value: String
    
    var id: String { value }
}
