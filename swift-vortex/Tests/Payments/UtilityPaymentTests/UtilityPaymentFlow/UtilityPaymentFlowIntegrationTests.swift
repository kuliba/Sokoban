//
//  UtilityPaymentFlowIntegrationTests.swift
//
//
//  Created by Igor Malyarov on 12.03.2024.
//

import PrePaymentPicker
import RxViewModel
import UtilityPayment
import XCTest

final class UtilityPaymentFlowIntegrationTests: XCTestCase {
    
    func test_init_shouldNotCallCollaborators() {
        
        let (_,_, loadLastPayments, loadOperators, loadServices, startPayment) = makeSUT()
        
        XCTAssertEqual(loadLastPayments.callCount, 0)
        XCTAssertEqual(loadOperators.callCount, 0)
        XCTAssertEqual(loadServices.callCount, 0)
        XCTAssertEqual(startPayment.callCount, 0)
    }
    
    func test_loadFailureFlow() {
        
        let initialState = State([])
        let (sut, spy, loadLastPayments, loadOperators, _, _) = makeSUT(initialState: initialState)
        
        sut.event(.prePaymentOptions(.initiate))
        loadLastPayments.complete(with: .failure(.connectivityError))
        loadOperators.complete(with: .failure(.connectivityError))
        
        assert(
            spy,
            initialState, {
                $0 = initialState
            }, {
                $0.current = .prePaymentOptions(.init(isInflight: true))
                $0.status = .inflight
            }, {
                $0.current = .prePaymentOptions(.init(isInflight: false))
                $0.status = nil
            }
        )
    }
    
    func test_scrollFlow() {
        
        let (lastPayment, `operator`) = (makeLastPayment(), makeOperator())
        let lastPayments = [lastPayment]
        let operators = [makeOperator(), `operator`, makeOperator()]
        let (sut, spy, loadLastPayments, loadOperators, _,_) = makeSUT()
        
        sut.event(.prePaymentOptions(.initiate))
        loadLastPayments.complete(with: .success(lastPayments))
        loadOperators.complete(with: .success(operators))
        
        sut.event(.prePaymentOptions(.didScrollTo(`operator`.id)))
        let newPage = [makeOperator(), makeOperator()]
        loadOperators.complete(with: .success(newPage), at: 1)
        
        assert(
            spy,
            .init([]), {
                $0 = .init([])
            }, {
                $0.current = .prePaymentOptions(.init(
                    isInflight: true
                ))
                $0.status = .inflight
            }, {
                $0.current = .prePaymentOptions(.init(
                    lastPayments: lastPayments,
                    operators: operators,
                    isInflight: false
                ))
                $0.status = nil
            }, {
                $0.current = .prePaymentOptions(.init(
                    lastPayments: lastPayments,
                    operators: operators + newPage,
                    isInflight: false
                ))
                $0.status = nil
            }
        )
    }
    
    func test_searchFlow() {
        
        let (lastPayment, `operator`) = (makeLastPayment(), makeOperator())
        let lastPayments = [lastPayment]
        let operators = [makeOperator(), `operator`, makeOperator()]
        let (sut, spy, loadLastPayments, loadOperators, _,_) = makeSUT()
        
        sut.event(.prePaymentOptions(.initiate))
        loadLastPayments.complete(with: .success(lastPayments))
        loadOperators.complete(with: .success(operators))
        
        sut.event(.prePaymentOptions(.search(.entered("abc"))))
#warning("FIX SEARCH!")
        // let found = [makeOperator(), makeOperator()]
        // loadOperators.complete(with: .success(found), at: 1)
        
        assert(
            spy,
            .init([]), {
                $0 = .init([])
            }, {
                $0.current = .prePaymentOptions(.init(
                    isInflight: true
                ))
                $0.status = .inflight
            }, {
                $0.current = .prePaymentOptions(.init(
                    lastPayments: lastPayments,
                    operators: operators,
                    isInflight: false
                ))
                $0.status = nil
            }, {
                $0.current = .prePaymentOptions(.init(
                    lastPayments: lastPayments,
                    operators: operators,
                    searchText: "abc",
                    isInflight: false
                ))
                $0.status = nil
            }
        )
    }
    
    func test_backFlow() {
        
        let (lastPayment, `operator`) = (makeLastPayment(), makeOperator())
        let lastPayments = [lastPayment]
        let operators = [makeOperator(), `operator`, makeOperator()]
        let (sut, spy, loadLastPayments, loadOperators, _,_) = makeSUT()
        
        sut.event(.prePaymentOptions(.initiate))
        loadLastPayments.complete(with: .success(lastPayments))
        loadOperators.complete(with: .success(operators))
        
        sut.event(.prePayment(.payByInstruction))
        sut.event(.back)
        
        sut.event(.prePayment(.scan))
        sut.event(.back)
        
        let ppo = State.Destination.prePaymentOptions(.init(
            lastPayments: lastPayments,
            operators: operators
        ))
        
        assert(
            spy,
            .init([]), {
                $0 = .init([])
            }, {
                $0.current = .prePaymentOptions(.init(isInflight: true))
                $0.status = .inflight
            }, {
                $0.current = ppo
                $0.status = nil
            }, {
                $0.push(.prePaymentState(.payingByInstruction))
            }, {
                $0 = .init([ppo])
            }, {
                $0.push(.prePaymentState(.scanning))
            }, {
                $0 = .init([ppo])
            }
        )
    }
    
    func test_startPaymentFailureFlow() {
        
        let (lastPayment, `operator`) = (makeLastPayment(), makeOperator())
        let lastPayments = [lastPayment]
        let operators = [makeOperator(), `operator`, makeOperator()]
        let serverErrorMessage = anyMessage()
        let (sut, spy, loadLastPayments, loadOperators, _, startPayment) = makeSUT()
        
        sut.event(.prePaymentOptions(.initiate))
        loadLastPayments.complete(with: .success(lastPayments))
        loadOperators.complete(with: .success(operators))
        
        sut.event(.prePayment(.select(.last(lastPayment))))
        startPayment.complete(with: .failure(.serverError(serverErrorMessage)))
        sut.event(.back)
        
        let ppo = State.Destination.prePaymentOptions(.init(
            lastPayments: lastPayments,
            operators: operators
        ))
        
        assert(
            spy,
            .init([]), {
                $0 = .init([])
            }, {
                $0.current = .prePaymentOptions(.init(isInflight: true))
                $0.status = .inflight
            }, {
                $0.current = ppo
                $0.status = nil
            }, {
                $0.status = .inflight
            }, {
                $0.status = .failure(.serverError(serverErrorMessage))
            }
        )
    }
    
    func test_startPayment_back_flow() {
        
        let (lastPayment, `operator`) = (makeLastPayment(), makeOperator())
        let lastPayments = [lastPayment]
        let operators = [makeOperator(), `operator`, makeOperator()]
        let (sut, spy, loadLastPayments, loadOperators, loadServices, startPayment) = makeSUT()
        
        sut.event(.prePaymentOptions(.initiate))
        loadLastPayments.complete(with: .success(lastPayments))
        loadOperators.complete(with: .success(operators))
        
        sut.event(.prePayment(.select(.last(lastPayment))))
        startPayment.complete(with: .success(makeResponse()))
        sut.event(.back)
        
        sut.event(.prePayment(.select(.operator(`operator`))))
        loadServices.complete(with: .success([makeService()]))
        startPayment.complete(with: .success(makeResponse()), at: 1)
        sut.event(.back)
        
        let ppo = State.Destination.prePaymentOptions(.init(
            lastPayments: lastPayments,
            operators: operators
        ))
        
        assert(
            spy,
            .init([]), {
                $0 = .init([])
            }, {
                $0.current = .prePaymentOptions(.init(isInflight: true))
                $0.status = .inflight
            }, {
                $0.current = ppo
                $0.status = nil
            }, {
                $0.status = .inflight
            }, {
                $0.push(.payment)
                $0.status = nil
            }, {
                $0 = .init([ppo])
            }, {
                $0.status = .inflight
            }, {
                $0.push(.payment)
                $0.status = nil
            }, {
                $0 = .init([ppo])
            }
        )
    }
    
    func test_startPaymentFromServicesFlow() {
        
        let (lastPayment, `operator`, service) = (makeLastPayment(), makeOperator(), makeService())
        let lastPayments = [lastPayment]
        let operators = [makeOperator(), `operator`, makeOperator()]
        let services = [service, makeService(), makeService()]
        let (sut, spy, loadLastPayments, loadOperators, loadServices, startPayment) = makeSUT()
        
        sut.event(.prePaymentOptions(.initiate))
        loadLastPayments.complete(with: .success(lastPayments))
        loadOperators.complete(with: .success(operators))
        
        sut.event(.prePayment(.select(.operator(`operator`))))
        loadServices.complete(with: .success(services))
        
        sut.event(.prePayment(.select(.service(service))))
        startPayment.complete(with: .success(makeResponse()))
        
        let ppo = State.Destination.prePaymentOptions(.init(
            lastPayments: lastPayments,
            operators: operators
        ))
        
        assert(
            spy,
            .init([]), {
                $0 = .init([])
            }, {
                $0.current = .prePaymentOptions(.init(isInflight: true))
                $0.status = .inflight
            }, {
                $0.current = ppo
                $0.status = nil
            }, {
                $0.status = .inflight
            }, {
                $0.push(.prePaymentState(.services(`operator`, services)))
                $0.status = nil
            }, {
                $0.status = .inflight
            }, {
                $0.push(.payment)
                $0.status = nil
            }
        )
    }
    
#warning("add payment flow test")
    
    // MARK: - Helpers
    
    private typealias Response = StartPaymentResponse
    
    private typealias State = UtilityPaymentFlowState<LastPayment, Operator, Service>
    private typealias Event = UtilityPaymentFlowEvent<LastPayment, Operator, Response, Service>
    private typealias Effect = UtilityPaymentFlowEffect<LastPayment, Operator, Service>
    
    private typealias SUT = RxViewModel<State, Event, Effect>
    private typealias StateSpy = ValueSpy<State>
    
    private typealias PPOReducer = PrePaymentOptionsReducer<LastPayment, Operator>
    
    private typealias PPOEffectHandler = PrePaymentOptionsEffectHandler<LastPayment, Operator>
    private typealias LoadLastPaymentsSpy = Spy<Void, PPOEffectHandler.LoadLastPaymentsResult>
    private typealias LoadOperatorsSpy = Spy<PPOEffectHandler.LoadOperatorsPayload?, PPOEffectHandler.LoadOperatorsResult>
    
    private typealias PPEffectHandler = PrePaymentEffectHandler<LastPayment, Operator, Response, Service>
    private typealias StartPaymentSpy = Spy<PPEffectHandler.StartPaymentPayload, PPEffectHandler.StartPaymentResult>
    private typealias LoadServicesSpy = Spy<PPEffectHandler.LoadServicesPayload, PPEffectHandler.LoadServicesResult>
    
    private typealias FlowEffectHandler = UtilityPaymentFlowEffectHandler<LastPayment, Operator, Response, Service>
    
    private func makeSUT(
        initialState: State = .init([]),
        observeLast: Int = 3,
        pageSize: Int = 10,
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        spy: StateSpy,
        loadLastPayments: LoadLastPaymentsSpy,
        loadOperators: LoadOperatorsSpy,
        loadServices: LoadServicesSpy,
        startPayment: StartPaymentSpy
    ) {
        let ppoReducer = PPOReducer(
            observeLast: observeLast,
            pageSize: pageSize
        )
        let reducer = UtilityPaymentFlowReducer<LastPayment, Operator, Response, Service>(
            prePaymentOptionsReduce: ppoReducer.reduce(_:_:)
        )
        
        let loadLastPayments = LoadLastPaymentsSpy()
        let loadOperators = LoadOperatorsSpy()
        let ppoEffectHandler = PPOEffectHandler(
            loadLastPayments: loadLastPayments.process,
            loadOperators: loadOperators.process,
            scheduler: .immediate
        )
        
        let loadServices = LoadServicesSpy()
        let startPayment = StartPaymentSpy()
        let ppEffectHandler = PPEffectHandler(
            loadServices: loadServices.process,
            startPayment: startPayment.process
        )
        
        let effectHandler = FlowEffectHandler(
            ppoHandleEffect: ppoEffectHandler.handleEffect(_:_:),
            ppHandleEffect: ppEffectHandler.handleEffect(_:_:)
        )
        
        let sut = SUT(
            initialState: initialState,
            reduce: reducer.reduce(_:_:),
            handleEffect: effectHandler.handleEffect(_:_:),
            scheduler: .immediate
        )
        
        let spy = StateSpy(sut.$state)
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(spy, file: file, line: line)
        trackForMemoryLeaks(loadLastPayments, file: file, line: line)
        trackForMemoryLeaks(loadOperators, file: file, line: line)
        trackForMemoryLeaks(loadServices, file: file, line: line)
        trackForMemoryLeaks(startPayment, file: file, line: line)
        
        return (sut, spy, loadLastPayments, loadOperators, loadServices, startPayment)
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
