//
//  TransactionFlowIntegrationTests.swift
//
//
//  Created by Igor Malyarov on 31.03.2024.
//

import AnywayPaymentDomain
import AnywayPaymentCore
import RxViewModel
import XCTest

final class TransactionFlowIntegrationTests: XCTestCase {
    
    func test_init_shouldNotCallCollaborators() {
        
        let (_,_, paymentEffectHandler, paymentInitiator, paymentMaker, paymentProcessing) = makeSUT()
        
        XCTAssertEqual(paymentEffectHandler.callCount, 0)
        XCTAssertEqual(paymentInitiator.callCount, 0)
        XCTAssertEqual(paymentMaker.callCount, 0)
        XCTAssertEqual(paymentProcessing.callCount, 0)
    }
    
    func test_initiateFailureFlow_shouldIgnoreSuccessiveEvents() {
        
        let initialState = makeTransaction()
        let (sut, stateSpy, paymentEffectHandler, paymentInitiator, paymentMaker, paymentProcessing) = makeSUT(initialState: initialState)
        
        sut.event(.initiatePayment)
        paymentInitiator.complete(with: .failure(.connectivityError))
        
        assert(stateSpy, initialState, {
            _ in
        }, {
            $0.status = .result(.failure(.updatePaymentFailure))
        })
        
        assertSuccessiveEventsDeliverNoStateChanges(sut, stateSpy)
        
        XCTAssertEqual(paymentEffectHandler.callCount, 0)
        XCTAssertEqual(paymentMaker.callCount, 0)
        XCTAssertEqual(paymentProcessing.callCount, 0)
    }
    
    func test_fraudCancel_shouldIgnoreSuccessiveEvents() {
        
        let initialState = makeTransaction()
        let updatedPayment = makePayment()
        let (sut, stateSpy, paymentEffectHandler, paymentInitiator, paymentMaker, paymentProcessing) = makeSUT(
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
        
        XCTAssertEqual(paymentEffectHandler.callCount, 0)
        XCTAssertEqual(paymentProcessing.callCount, 0)
        XCTAssertEqual(paymentMaker.callCount, 0)
    }
    
    func test_fraudContinue_shouldAllowContinuation() {
        
        let initialState = makeTransaction()
        let updatedPayment = makePayment()
        let (sut, stateSpy, paymentEffectHandler, paymentInitiator, paymentMaker, paymentProcessing) = makeSUT(
            makeStub(checkFraud: true, updatePayment: updatedPayment),
            initialState: initialState
        )
        
        sut.event(.initiatePayment)
        paymentInitiator.complete(with: .success(makeUpdate()))
        
        sut.event(.fraud(.continue))
        
        sut.event(.continue)
        paymentProcessing.complete(with: .success(makeUpdate()))
        
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
        
        XCTAssertEqual(paymentEffectHandler.callCount, 0)
        XCTAssertEqual(paymentMaker.callCount, 0)
    }
    
    func test_fraudExpired_shouldIgnoreSuccessiveEvents() {
        
        let initialState = makeTransaction()
        let updatedPayment = makePayment()
        let (sut, stateSpy, paymentEffectHandler, paymentInitiator, paymentMaker, paymentProcessing) = makeSUT(
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
        
        XCTAssertEqual(paymentEffectHandler.callCount, 0)
        XCTAssertEqual(paymentProcessing.callCount, 0)
        XCTAssertEqual(paymentMaker.callCount, 0)
    }
    
    func test_paymentProcessingServerError_shouldAllowContinuation() {
        
        let initialState = makeTransaction()
        let updatedPayment = makePayment()
        let message = anyMessage()
        let (sut, stateSpy, paymentEffectHandler, paymentInitiator, paymentMaker, paymentProcessing) = makeSUT(
            makeStub(updatePayment: updatedPayment),
            initialState: initialState
        )
        
        sut.event(.initiatePayment)
        paymentInitiator.complete(with: .success(makeUpdate()))
        
        sut.event(.continue)
        paymentProcessing.complete(with: .failure(.serverError(message)))
        
        sut.event(.dismissRecoverableError)
        
        sut.event(.continue)
        paymentProcessing.complete(with: .success(makeUpdate()), at: 1)
        
        XCTAssertEqual(paymentEffectHandler.callCount, 0)
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
    
    func test_paymentProcessingConnectivityError_shouldIgnoreSuccessiveEvents() {
        
        let initialState = makeTransaction()
        let updatedPayment = makePayment()
        let (sut, stateSpy, paymentEffectHandler, paymentInitiator, paymentMaker, paymentProcessing) = makeSUT(
            makeStub(updatePayment: updatedPayment),
            initialState: initialState
        )
        
        sut.event(.initiatePayment)
        paymentInitiator.complete(with: .success(makeUpdate()))
        
        sut.event(.continue)
        paymentProcessing.complete(with: .failure(.connectivityError))
        
        assert(stateSpy, initialState, {
            _ in
        }, {
            $0.payment = updatedPayment
            $0.isValid = true
        }, {
            $0.status = .result(.failure(.updatePaymentFailure))
        })
        
        assertSuccessiveEventsDeliverNoStateChanges(sut, stateSpy)
        
        XCTAssertEqual(paymentEffectHandler.callCount, 0)
        XCTAssertEqual(paymentMaker.callCount, 0)
    }
    
    func test_shouldCallPaymentInitiatorTwiceOnRestartPayment() {
        
        let initialState = makeTransaction(makePayment(shouldRestart: true))
        let updatedPayment = makePayment()
        let editedPayment = makePayment()
        let (sut, stateSpy, paymentEffectHandler, paymentInitiator, paymentMaker, paymentProcessing) = makeSUT(
            makeStub(
                paymentReduce: (editedPayment, nil),
                updatePayment: updatedPayment,
                wouldNeedRestart: true
            ),
            initialState: initialState
        )
        
        sut.event(.initiatePayment)
        paymentInitiator.complete(with: .success(makeUpdate()))
        
        sut.event(.payment(.select))
        sut.event(.paymentRestartConfirmation(true))
        
        sut.event(.continue)
        paymentInitiator.complete(with: .success(makeUpdate()), at: 1)
        
        assert(stateSpy, initialState, {
            _ in
        }, {
            $0.payment = updatedPayment
            $0.isValid = true
        }, {
            $0.payment = editedPayment
            $0.payment.shouldRestart = true
        }, {
            $0.payment = updatedPayment
        })
        
        XCTAssertEqual(paymentInitiator.callCount, 2)
        XCTAssertEqual(paymentEffectHandler.callCount, 0)
        XCTAssertEqual(paymentMaker.callCount, 0)
        XCTAssertEqual(paymentProcessing.callCount, 0)
    }
    
    func test_makePaymentFailure_shouldIgnoreSuccessiveEvents() {
        
        let initialState = makeTransaction()
        let verificationCode = makeVerificationCode()
        let updatedPayment = makePayment()
        let (sut, stateSpy, paymentEffectHandler, paymentInitiator, paymentMaker, paymentProcessing) = makeSUT(
            makeStub(getVerificationCode: verificationCode, updatePayment: updatedPayment),
            initialState: initialState
        )
        
        sut.event(.initiatePayment)
        paymentInitiator.complete(with: .success(makeUpdate()))
        
        sut.event(.continue)
        paymentMaker.complete(with: .none)
        
        assert(stateSpy, initialState, {
            _ in
        }, {
            $0.payment = updatedPayment
            $0.isValid = true
        }, {
            $0.status = .result(.failure(.transactionFailure))
        })
        
        assertSuccessiveEventsDeliverNoStateChanges(sut, stateSpy)
        
        XCTAssertEqual(paymentEffectHandler.callCount, 0)
        XCTAssertEqual(paymentProcessing.callCount, 0)
    }
    
    func test_makePaymentSuccessDetailID_shouldIgnoreSuccessiveEvents() {
        
        let initialState = makeTransaction()
        let verificationCode = makeVerificationCode()
        let report = makeDetailIDTransactionReport()
        let updatedPayment = makePayment()
        let (sut, stateSpy, paymentEffectHandler, paymentInitiator, paymentMaker, paymentProcessing) = makeSUT(
            makeStub(getVerificationCode: verificationCode, updatePayment: updatedPayment),
            initialState: initialState
        )
        
        sut.event(.initiatePayment)
        paymentInitiator.complete(with: .success(makeUpdate()))
        
        sut.event(.continue)
        paymentMaker.complete(with: report)
        
        assert(stateSpy, initialState, {
            _ in
        }, {
            $0.payment = updatedPayment
            $0.isValid = true
        }, {
            $0.status = .result(.success(report))
        })
        
        assertSuccessiveEventsDeliverNoStateChanges(sut, stateSpy)
        
        XCTAssertEqual(paymentEffectHandler.callCount, 0)
        XCTAssertEqual(paymentProcessing.callCount, 0)
    }
    
    func test_makePaymentSuccessOperationDetailID_shouldIgnoreSuccessiveEvents() {
        
        let initialState = makeTransaction()
        let verificationCode = makeVerificationCode()
        let report = makeOperationDetailsTransactionReport()
        let updatedPayment = makePayment()
        let (sut, stateSpy, paymentEffectHandler, paymentInitiator, paymentMaker, paymentProcessing) = makeSUT(
            makeStub(getVerificationCode: verificationCode, updatePayment: updatedPayment),
            initialState: initialState
        )
        
        sut.event(.initiatePayment)
        paymentInitiator.complete(with: .success(makeUpdate()))
        
        sut.event(.continue)
        paymentMaker.complete(with: report)
        
        assert(stateSpy, initialState, {
            _ in
        }, {
            $0.payment = updatedPayment
            $0.isValid = true
        }, {
            $0.status = .result(.success(report))
        })
        
        assertSuccessiveEventsDeliverNoStateChanges(sut, stateSpy)
        
        XCTAssertEqual(paymentEffectHandler.callCount, 0)
        XCTAssertEqual(paymentProcessing.callCount, 0)
    }
    
    // MARK: - Helpers
    
    private typealias State = _Transaction
    private typealias Event = _TransactionEvent
    private typealias Effect = _TransactionEffect
    
    private typealias SUT = RxViewModel<State, Event, Effect>
    private typealias StateSpy = ValueSpy<State>
    private typealias Reducer = _TransactionReducer
    private typealias EffectHandler = _TransactionEffectHandler
    
    private typealias Stub = (checkFraud: Bool, getVerificationCode: VerificationCode?, makeDigest: PaymentDigest, paymentReduce: (Payment, Effect?), restorePayment: Payment, stagePayment: Payment?, updatePayment: Payment, validatePayment: Bool, wouldNeedRestart: Bool)
    
    private typealias Inspector = PaymentInspector<Payment, PaymentDigest>

    private func makeSUT(
        _ stub: Stub? = nil,
        initialState: State = makeTransaction(),
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        stateSpy: StateSpy,
        paymentEffectHandler: PaymentEffectHandleSpy,
        paymentInitiator: PaymentInitiator,
        paymentMaker: PaymentMaker,
        paymentProcessing: PaymentProcessing
    ) {
        let stub = stub ?? makeStub()
        let reducer = Reducer(
            paymentReduce: { _,_ in stub.paymentReduce },
            stagePayment: { stub.stagePayment ?? $0 },
            updatePayment: { _,_ in stub.updatePayment },
            paymentInspector: .init(
                checkFraud: { _ in stub.checkFraud },
                getVerificationCode: { _ in stub.getVerificationCode },
                makeDigest: { _ in stub.makeDigest },
                restorePayment: { _ in stub.restorePayment },
                validatePayment: { _ in stub.validatePayment },
                wouldNeedRestart: { _ in stub.wouldNeedRestart }
            )
        )
        let paymentInitiator = PaymentInitiator()
        let paymentEffectHandler = PaymentEffectHandleSpy()
        let paymentMaker = PaymentMaker()
        let paymentProcessing = PaymentProcessing()
        let effectHandler = EffectHandler(
            microServices: .init(
                initiatePayment: paymentInitiator.process,
                makePayment: paymentMaker.process,
                paymentEffectHandle: paymentEffectHandler.handleEffect,
                processPayment: paymentProcessing.process
            )
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
        trackForMemoryLeaks(paymentEffectHandler, file: file, line: line)
        trackForMemoryLeaks(paymentInitiator, file: file, line: line)
        trackForMemoryLeaks(paymentMaker, file: file, line: line)
        trackForMemoryLeaks(paymentProcessing, file: file, line: line)
        
        return (sut, stateSpy, paymentEffectHandler, paymentInitiator, paymentMaker, paymentProcessing)
    }
    
    private func makeStub(
        checkFraud: Bool = false,
        getVerificationCode: VerificationCode? = nil,
        makeDigest: PaymentDigest = makePaymentDigest(),
        paymentReduce: (Payment, Effect?) = (makePayment(), nil),
        restorePayment: Payment = makePayment(),
        stagePayment: Payment? = nil,
        updatePayment: Payment = makePayment(),
        validatePayment: Bool = true,
        wouldNeedRestart: Bool = true
    ) -> Stub {
        (
            checkFraud: checkFraud,
            getVerificationCode: getVerificationCode,
            makeDigest: makeDigest,
            paymentReduce: paymentReduce,
            restorePayment: restorePayment,
            stagePayment: stagePayment,
            updatePayment: updatePayment,
            validatePayment: validatePayment,
            wouldNeedRestart: wouldNeedRestart
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
        sut.event(.payment(.select))
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
