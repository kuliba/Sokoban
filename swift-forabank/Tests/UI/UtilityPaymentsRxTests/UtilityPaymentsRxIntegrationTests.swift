//
//  UtilityPaymentsRxIntegrationTests.swift
//
//
//  Created by Igor Malyarov on 19.02.2024.
//

import RxViewModel
import UtilityPaymentsRx
import XCTest

private typealias UtilityPaymentsViewModel = RxViewModel<UtilityPaymentsState, UtilityPaymentsEvent, UtilityPaymentsEffect>

final class UtilityPaymentsRxIntegrationTests: XCTestCase {
    
    func test_init_shouldNotCallCollaborators() {
        
        let (_,_, loadLastPaymentsSpy, loadOperatorsSpy, paginator) = makeSUT()
        
        XCTAssertEqual(loadLastPaymentsSpy.callCount, 0)
        XCTAssertEqual(loadOperatorsSpy.callCount, 0)
        XCTAssertEqual(paginator.callCount, 0)
    }
    
    func test_init_shouldNotChangeInitialState() {
        
        let initialState: State = .init()
        let stateSpy = makeSUT(initialState: initialState).stateSpy
        
        XCTAssertNoDiff(stateSpy.values, [])
    }
    
    func test_flow___() {
        
        let initialState: State = .init()
        let (sut, stateSpy, loadLastPaymentsSpy, loadOperatorsSpy, _) = makeSUT(initialState: initialState)
        
        sut.event(.initiate)
        sut.event(.initiate)
        sut.event(.initiate)
        
        loadLastPaymentsSpy.complete(with: .failure(.connectivityError))
        loadOperatorsSpy.complete(with: .failure(.connectivityError))
        
        loadLastPaymentsSpy.complete(with: .success(.init()))
        loadOperatorsSpy.complete(with: .success(.init()))
        
        loadLastPaymentsSpy.complete(with: .success(.stub))
        loadOperatorsSpy.complete(with: .success(.stub))
        
        assert(
            stateSpy, initialState,
            {
                $0.status = .inflight
            }, {
                $0.status = .failure(.connectivityError) },
            {
                $0.lastPayments = .init()
                $0.status = .none
            }, {
                $0.operators = .init()
            }, {
                $0.lastPayments = .stub
            }, {
                $0.operators = .stub
            }
        )
    }
    
    // MARK: - Helpers
    
    private typealias SUT = UtilityPaymentsViewModel
    private typealias State = UtilityPaymentsState
    private typealias Event = UtilityPaymentsEvent
    private typealias Effect = UtilityPaymentsEffect
    
    private typealias StateSpy = ValueSpy<State>
    private typealias LoadLastPaymentsSpy = Spy<Void, LoadLastPaymentsResult>
    private typealias LoadOperatorsSpy = Spy<Void, LoadOperatorsResult>
    private typealias Paginator = Spy<Void, [Operator]>
    
    private func makeSUT(
        initialState: UtilityPaymentsState = .init(),
        observeLast: Int = 0,
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        stateSpy: StateSpy,
        loadLastPaymentsSpy: LoadLastPaymentsSpy,
        loadOperatorsSpy: LoadOperatorsSpy,
        paginator: Paginator
    ) {
        let reducer = UtilityPaymentsReducer(observeLast: observeLast)
        
        let loadLastPaymentsSpy = LoadLastPaymentsSpy()
        let loadOperatorsSpy = LoadOperatorsSpy()
        let paginator = Paginator()
        let effectHandler = UtilityPaymentsEffectHandler(
            loadLastPayments: loadLastPaymentsSpy.process(completion:),
            loadOperators: loadOperatorsSpy.process(completion:),
            paginate: paginator.process(completion:)
        )
        
        let sut = SUT(
            initialState: initialState,
            reduce: reducer.reduce(_:_:),
            handleEffect: effectHandler.handleEffect(_:_:),
            scheduler: .immediate
        )
        let stateSpy = StateSpy(sut.$state.dropFirst())
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(reducer, file: file, line: line)
        trackForMemoryLeaks(effectHandler, file: file, line: line)
        trackForMemoryLeaks(loadLastPaymentsSpy, file: file, line: line)
        trackForMemoryLeaks(loadOperatorsSpy, file: file, line: line)
        trackForMemoryLeaks(stateSpy, file: file, line: line)
        
        return (sut, stateSpy, loadLastPaymentsSpy, loadOperatorsSpy, paginator)
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

import Tagged

private extension Array where Element == LastPayment {
    
    static let stub: Self = (0..<9)
        .map { $0 }
        .map(String.init)
        .map { .init(id: .init($0)) }
}

private extension Array where Element == Operator {
    
    static let stub: Self = (0..<9)
        .map { $0 }
        .map(String.init)
        .map { .init(id: .init($0)) }
}
