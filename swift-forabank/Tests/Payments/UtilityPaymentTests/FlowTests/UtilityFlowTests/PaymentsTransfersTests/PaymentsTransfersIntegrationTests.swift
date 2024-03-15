//
//  PaymentsTransfersIntegrationTests.swift
//
//
//  Created by Igor Malyarov on 15.03.2024.
//

import RxViewModel
import UtilityPayment
import XCTest

final class PaymentsTransfersIntegrationTests: XCTestCase {
    
    // MARK: - back
    
    func test_back_shouldNotChangeNilRouteState() {
        
        let (sut, spy) = makeSUT(initialRoute: nil)
        
        sut.event(.back)
        sut.event(.back)
        sut.event(.back)
        
        assert(
            spy,
            .init(route: nil),
            { _ in }
        )
    }
    
    func test_flow() {
        
        let (sut, spy) = makeSUT(initialRoute: nil)
        
        sut.event(.start(.utilityFlow))
        
        assert(
            spy,
            .init(route: nil),
            { _ in }
        )
    }
    
    // MARK: - Helpers
    
    private typealias SUT = RxViewModel<State, Event, Effect>
    
    private typealias Reducer = PaymentsTransfersReducer<LastPayment, Operator>
    private typealias UtilityReducer = UtilityFlowReducer<LastPayment, Operator>
    
    private typealias Destination = UtilityDestination<LastPayment, Operator>
    
    private typealias StateSpy = ValueSpy<State>
    
    private typealias State = PaymentsTransfersState<Destination>
    private typealias Event = PaymentsTransfersEvent
    private typealias Effect = PaymentsTransfersEffect
    
    private func makeSUT(
        initialRoute: State.Route? = nil,
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        spy: StateSpy
    ) {
        let utilityReducer = UtilityReducer()
        let reducer = Reducer(
            utilityReduce: utilityReducer.reduce(_:_:)
        )
        
        let effectHandler = PaymentsTransfersEffectHandler()
        
        let sut = SUT(
            initialState: .init(route: initialRoute),
            reduce: reducer.reduce(_:_:),
            handleEffect: effectHandler.handleEffect(_:_:)
        )
        
        let spy = StateSpy(sut.$state)
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(spy, file: file, line: line)
        trackForMemoryLeaks(reducer, file: file, line: line)
        trackForMemoryLeaks(effectHandler, file: file, line: line)
        
        return (sut, spy)
    }
    
    private func assert(
        _ spy: StateSpy,
        _ initialState: State,
        _ updates: ((inout State) -> Void)...,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        var state = initialState
        var values = [State]()
        
        for update in updates {
            
            update(&state)
            values.append(state)
        }
        
        XCTAssertNoDiff(spy.values, values, file: file, line: line)
    }
}
