//
//  CachedModelsTransactionTests.swift
//
//
//  Created by Igor Malyarov on 16.06.2024.
//

import AnywayPaymentDomain
import AnywayPaymentUI
import XCTest

final class CachedModelsTransactionTests: XCTestCase {
    
    // MARK: - init
    
    func test_init_shouldSetEmptyTransactionOnEmptyTransaction() {
        
        let emptyTransaction = makeTransaction()
        XCTAssertTrue(isEmpty(emptyTransaction))
        
        let sut = makeSUT(with: emptyTransaction)
        
        XCTAssertNoDiff(sut.transaction, emptyTransaction)
    }
    
    func test_init_shouldCreateEmptyModelsOnEmptyTransaction() {
        
        let emptyTransaction = makeTransaction()
        XCTAssertTrue(isEmpty(emptyTransaction))
        
        let sut = makeSUT(with: emptyTransaction)
        
        XCTAssertTrue(sut.models.isEmpty)
    }
    
    func test_init_shouldSetTransaction() {
        
        let field = makeFieldAnywayElement()
        let parameter = makeParameterAnywayElement()
        let transaction = makeTransaction(
            elements: [field, parameter]
        )
        XCTAssertFalse(isEmpty(transaction))
        
        let sut = makeSUT(with: transaction)
        
        XCTAssertNoDiff(sut.transaction, transaction)
    }
    
    func test_init_shouldMapElementsToModels() {
        
        let field = makeFieldAnywayElement()
        let parameter = makeParameterAnywayElement()
        let transaction = makeTransaction(
            elements: [field, parameter]
        )
        
        let sut = makeSUT(with: transaction)
        
        XCTAssertEqual(sut.models.count, 2)
        XCTAssertEqual(sut.models[field.id]?.value, field)
        XCTAssertEqual(sut.models[parameter.id]?.value, parameter)
        XCTAssertEqual(sut.transaction.context.payment.elements.count, 2)
    }
    
    // MARK: - updating
    
    func test_updating_shouldSetTransaction() {
        
        let field = makeFieldAnywayElement()
        let initial = makeTransaction(
            elements: [field]
        )
        
        let sut = makeSUT(with: initial)
        
        let parameter = makeParameterAnywayElement()
        let updated = makeTransaction(
            elements: [field, parameter]
        )
        
        let updatedSUT = updating(sut, with: updated)
        
        XCTAssertNoDiff(updatedSUT.transaction, updated)
    }
    
    func test_updating_shouldUpdateModels() {
        
        let field = makeFieldAnywayElement()
        let initial = makeTransaction(
            elements: [field]
        )
        
        let sut = makeSUT(with: initial)
        
        let parameter = makeParameterAnywayElement()
        let updated = makeTransaction(
            elements: [field, parameter]
        )
        
        let updatedSUT = updating(sut, with: updated)
        
        XCTAssertEqual(updatedSUT.models.count, 2)
        XCTAssertEqual(updatedSUT.models[field.id]?.value, field)
        XCTAssertEqual(updatedSUT.models[parameter.id]?.value, parameter)
    }
    
    func test_update_shouldPreserveExistingModels() throws {
        
        let id = anyMessage()
        let field = makeFieldAnywayElement(id: id)
        let initial = makeTransaction(
            elements: [field]
        )
        
        let sut = makeSUT(with: initial)
        let initialFieldModel = try XCTUnwrap(sut.models[.fieldID(id)])
        
        let updatedField = makeFieldAnywayElement(id: id)
        XCTAssertNotEqual(updatedField, field)
        
        let parameter = makeParameterAnywayElement()
        let updated = makeTransaction(
            elements: [updatedField, parameter]
        )
        
        let updatedSUT = updating(sut, with: updated)
        let fieldModel = try XCTUnwrap(updatedSUT.models[.fieldID(id)])
        
        XCTAssertTrue(initialFieldModel === fieldModel)
    }
    
    // TODO: add tests for makeAmountViewModel
    
    // MARK: - Helpers
    
    private typealias SUT = CachedModelsTransaction<AmountViewModel, Model, DocumentStatus, Response>
    private typealias AmountViewModel = String

    private func makeSUT(
        with transaction: SUT.Transaction = makeTransaction(),
        using map: @escaping SUT.Map = { .init(value: $0) }
    ) -> SUT {
        
        return SUT(with: transaction, using: map, makeAmount: { _ in "Amount" })
    }
    
    private func updating(
        _ sut: SUT,
        with transaction: SUT.Transaction,
        using map: @escaping SUT.Map = { .init(value: $0) }
    ) -> SUT {
        
        sut.updating(with: transaction, using: map, makeAmount: { _ in "Amount" })
    }
    
    private final class Model {
        
        var value: AnywayElement
        
        init(value: AnywayElement) {
            
            self.value = value
        }
    }
}
