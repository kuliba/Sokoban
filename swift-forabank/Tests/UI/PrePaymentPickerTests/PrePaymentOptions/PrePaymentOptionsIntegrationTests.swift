//
//  PrePaymentOptionsIntegrationTests.swift
//
//
//  Created by Igor Malyarov on 19.02.2024.
//

import RxViewModel
import PrePaymentPicker
import XCTest

final class PrePaymentOptionsIntegrationTests: XCTestCase {
    
    // MARK: - init
    
    func test_init_shouldNotCallCollaborators() {
        
        let (_,_, loadLastPaymentsSpy, loadOperatorsSpy) = makeSUT()
        
        XCTAssertEqual(loadLastPaymentsSpy.callCount, 0)
        XCTAssertEqual(loadOperatorsSpy.callCount, 0)
        XCTAssertEqual(loadOperatorsSpy.callCount, 0)
    }
    
    func test_init_shouldNotChangeInitialState() {
        
        let initialState: State = .init()
        let stateSpy = makeSUT(initialState: initialState).stateSpy
        
        XCTAssertNoDiff(stateSpy.values, [])
    }
    
    // MARK: - didScroll
    
    func test_didScroll_shouldNotCallForAdditionalDataOnEmpty() {
        
        let observeLast = 3
        let emptyInitialState: State = .init()
        let (sut, _, _, loadOperatorsSpy) = makeSUT(
            initialState: emptyInitialState,
            observeLast: observeLast
        )
        XCTAssertNoDiff(loadOperatorsSpy.callCount, 0)
        
        sut.event(.didScrollTo("6"))
        
        XCTAssertNoDiff(loadOperatorsSpy.callCount, 0)
    }
    
    func test_didScroll_shouldNotCallForAdditionalDataForIDOutOfObservedRange() {
        
        let observeLast = 3
        let (sut, _, _, loadOperatorsSpy) = makeSUT(
            initialState: .init(operators: .stub),
            observeLast: observeLast
        )
        XCTAssertNoDiff(loadOperatorsSpy.callCount, 0)
        
        sut.event(.didScrollTo("6"))
        
        XCTAssertNoDiff(loadOperatorsSpy.callCount, 0)
    }
    
    func test_didScroll_shouldCallForAdditionalDataForIDInObservedRange() {
        
        let observeLast = 3
        let pageSize = 99
        let (sut, _, _, loadOperatorsSpy) = makeSUT(
            initialState: .init(operators: .stub),
            observeLast: observeLast,
            pageSize: pageSize
        )
        XCTAssertNoDiff(loadOperatorsSpy.callCount, 0)
        
        sut.event(.didScrollTo("7"))
        
        XCTAssertEqual(loadOperatorsSpy.payloads.map(\.?.0), ["7"])
        XCTAssertEqual(loadOperatorsSpy.payloads.map(\.?.1), [pageSize])
    }
    
    func test_didScroll_shouldCallForAdditionalDataForIDInObservedRange_2() {
        
        let observeLast = 3
        let pageSize = 99
        let (sut, _, _, loadOperatorsSpy) = makeSUT(
            initialState: .init(operators: .stub),
            observeLast: observeLast,
            pageSize: pageSize
        )
        XCTAssertNoDiff(loadOperatorsSpy.callCount, 0)
        
        sut.event(.didScrollTo("8"))
        
        XCTAssertEqual(loadOperatorsSpy.payloads.map(\.?.0), ["8"])
        XCTAssertEqual(loadOperatorsSpy.payloads.map(\.?.1), [pageSize])
    }
    
    func test_didScroll_shouldCallForAdditionalDataForIDInObservedRange_3() {
        
        let observeLast = 3
        let pageSize = 99
        let (sut, _, _, loadOperatorsSpy) = makeSUT(
            initialState: .init(operators: .stub),
            observeLast: observeLast,
            pageSize: pageSize
        )
        XCTAssertNoDiff(loadOperatorsSpy.callCount, 0)
        
        sut.event(.didScrollTo("9"))
        
        XCTAssertEqual(loadOperatorsSpy.payloads.map(\.?.0), ["9"])
        XCTAssertEqual(loadOperatorsSpy.payloads.map(\.?.1), [pageSize])
    }
    
    func test_didScroll_shouldAppendPaginatedData() {
        
        let observeLast = 3
        let initialState: State = .init(operators: .stub)
        let (sut, stateSpy, _, loadOperatorsSpy) = makeSUT(
            initialState: initialState,
            observeLast: observeLast
        )
        
        sut.event(.didScrollTo("9"))
        loadOperatorsSpy.complete(with: .success([.init(id: "111")]))
        
        assert(
            stateSpy, initialState,
            { _ in },
            {
                var operators = $0.operators
                operators?.append(.init(id: "111"))
                $0.operators = operators
            }
        )
    }
    
    func test_didScroll_shouldNotChangeStateOnPaginatorDeliveringEmptyData() {
        
        let observeLast = 3
        let initialState: State = .init(operators: .stub)
        let (sut, stateSpy, _, loadOperatorsSpy) = makeSUT(
            initialState: initialState,
            observeLast: observeLast
        )
        
        sut.event(.didScrollTo("9"))
        loadOperatorsSpy.complete(with: .success([]))
        
        assert(
            stateSpy, initialState,
            { _ in }
        )
    }
    
    // MARK: - sample flow
    
    func test_sampleFlow() {
        
        let initialState: State = .init()
        let (sut, stateSpy, loadLastPaymentsSpy, loadOperatorsSpy) = makeSUT(
            initialState: initialState,
            observeLast: 1
        )
        
        sut.event(.initiate)
        sut.event(.initiate)
        sut.event(.initiate)
        
        loadLastPaymentsSpy.complete(with: .failure(.connectivityError))
        loadOperatorsSpy.complete(with: .failure(.connectivityError))
        
        loadLastPaymentsSpy.complete(with: .success(.init()), at: 1)
        loadOperatorsSpy.complete(with: .success(.init()), at: 1)
        
        loadLastPaymentsSpy.complete(with: .success(.stub), at: 2)
        loadOperatorsSpy.complete(with: .success(.stub), at: 2)
        
        sut.event(.didScrollTo("5"))
        sut.event(.didScrollTo("8"))
        
        assert(
            stateSpy, initialState,
            {
                $0.isInflight = true
            }, {
                $0.isInflight = false
            }, {
                $0.lastPayments = .init()
                $0.operators = .init()
                $0.isInflight = false
            }, {
                $0.lastPayments = .stub
                $0.operators = .stub
            }
        )
        
        sut.event(.didScrollTo("9"))
        loadOperatorsSpy.complete(with: .success([.init(id: "111")]), at: 3)
        
        sut.event(.search(.entered("abc")))
        
        assert(
            stateSpy, initialState,
            {
                $0.isInflight = true
            }, {
                $0.isInflight = false
            }, {
                $0.lastPayments = .init()
                $0.operators = .init()
                $0.isInflight = false
            }, {
                $0.lastPayments = .stub
                $0.operators = .stub
            }, {
                var operators = $0.operators
                operators?.append(.init(id: "111"))
                $0.operators = operators
            }, {
                $0.searchText = "abc"
            }
        )
    }
    
    // MARK: - Helpers
    
    private typealias State = PrePaymentOptionsState<TestLastPayment, TestOperator>
    private typealias Event = PrePaymentOptionsEvent<TestLastPayment, TestOperator>
    private typealias Effect = PrePaymentOptionsEffect<TestOperator>
    
    private typealias SUT = RxViewModel<State, Event, Effect>
    private typealias Reducer = PrePaymentOptionsReducer<TestLastPayment, TestOperator>
    private typealias EffectHandler = PrePaymentOptionsEffectHandler<TestLastPayment, TestOperator>
    
    private typealias StateSpy = ValueSpy<State>
    private typealias LoadLastPaymentsSpy = Spy<Void, Event.LoadLastPaymentsResult>
    private typealias LoadOperatorsSpy = Spy<EffectHandler.LoadOperatorsPayload?, Event.LoadOperatorsResult>
    
    private func makeSUT(
        initialState: State = .init(),
        observeLast: Int = 10,
        pageSize: Int = 100,
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        stateSpy: StateSpy,
        loadLastPaymentsSpy: LoadLastPaymentsSpy,
        loadOperatorsSpy: LoadOperatorsSpy
    ) {
        let reducer = Reducer(
            observeLast: observeLast,
            pageSize: pageSize
        )
        
        let loadLastPaymentsSpy = LoadLastPaymentsSpy()
        let loadOperatorsSpy = LoadOperatorsSpy()
        let effectHandler = EffectHandler(
            loadLastPayments: loadLastPaymentsSpy.process(completion:),
            loadOperators: loadOperatorsSpy.process(_:completion:),
            scheduler: .immediate
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
        
        return (sut, stateSpy, loadLastPaymentsSpy, loadOperatorsSpy)
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
