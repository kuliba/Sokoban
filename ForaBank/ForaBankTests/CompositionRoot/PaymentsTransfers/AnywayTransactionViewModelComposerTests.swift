//
//  AnywayTransactionViewModelComposerTests.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 10.06.2024.
//

import AnywayPaymentCore
import AnywayPaymentDomain
@testable import ForaBank
import XCTest

final class AnywayTransactionViewModelComposerTests: XCTestCase {
    
    func test_dismissRecoverableError_shouldNotResetTerminatedStatus() {
        
        let (sut, statusSpy) = makeSUT(
            transaction: makeTransaction(
                status: .result(.failure(.updatePaymentFailure))
            )
        )
        
        sut.event(.dismissRecoverableError)
        sut.event(.dismissRecoverableError)
        sut.event(.dismissRecoverableError)
        
        XCTAssertNoDiff(statusSpy.values, [
            .result(.failure(.updatePaymentFailure)),
        ])
    }
    
    func test_dismissRecoverableError_shouldResetServerErrorStatus() {
        
        let message = anyMessage()
        let (sut, statusSpy) = makeSUT(
            transaction: makeTransaction(
                status: .serverError(message)
            )
        )
        XCTAssertNoDiff(sut.state.transaction.status, .serverError(message))
        
        sut.event(.dismissRecoverableError)
        
        XCTAssertNoDiff(statusSpy.values, [
            .serverError(message),
            nil,
        ])
    }
    
    // MARK: - Helpers
    
    // TODO: replace with `AnywayTransactionViewModelComposer`
    private typealias Composer = __AnywayTransactionViewModelComposer
    private typealias SUT = AnywayTransactionViewModel
    private typealias StatusSpy = ValueSpy<AnywayTransactionStatus?>
    
    private func makeComposer(
        file: StaticString = #file,
        line: UInt = #line
    ) -> Composer {
        
        let sut = Composer(
            getCurrencySymbol: { _ in "₽" },
            elementMapper: .init(
                currencyOfProduct: { _ in "₽" }, 
                format: { _,_ in ""},
                getProducts: { [] },
                flag: .stub
            ),
            microServices: .init(
                getVerificationCode: { _ in },
                initiatePayment: { _,_ in },
                makePayment: { _,_ in },
                paymentEffectHandle: { _,_ in },
                processPayment: { _,_ in }
            ),
            spinnerActions: nil
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return sut
    }
    
    private func makeSUT(
        transaction: AnywayTransactionState.Transaction,
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        statusSpy: StatusSpy
    ) {
        let composer = makeComposer(file: file, line: line)
        let sut = composer.makeAnywayTransactionViewModel(
            transaction: transaction,
            scheduler: .immediate
        )
        let statusSpy = ValueSpy(sut.$state.map(\.transaction.status))
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(statusSpy, file: file, line: line)
        
        return (sut, statusSpy)
    }
    
    typealias ReducerComposer = AnywayPaymentTransactionReducerComposer<AnywayTransactionReport>
    typealias Observe = (AnywayTransactionState, AnywayTransactionState) -> Void
    
    private func makeTransaction(
        context: AnywayPaymentContext? = nil,
        isValid: Bool = true,
        status: AnywayTransactionStatus? = nil
    ) -> AnywayTransactionState.Transaction {
        
        return .init(
            context: context ?? makeAnywayPaymentContext(),
            isValid: isValid,
            status: status
        )
    }
    
    private typealias AnywayPayment = AnywayPaymentDomain.AnywayPayment
    
    private func makeAnywayPaymentContext(
        initial: AnywayPayment? = nil,
        payment: AnywayPayment? = nil,
        staged: AnywayPaymentStaged = [],
        outline: AnywayPaymentOutline? = nil,
        shouldRestart: Bool = false
    ) -> AnywayPaymentContext {
        
        return .init(
            initial: initial ?? makeAnywayPayment(),
            payment: payment ?? makeAnywayPayment(),
            staged: staged,
            outline: outline ?? makeAnywayPaymentOutline(),
            shouldRestart: shouldRestart
        )
    }
    
    private func makeAnywayPayment(
        amount: Decimal? = nil,
        elements: [AnywayElement] = [],
        footer: Payment<AnywayElement>.Footer = .continue,
        isFinalStep: Bool = false,
        isFraudSuspected: Bool = false,
        puref: String = UUID().uuidString
    ) -> AnywayPayment {
        
        return .init(
            amount: amount,
            elements: elements,
            footer: footer,
            isFinalStep: isFinalStep
        )
    }
    
    private func makeAnywayPaymentOutline(
        amount: Decimal? = nil,
        product: AnywayPaymentOutline.Product? = nil,
        fields: AnywayPaymentOutline.Fields = [:],
        payload: AnywayPaymentOutline.Payload? = nil
    ) -> AnywayPaymentOutline {
        
        return .init(
            amount: amount,
            product: product ?? makePaymentProduct(),
            fields: fields,
            payload: payload ?? makeAnywayPaymentPayload()
        )
    }
    
    private func makePaymentProduct(
        currency: String = "₽",
        productID: Int = generateRandom11DigitNumber(),
        productType: AnywayPaymentOutline.Product.ProductType = .account
    ) -> AnywayPaymentOutline.Product {
        
        return .init(
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
