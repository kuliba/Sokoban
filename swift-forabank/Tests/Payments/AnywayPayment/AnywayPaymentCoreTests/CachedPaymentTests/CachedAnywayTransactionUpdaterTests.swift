//
//  CachedAnywayTransactionUpdaterTests.swift
//  
//
//  Created by Igor Malyarov on 07.06.2024.
//

import AnywayPaymentCore
import AnywayPaymentDomain
import XCTest

final class CachedAnywayTransactionUpdaterTests: XCTestCase {
    
    func test_update_shouldUpdatePaymentPreservingExistingModels() throws {
        
        let sut = makeSUT()
        let parameter = makeAnywayPaymentParameter(id: "abc123", value: "ABC")
        let payment = makeAnywayPayment(parameters: [parameter])
        let cachedTransaction = makeCachedTransaction(
            payment: makeCachedPaymentContext(
                payment: makeCachedPayment(
                    with: payment,
                    using: mapToModel(_:)
                )
            )
        )
        XCTAssertNoDiff(cachedTransaction.payment.payment.models.map(\.id), [
            .parameterID(.init("abc123"))
        ])

        let newParameter = makeAnywayPaymentParameter(id: "a1", value: "edf")
        let transaction = makeTransaction(
            payment: makeAnywayPaymentContext(
                payment: makeAnywayPayment(
                    parameters: [parameter, newParameter]
                )
            )
        )
        let updated = sut.update(cachedTransaction, with: transaction)
        
        XCTAssertNoDiff(updated.payment.payment.models.map(\.id), [
            .parameterID(.init("abc123")),
            .parameterID(.init("a1")),
        ])

        let firstModel = try XCTUnwrap(cachedTransaction.payment.payment.models.first?.model)
        XCTAssertTrue(updated.payment.payment.models.first?.model === firstModel)
    }
    
    func test_update_shouldUpdateStaged() {
        
        let sut = makeSUT()
        let cachedTransaction = makeCachedTransaction(
            payment: makeCachedPaymentContext(staged: ["a"])
        )
        XCTAssertNoDiff(cachedTransaction.payment.staged, ["a"])

        let transaction = makeTransaction(
            payment: makeAnywayPaymentContext(staged: ["c", "d"])
        )
        let updated = sut.update(cachedTransaction, with: transaction)
        
        XCTAssertNoDiff(updated.payment.staged, ["c", "d"])
    }
    
    func test_update_shouldUpdateOutline() {
        
        let sut = makeSUT()
        let cachedOutline = makeAnywayPaymentOutline(["a": "A"])
        let cachedTransaction = makeCachedTransaction(
            payment: makeCachedPaymentContext(outline: cachedOutline)
        )
        XCTAssertNoDiff(cachedTransaction.payment.outline, cachedOutline)

        let outline = makeAnywayPaymentOutline(["b": "B"])
        let transaction = makeTransaction(
            payment: makeAnywayPaymentContext(outline: outline)
        )
        
        let updated = sut.update(cachedTransaction, with: transaction)
        
        XCTAssertNoDiff(updated.payment.outline, outline)
    }
    
    func test_update_shouldSetShouldRestartToFalseOnFalse() {
        
        let sut = makeSUT()
        let cachedTransaction = makeCachedTransaction(
            payment: makeCachedPaymentContext(shouldRestart: true)
        )
        XCTAssertTrue(cachedTransaction.payment.shouldRestart)

        let transaction = makeTransaction(
            payment: makeAnywayPaymentContext(shouldRestart: false)
        )
        let updated = sut.update(cachedTransaction, with: transaction)
        
        XCTAssertFalse(updated.payment.shouldRestart)
    }
    
    func test_update_shouldSetShouldRestartToTrueOnTrue() {
        
        let sut = makeSUT()
        let cachedTransaction = makeCachedTransaction(
            payment: makeCachedPaymentContext(shouldRestart: false)
        )
        XCTAssertFalse(cachedTransaction.payment.shouldRestart)

        let transaction = makeTransaction(
            payment: makeAnywayPaymentContext(shouldRestart: true)
        )
        let updated = sut.update(cachedTransaction, with: transaction)
        
        XCTAssertTrue(updated.payment.shouldRestart)
    }
    
    func test_update_shouldSetIsValidToFalseOnFalse() {
        
        let sut = makeSUT()
        let cachedTransaction = makeCachedTransaction(isValid: true)
        XCTAssertTrue(cachedTransaction.isValid)
        
        let transaction = makeTransaction(isValid: false)
        let updated = sut.update(cachedTransaction, with: transaction)
        
        XCTAssertFalse(updated.isValid)
    }
    
    func test_update_shouldSetIsValidToTrueOnTrue() {
        
        let sut = makeSUT()
        let cachedTransaction = makeCachedTransaction(isValid: false)
        XCTAssertFalse(cachedTransaction.isValid)

        let transaction = makeTransaction(isValid: true)
        let updated = sut.update(cachedTransaction, with: transaction)
        
        XCTAssertTrue(updated.isValid)
    }
    
    func test_update_shouldSetStatusToNilOnNil() {
        
        let sut = makeSUT()
        let cachedTransaction = makeCachedTransaction(status: .fraudSuspected)
        XCTAssertNotNil(cachedTransaction.status)
        
        let transaction = makeTransaction(status: nil)
        let updated = sut.update(cachedTransaction, with: transaction)
        
        XCTAssertNil(updated.status)
    }
    
    func test_update_shouldSetNilStatusToNonNilOnNonNil() {
        
        let sut = makeSUT()
        let cachedTransaction = makeCachedTransaction(status: nil)
        XCTAssertNil(cachedTransaction.status)
        
        let transaction = makeTransaction(status: .fraudSuspected)
        let updated = sut.update(cachedTransaction, with: transaction)
        
        XCTAssertNoDiff(updated.status, .fraudSuspected)
    }
    
    func test_update_shouldUpdateNonNilStatusOnNonNil() {
        
        let sut = makeSUT()
        let cachedTransaction = makeCachedTransaction(status: .awaitingPaymentRestartConfirmation)
        XCTAssertNoDiff(cachedTransaction.status, .awaitingPaymentRestartConfirmation)
        
        let transaction = makeTransaction(status: .fraudSuspected)
        let updated = sut.update(cachedTransaction, with: transaction)
        
        XCTAssertNoDiff(updated.status, .fraudSuspected)
    }
    
    // MARK: - Helpers
    
    private typealias SUT = CachedAnywayTransactionUpdater<DocumentStatus, Model, OperationDetailID, OperationDetails>
    private typealias CachedTransaction = SUT.CachedTransaction
    private typealias Transaction = SUT.Transaction
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> SUT {
        
        let sut = SUT(map: mapToModel(_:))
        
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return sut
    }
    
    private func makeCachedTransaction(
        payment: CachedPaymentContext<Model>? = nil,
        isValid: Bool = true,
        status: TransactionStatus<TransactionReport<DocumentStatus, OperationInfo<OperationDetailID, OperationDetails>>>? = nil
    ) -> CachedTransaction {
        
        return .init(
            payment: payment ?? makeCachedPaymentContext(),
            isValid: isValid,
            status: status
        )
    }
    
    private func makeCachedPaymentContext(
        payment: CachedPaymentContext<Model>.CachedPayment? = nil,
        staged: AnywayPaymentStaged = [],
        outline: AnywayPaymentOutline = makeAnywayPaymentOutline(),
        shouldRestart: Bool = false
    ) -> CachedPaymentContext<Model> {
        
        return .init(
            payment: payment ?? makeCachedPayment(),
            staged: staged,
            outline: outline,
            shouldRestart: shouldRestart
        )
    }
    
    private func makeCachedPayment(
        with payment: AnywayPayment = makeAnywayPayment(),
        using map: CachedAnywayPayment<Model>.Map? = nil
    ) -> CachedAnywayPayment<Model> {
        
        return .init(payment, using: map ?? mapToModel)
    }
    
    private func mapToModel(
        _ element: AnywayElement
    ) -> Model {
        
        return .init()
    }
    
    private func makeTransaction(
        payment: AnywayPaymentContext = makeAnywayPaymentContext(),
        isValid: Bool = true,
        status: TransactionStatus<TransactionReport<DocumentStatus, OperationInfo<OperationDetailID, OperationDetails>>>? = nil
    ) -> Transaction {
        
        return .init(payment: payment, isValid: isValid, status: status)
    }
    
    private final class Model {}
}
