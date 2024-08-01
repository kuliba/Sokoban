//
//  PrepaymentPickerReducerTests.swift
//
//
//  Created by Igor Malyarov on 11.05.2024.
//

import UtilityServicePrepaymentCore
import XCTest

final class PrepaymentPickerReducerTests: XCTestCase {
    
    func test_event_shouldNotChangeFailureState() {
        
        assertState(.didScrollTo(makeOperatorID()), on: .failure(anyError()))
    }
    
    func test_event_shouldNotDeliverEffectOnFailureState() {
        
        assert(.didScrollTo(makeOperatorID()), on: .failure(anyError()), effect: nil)
    }
    
    func test_event_shouldCallSuccessReduceWithSuccessAndEventOnSuccessState() {
        
        var messages = [(success: SUT.Success, event: Event)]()
        let success = makeState()
        let event = Event.didScrollTo("")
        let sut = makeSUT(reduce: {
            
            messages.append(($0, $1))
            return ($0, nil)
        })
        
        _ = sut.reduce(.success(success), event)
        
        XCTAssertNoDiff(messages.map(\.success), [success])
        XCTAssertNoDiff(messages.map(\.event), [event])
    }
    
    func test_event_shouldDeliverSuccessReduceResultOnSuccessState() {
        
        let newSuccess = makeState(operators: [makeOperator()])
        let sut = makeSUT(reduce: { _,_ in
            
            return (newSuccess, nil)
        })
        
        assertState(sut: sut, .didScrollTo(""), on: .success(makeState())) {
            
            $0 = .success(newSuccess)
        }
    }
    
    func test_event_shouldDeliverSuccessReduceEffectOnSuccessState() {
        
        let newEffect = Effect.paginate(makePaginatePayload())
        let sut = makeSUT(reduce: { _,_ in
            
            return (makeState(), newEffect)
        })
        
        assert(sut: sut, .didScrollTo(""), on: .success(makeState()), effect: newEffect)
    }
    
    // MARK: - Helpers
    
    private typealias SUT = PrepaymentPickerReducer<LastPayment, Operator>
    
    private func makeSUT(
        reduce: @escaping SUT.SuccessReduce = { state, _ in (state, nil) },
        file: StaticString = #file,
        line: UInt = #line
    ) -> SUT {
        
        let sut = SUT(successReduce: reduce)
        
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return sut
    }
    
    private typealias UpdateStateToExpected<State> = (_ state: inout State) -> Void
    
    private func assertState(
        sut: SUT? = nil,
        _ event: Event,
        on state: SUT.State,
        updateStateToExpected: UpdateStateToExpected<SUT.State>? = nil,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let sut = sut ?? makeSUT(file: file, line: line)
        
        var expectedState = state
        updateStateToExpected?(&expectedState)
        
        let (receivedState, _) = sut.reduce(state, event)
        
        switch (expectedState, receivedState) {
        case let (
            .failure(expectedFailure as NSError),
            .failure(receivedFailure as NSError)
        ):
            XCTAssertNoDiff(
                expectedFailure,
                receivedFailure,
                "\nExpected \(expectedFailure), but got \(receivedFailure) instead.",
                file: file, line: line
            )
            
        case let (
            .success(expectedSuccess),
            .success(receivedSuccess)
        ):
            XCTAssertNoDiff(
                expectedSuccess,
                receivedSuccess,
                "\nExpected \(expectedSuccess), but got \(receivedSuccess) instead.",
                file: file, line: line
            )
            
        default:
            XCTFail("\nExpected \(expectedState), but got \(receivedState) instead.")
        }
    }
    
    private func assert(
        sut: SUT? = nil,
        _ event: Event,
        on state: SUT.State,
        effect expectedEffect: Effect?,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let sut = sut ?? makeSUT(file: file, line: line)
        let (_, receivedEffect) = sut.reduce(state, event)
        
        XCTAssertNoDiff(
            receivedEffect,
            expectedEffect,
            "\nExpected \(String(describing: expectedEffect)), but got \(String(describing: receivedEffect)) instead.",
            file: file, line: line
        )
    }
}
