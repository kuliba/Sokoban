//
//  PaymentIntegrationTests.swift
//
//
//  Created by Igor Malyarov on 31.03.2024.
//

import AnywayPaymentCore
import RxViewModel
import XCTest

final class PaymentIntegrationTests: XCTestCase {
    
    func test_init_shouldNotCallCollaborators() {
        
        let (_,_, parameterEffectHandler, paymentInitiator, paymentMaker, processing) = makeSUT()
        
        XCTAssertEqual(parameterEffectHandler.callCount, 0)
        XCTAssertEqual(paymentInitiator.callCount, 0)
        XCTAssertEqual(paymentMaker.callCount, 0)
        XCTAssertEqual(processing.callCount, 0)
    }
    
    func test_initiateFailureFlow_shouldIgnoreSuccessiveEvents() {
        
        let initialState = makePaymentState()
        let (sut, stateSpy, parameterEffectHandler, paymentInitiator, paymentMaker, processing) = makeSUT(initialState: initialState)
        
        sut.event(.initiatePayment)
        paymentInitiator.complete(with: .failure(.connectivityError))
        
        assert(stateSpy, initialState, {
            _ in
        }, {
            $0.status = .result(.failure(.updatePaymentFailure))
        })
        
        assertSuccessiveEventsDeliverNoStateChanges(sut, stateSpy)
        
        XCTAssertEqual(parameterEffectHandler.callCount, 0)
        XCTAssertEqual(paymentMaker.callCount, 0)
        XCTAssertEqual(processing.callCount, 0)
    }
    
    func test_fraudCancel_shouldIgnoreSuccessiveEvents() {
        
        let initialState = makePaymentState()
        let updatedPayment = makePayment()
        let (sut, stateSpy, parameterEffectHandler, paymentInitiator, paymentMaker, processing) = makeSUT(
            makeStub(checkFraud: true, updatePayment: updatedPayment),
            initialState: initialState
        )
        
        sut.event(.initiatePayment)
        paymentInitiator.complete(with: .success(makeUpdate()))
        
        sut.event(.fraud(.cancel))
        
        assert(stateSpy, initialState, {
            _ in
        }, {
            $0.payment = updatedPayment
            $0.isValid = true
            $0.status = .fraudSuspected
        }, {
            $0.status = .result(.failure(.fraud(.cancelled)))
        })
        
        assertSuccessiveEventsDeliverNoStateChanges(sut, stateSpy)
        
        XCTAssertEqual(parameterEffectHandler.callCount, 0)
        XCTAssertEqual(processing.callCount, 0)
        XCTAssertEqual(paymentMaker.callCount, 0)
    }
    
    func test_fraudContinue_shouldAllowContinuation() {
        
        let initialState = makePaymentState()
        let updatedPayment = makePayment()
        let (sut, stateSpy, parameterEffectHandler, paymentInitiator, paymentMaker, processing) = makeSUT(
            makeStub(checkFraud: true, updatePayment: updatedPayment),
            initialState: initialState
        )
        
        sut.event(.initiatePayment)
        paymentInitiator.complete(with: .success(makeUpdate()))
        
        sut.event(.fraud(.continue))
        
        sut.event(.continue)
        processing.complete(with: .success(makeUpdate()))
        
        assert(stateSpy, initialState, {
            _ in
        }, {
            $0.payment = updatedPayment
            $0.isValid = true
            $0.status = .fraudSuspected
        }, {
            $0.status = nil
        }, {
            $0.status = .fraudSuspected
        })
        
        XCTAssertEqual(parameterEffectHandler.callCount, 0)
        XCTAssertEqual(paymentMaker.callCount, 0)
    }
    
    func test_fraudExpired_shouldIgnoreSuccessiveEvents() {
        
        let initialState = makePaymentState()
        let updatedPayment = makePayment()
        let (sut, stateSpy, parameterEffectHandler, paymentInitiator, paymentMaker, processing) = makeSUT(
            makeStub(checkFraud: true, updatePayment: updatedPayment),
            initialState: initialState
        )
        
        sut.event(.initiatePayment)
        paymentInitiator.complete(with: .success(makeUpdate()))
        
        sut.event(.fraud(.expired))
        
        assert(stateSpy, initialState, {
            _ in
        }, {
            $0.payment = updatedPayment
            $0.isValid = true
            $0.status = .fraudSuspected
        }, {
            $0.status = .result(.failure(.fraud(.expired)))
        })
        
        assertSuccessiveEventsDeliverNoStateChanges(sut, stateSpy)
        
        XCTAssertEqual(parameterEffectHandler.callCount, 0)
        XCTAssertEqual(processing.callCount, 0)
        XCTAssertEqual(paymentMaker.callCount, 0)
    }
    
    func test_processingServerError_shouldAllowContinuation() {
        
        let initialState = makePaymentState()
        let updatedPayment = makePayment()
        let message = anyMessage()
        let (sut, stateSpy, parameterEffectHandler, paymentInitiator, paymentMaker, processing) = makeSUT(
            makeStub(updatePayment: updatedPayment),
            initialState: initialState
        )
        
        sut.event(.initiatePayment)
        paymentInitiator.complete(with: .success(makeUpdate()))
        
        sut.event(.continue)
        processing.complete(with: .failure(.serverError(message)))
        
        sut.event(.dismissRecoverableError)
        
        sut.event(.continue)
        processing.complete(with: .success(makeUpdate()), at: 1)
        
        XCTAssertEqual(parameterEffectHandler.callCount, 0)
        XCTAssertEqual(paymentMaker.callCount, 0)
        
        assert(stateSpy, initialState, {
            _ in
        }, {
            $0.payment = updatedPayment
            $0.isValid = true
        }, {
            $0.status = .serverError(message)
        }, {
            $0.status = nil
        })
    }
    
    func test_processingConnectivityError_shouldIgnoreSuccessiveEvents() {
        
        let initialState = makePaymentState()
        let updatedPayment = makePayment()
        let (sut, stateSpy, parameterEffectHandler, paymentInitiator, paymentMaker, processing) = makeSUT(
            makeStub(updatePayment: updatedPayment),
            initialState: initialState
        )
        
        sut.event(.initiatePayment)
        paymentInitiator.complete(with: .success(makeUpdate()))
        
        sut.event(.continue)
        processing.complete(with: .failure(.connectivityError))
        
        assert(stateSpy, initialState, {
            _ in
        }, {
            $0.payment = updatedPayment
            $0.isValid = true
        }, {
            $0.status = .result(.failure(.updatePaymentFailure))
        })
        
        assertSuccessiveEventsDeliverNoStateChanges(sut, stateSpy)
        
        XCTAssertEqual(parameterEffectHandler.callCount, 0)
        XCTAssertEqual(paymentMaker.callCount, 0)
    }
    
    func test_flow() {
        
        let initialState = makePaymentState()
        let parameterReduced = makePayment()
        let updatePayment = makePayment()
        let (sut, stateSpy, _, paymentInitiator, paymentMaker, processing) = makeSUT(
            makeStub(
                parameterReduce: (parameterReduced, nil),
                updatePayment: updatePayment,
                validatePayment: true
            ),
            initialState: initialState
        )
        
        sut.event(.parameter(.select))
        sut.event(.continue)
        processing.complete(with: .success(makeUpdate()))
        
        assert(stateSpy, initialState, {
            $0 = initialState
        }, {
            $0.payment = parameterReduced
            $0.isValid = true
        }, {
            $0.payment = updatePayment
        })
    }
    
    // MARK: - Helpers
    
    private typealias State = PaymentState<Payment, DocumentStatus, OperationDetails>
    private typealias Event = PaymentEvent<DocumentStatus, OperationDetails, ParameterEvent, Update>
    private typealias Effect = PaymentEffect<Digest, ParameterEffect>
    
    private typealias SUT = RxViewModel<State, Event, Effect>
    private typealias StateSpy = ValueSpy<State>
    private typealias Reducer = PaymentReducer<Digest, DocumentStatus, OperationDetails, ParameterEffect, ParameterEvent, Payment, Update>
    private typealias EffectHandler = PaymentEffectHandler<Digest, DocumentStatus, OperationDetails, ParameterEffect, ParameterEvent, Update>
    
    private typealias Stub = (checkFraud: Bool, getVerificationCode: VerificationCode?, makeDigest: Digest, parameterReduce: (Payment, Effect?), updatePayment: Payment, validatePayment: Bool)
    
    private typealias PaymentInitiator = Processing
    private typealias PaymentMaker = Spy<VerificationCode, EffectHandler.MakePaymentResult>
    private typealias ParameterEffectHandleSpy = EffectHandlerSpy<ParameterEvent, ParameterEffect>
    private typealias Processing = Spy<Digest, EffectHandler.ProcessResult>
    
    private func makeSUT(
        _ stub: Stub? = nil,
        initialState: State = makePaymentState(),
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        stateSpy: StateSpy,
        parameterEffectHandler: ParameterEffectHandleSpy,
        paymentInitiator: PaymentInitiator,
        paymentMaker: PaymentMaker,
        processing: Processing
    ) {
        let stub = stub ?? makeStub()
        let reducer = Reducer(
            checkFraud: { _ in stub.checkFraud },
            getVerificationCode: { _ in stub.getVerificationCode },
            makeDigest: { _ in stub.makeDigest },
            parameterReduce: { _,_ in stub.parameterReduce },
            updatePayment: { _,_ in stub.updatePayment },
            validatePayment: { _ in stub.validatePayment }
        )
        
        let paymentInitiator = PaymentInitiator()
        let parameterEffectHandler = ParameterEffectHandleSpy()
        let paymentMaker = PaymentMaker()
        let processing = Processing()
        let effectHandler = EffectHandler(
            initiate: paymentInitiator.process,
            makePayment: paymentMaker.process,
            parameterEffectHandle: parameterEffectHandler.handleEffect,
            process: processing.process
        )
        
        let sut = SUT(
            initialState: initialState,
            reduce: reducer.reduce,
            handleEffect: effectHandler.handleEffect,
            scheduler: .immediate
        )
        let stateSpy = StateSpy(sut.$state.removeDuplicates())
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(stateSpy, file: file, line: line)
        trackForMemoryLeaks(reducer, file: file, line: line)
        trackForMemoryLeaks(effectHandler, file: file, line: line)
        trackForMemoryLeaks(parameterEffectHandler, file: file, line: line)
        trackForMemoryLeaks(paymentInitiator, file: file, line: line)
        trackForMemoryLeaks(paymentMaker, file: file, line: line)
        trackForMemoryLeaks(processing, file: file, line: line)
        
        return (sut, stateSpy, parameterEffectHandler, paymentInitiator, paymentMaker, processing)
    }
    
    private func makeStub(
        checkFraud: Bool = false,
        getVerificationCode: VerificationCode? = nil,
        makeDigest: Digest = makeDigest(),
        parameterReduce: (Payment, Effect?) = (makePayment(), nil),
        updatePayment: Payment = makePayment(),
        validatePayment: Bool = true
    ) -> Stub {
        (
            checkFraud: checkFraud,
            getVerificationCode: getVerificationCode,
            makeDigest: makeDigest,
            parameterReduce: parameterReduce,
            updatePayment: updatePayment,
            validatePayment: validatePayment
        )
    }
    
    private func assertSuccessiveEventsDeliverNoStateChanges(
        _ sut: SUT,
        _ stateSpy: StateSpy,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let accStates = stateSpy.values
        
        sut.event(.completePayment(.none))
        sut.event(.continue)
        sut.event(.continue)
        sut.event(.fraud(.cancel))
        sut.event(.fraud(.continue))
        sut.event(.fraud(.expired))
        sut.event(.initiatePayment)
        sut.event(.parameter(.select))
        sut.event(.updatePayment(.failure(.connectivityError)))
        
        XCTAssertNoDiff(stateSpy.values, accStates)
    }
    
    @discardableResult
    private func assert(
        _ stateSpy: StateSpy,
        _ initialState: State,
        _ updates: ((inout State) -> Void)...,
        file: StaticString = #file,
        line: UInt = #line
    ) -> [State] {
        
        var state = initialState
        var values = [State]()
        
        for update in updates {
            
            update(&state)
            values.append(state)
        }
        
        XCTAssertNoDiff(stateSpy.values, values, file: file, line: line)
        
        return values
    }
}
