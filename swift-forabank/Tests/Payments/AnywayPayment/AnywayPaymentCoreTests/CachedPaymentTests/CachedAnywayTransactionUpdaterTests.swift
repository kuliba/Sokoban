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
            context: makeCachedPaymentContext(
                payment: makeCachedPayment(
                    with: payment,
                    using: mapToModel(_:)
                )
            )
        )
        XCTAssertNoDiff(cachedTransaction.context.payment.models.map(\.id), [
            .parameterID(.init("abc123"))
        ])

        let newParameter = makeAnywayPaymentParameter(id: "a1", value: "edf")
        let transaction = makeTransaction(
            context: makeAnywayPaymentContext(
                payment: makeAnywayPayment(
                    parameters: [parameter, newParameter]
                )
            )
        )
        let updated = sut.update(cachedTransaction, with: transaction)
        
        XCTAssertNoDiff(updated.context.payment.models.map(\.id), [
            .parameterID(.init("abc123")),
            .parameterID(.init("a1")),
        ])

        let firstModel = try XCTUnwrap(cachedTransaction.context.payment.models.first?.model)
        XCTAssertTrue(updated.context.payment.models.first?.model === firstModel)
    }
    
    func test_update_shouldUpdateStaged() {
        
        let sut = makeSUT()
        let cachedTransaction = makeCachedTransaction(
            context: makeCachedPaymentContext(staged: ["a"])
        )
        XCTAssertNoDiff(cachedTransaction.context.staged, ["a"])

        let transaction = makeTransaction(
            context: makeAnywayPaymentContext(staged: ["c", "d"])
        )
        let updated = sut.update(cachedTransaction, with: transaction)
        
        XCTAssertNoDiff(updated.context.staged, ["c", "d"])
    }
    
    func test_update_shouldUpdateOutline() {
        
        let sut = makeSUT()
        let cachedOutline = makeAnywayPaymentOutline(["a": "A"])
        let cachedTransaction = makeCachedTransaction(
            context: makeCachedPaymentContext(outline: cachedOutline)
        )
        XCTAssertNoDiff(cachedTransaction.context.outline, cachedOutline)

        let outline = makeAnywayPaymentOutline(["b": "B"])
        let transaction = makeTransaction(
            context: makeAnywayPaymentContext(outline: outline)
        )
        
        let updated = sut.update(cachedTransaction, with: transaction)
        
        XCTAssertNoDiff(updated.context.outline, outline)
    }
    
    func test_update_shouldSetShouldRestartToFalseOnFalse() {
        
        let sut = makeSUT()
        let cachedTransaction = makeCachedTransaction(
            context: makeCachedPaymentContext(shouldRestart: true)
        )
        XCTAssertTrue(cachedTransaction.context.shouldRestart)

        let transaction = makeTransaction(
            context: makeAnywayPaymentContext(shouldRestart: false)
        )
        let updated = sut.update(cachedTransaction, with: transaction)
        
        XCTAssertFalse(updated.context.shouldRestart)
    }
    
    func test_update_shouldSetShouldRestartToTrueOnTrue() {
        
        let sut = makeSUT()
        let cachedTransaction = makeCachedTransaction(
            context: makeCachedPaymentContext(shouldRestart: false)
        )
        XCTAssertFalse(cachedTransaction.context.shouldRestart)

        let transaction = makeTransaction(
            context: makeAnywayPaymentContext(shouldRestart: true)
        )
        let updated = sut.update(cachedTransaction, with: transaction)
        
        XCTAssertTrue(updated.context.shouldRestart)
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
        context: CachedPaymentContext<Model>? = nil,
        isValid: Bool = true,
        status: TransactionStatus<TransactionReport<DocumentStatus, OperationInfo<OperationDetailID, OperationDetails>>>? = nil
    ) -> CachedTransaction {
        
        return .init(
            context: context ?? makeCachedPaymentContext(),
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
        context: AnywayPaymentContext = makeAnywayPaymentContext(),
        isValid: Bool = true,
        status: TransactionStatus<TransactionReport<DocumentStatus, OperationInfo<OperationDetailID, OperationDetails>>>? = nil
    ) -> Transaction {
        
        return .init(context: context, isValid: isValid, status: status)
    }
    
    private final class Model {}
}
