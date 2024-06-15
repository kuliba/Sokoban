//
//  CachedAnywayTransactionViewModelComposerTests.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 10.06.2024.
//

import AnywayPaymentCore
import AnywayPaymentDomain
@testable import ForaBank
import XCTest

final class CachedAnywayTransactionViewModelComposerTests: XCTestCase {
    
    func test_dismissRecoverableError_shouldNotResetTerminatedStatus() {
        
        let (sut, statusSpy) = makeSUT(
            transactionState: makeTransactionState(
                status: .result(.failure(.updatePaymentFailure))
            )
        )
        
        sut.event(.transaction(.dismissRecoverableError))
        
        // TODO: add scheduler to Composer
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.5)
        
        XCTAssertNoDiff(statusSpy.values, [
            .result(.failure(.updatePaymentFailure)),
            .result(.failure(.updatePaymentFailure)),
        ])
    }
    
    func test_dismissRecoverableError_shouldResetServerErrorStatus() {
        
        let message = anyMessage()
        let (sut, statusSpy) = makeSUT(
            transactionState: makeTransactionState(
                status: .serverError(message)
            )
        )
        
        sut.event(.transaction(.dismissRecoverableError))
        
        // TODO: add scheduler to Composer
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.5)
        
        XCTAssertNoDiff(statusSpy.values, [
            .serverError(message),
            .serverError(message),
            nil,
        ])
    }
    
    // MARK: - Helpers
    
    private typealias Composer = CachedAnywayTransactionViewModelComposer
    private typealias SUT = CachedAnywayTransactionViewModel
    private typealias StatusSpy = ValueSpy<AnywayTransactionStatus?>
    
    private func makeComposer(
        file: StaticString = #file,
        line: UInt = #line
    ) -> Composer {
        
        let sut = Composer(
            currencyOfProduct: { _ in "₽" },
            getProducts: { [] },
            initiateOTP: { _ in },
            makeTransactionViewModel: makeAnywayTransactionViewModel,
            spinnerActions: nil
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return sut
    }
    
    private func makeSUT(
        transactionState: AnywayTransactionState,
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        statusSpy: StatusSpy
    ) {
        let composer = makeComposer(file: file, line: line)
        let sut = composer.makeCachedAnywayTransactionViewModel(
            transactionState: transactionState,
            notify: { _ in }
        )
        let statusSpy = ValueSpy(sut.$state.map(\.status).dropFirst())
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(statusSpy, file: file, line: line)
        
        return (sut, statusSpy)
    }
    
    private func makeAnywayTransactionViewModel(
        _ initialState: AnywayTransactionState,
        _ observe: @escaping Observe
    ) -> AnywayTransactionViewModel {
        
        let composer = ReducerComposer()
        let reducer = composer.compose()
        
        return .init(
            initialState: initialState,
            reduce: reducer.reduce(_:_:),
            handleEffect: { _,_ in },
            observe: observe
        )
    }
    
    typealias ReducerComposer = AnywayPaymentTransactionReducerComposer<AnywayTransactionReport>
    typealias Observe = (AnywayTransactionState, AnywayTransactionState) -> Void
    
    private func makeTransactionState(
        context: AnywayPaymentContext? = nil,
        isValid: Bool = true,
        status: AnywayTransactionStatus? = nil
    ) -> AnywayTransactionState {
        
        return .init(
            context: context ?? makeAnywayPaymentContext(), 
            isValid: isValid,
            status: status
        )
    }
    
    private typealias AnywayPayment = AnywayPaymentDomain.AnywayPayment
    
    private func makeAnywayPaymentContext(
        payment: AnywayPayment? = nil,
        staged: AnywayPaymentStaged = [],
        outline: AnywayPaymentOutline? = nil,
        shouldRestart: Bool = false
    ) -> AnywayPaymentContext {
        
        return .init(
            payment: payment ?? makeAnywayPayment(),
            staged: staged,
            outline: outline ?? makeAnywayPaymentOutline(),
            shouldRestart: shouldRestart
        )
    }
    
    private func makeAnywayPayment(
        elements: [AnywayElement] = [],
        footer: Payment<AnywayElement>.Footer = .continue,
        infoMessage: String? = nil,
        isFinalStep: Bool = false,
        isFraudSuspected: Bool = false,
        puref: String = UUID().uuidString
    ) -> AnywayPayment {
        
        return .init(
            elements: elements,
            footer: footer,
            infoMessage: infoMessage,
            isFinalStep: isFinalStep,
            isFraudSuspected: isFraudSuspected
        )
    }
    
    private func makeAnywayPaymentOutline(
        core: AnywayPaymentOutline.PaymentCore? = nil,
        fields: AnywayPaymentOutline.Fields = [:],
        payload: AnywayPaymentOutline.Payload? = nil
    ) -> AnywayPaymentOutline {
        
        return .init(
            core: core ?? makePaymentCore(), 
            fields: fields,
            payload: payload ?? makeAnywayPaymentPayload()
        )
    }
    
    private func makePaymentCore(
        amount: Decimal = .init(Double.random(in: 1...1_000)),
        currency: String = "₽",
        productID: Int = generateRandom11DigitNumber(),
        productType: AnywayPaymentOutline.PaymentCore.ProductType = .account
    ) -> AnywayPaymentOutline.PaymentCore {
        
        return .init(
            amount: amount, 
            currency: currency,
            productID: productID,
            productType: productType
        )
    }
    
    func makeAnywayPaymentPayload(
        puref: AnywayPaymentOutline.Payload.Puref = anyMessage(),
        title: String = anyMessage(),
        subtitle: String = anyMessage(),
        icon: String = anyMessage()
    ) -> AnywayPaymentOutline.Payload {
        
        return .init(puref: puref, title: title, subtitle: subtitle, icon: icon)
    }
}
