//
//  InitialAnywayTransactionComposerTests.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 11.08.2024.
//

import AnywayPaymentDomain
@testable import ForaBank
import XCTest

final class InitialAnywayTransactionComposerTests: XCTestCase {
    
    func test_compose_shouldDeliverNilOnResponseMappingFailure() {
        
        let sut = makeSUT()
        
        XCTAssertNil(sut.compose(with: makeInput(), and: makeFailingResponse()))
    }
    
    func test_compose_shouldDeliverTransactionWithFirstFieldNilOnNil() throws {
        
        let input = makeInput(firstField: nil)
        let sut = makeSUT()
        
        let transaction = try XCTUnwrap(sut.compose(with: input, and: makeResponse()))
        
        XCTAssertNil(transaction.firstInitialField)
    }
    
    func test_compose_shouldDeliverTransactionWithFirstInitialField() throws {
        
        let (name, icon) = (anyMessage(), anyMessage())
        let firstField = makeFirstField(name: name, icon: icon)
        let input = makeInput(firstField: firstField)
        let sut = makeSUT()
        
        let transaction = try XCTUnwrap(sut.compose(with: input, and: makeResponse()))
        
        XCTAssertNoDiff(
            transaction.firstInitialField,
            makeFirstField(name: name, icon: icon)
        )
    }
    
    func test_compose_shouldDeliverTransactionWithFirstField() throws {
        
        let (name, icon) = (anyMessage(), anyMessage())
        let firstField = makeFirstField(name: name, icon: icon)
        let input = makeInput(firstField: firstField)
        let sut = makeSUT()
        
        let transaction = try XCTUnwrap(sut.compose(with: input, and: makeResponse()))
        
        XCTAssertNoDiff(
            transaction.firstField,
            makeFirstField(name: name, icon: icon)
        )
    }
    
    func test_compose_shouldDeliverTransactionWithAmountFromOutlineNil() throws {
        
        let outline = makeAnywayPaymentOutline(amount: nil)
        let input = makeInput(outline: outline)
        let sut = makeSUT()
        
        let transaction = try XCTUnwrap(sut.compose(with: input, and: makeResponse()))
        
        XCTAssertNil(transaction.context.initial.amount)
        XCTAssertNil(transaction.context.payment.amount)
    }
    
    func test_compose_shouldDeliverTransactionWithAmountFromOutline() throws {
        
        let amount = anyAmount()
        let outline = makeAnywayPaymentOutline(amount: amount)
        let input = makeInput(outline: outline)
        let sut = makeSUT()
        
        let transaction = try XCTUnwrap(sut.compose(with: input, and: makeResponse()))
        
        XCTAssertEqual(transaction.context.initial.amount, amount)
        XCTAssertEqual(transaction.context.payment.amount, amount)
    }
    
    func test_compose_shouldDeliverTransactionWithFooterSetToContinue() throws {
        
        let sut = makeSUT()
        
        let transaction = try XCTUnwrap(sut.compose(with: makeInput(), and: makeResponse()))
        
        XCTAssertEqual(transaction.context.initial.footer, .continue)
        XCTAssertEqual(transaction.context.payment.footer, .continue)
    }
    
    func test_compose_shouldDeliverTransactionWithOutline() throws {
        
        let outline = makeAnywayPaymentOutline()
        let input = makeInput(outline: outline)
        let sut = makeSUT()
        
        let transaction = try XCTUnwrap(sut.compose(with: input, and: makeResponse()))
        
        XCTAssertEqual(transaction.context.outline, outline)
    }
    
    func test_compose_shouldDeliverTransactionWithEmptyStaged() throws {
        
        let sut = makeSUT()
        
        let transaction = try XCTUnwrap(sut.compose(with: makeInput(), and: makeResponse()))
        
        XCTAssertEqual(transaction.context.staged, .init())
    }
    
    func test_compose_shouldDeliverTransactionWithShouldRestartFalse() throws {
        
        let sut = makeSUT()
        
        let transaction = try XCTUnwrap(sut.compose(with: makeInput(), and: makeResponse()))
        
        XCTAssertFalse(transaction.context.shouldRestart)
    }
    
    // MARK: - Helpers
    
    private typealias SUT = InitialAnywayTransactionComposer
    
    private func makeSUT(
        isValid: Bool = true,
        file: StaticString = #file,
        line: UInt = #line
    ) -> SUT {
        
        let sut = SUT(isValid: { _ in isValid })
        
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return sut
    }
    
    private func makeInput(
        outline: AnywayPaymentOutline = makeAnywayPaymentOutline(),
        firstField: AnywayElement.Field? = nil
    ) -> SUT.Input {
        
        return .init(outline: outline, firstField: firstField)
    }
    
    private func makeFailingResponse(
        file: StaticString = #file,
        line: UInt = #line
    ) -> SUT.Response {
        
        let response = makeCreateAnywayTransferResponse(
            finalStep: false,
            needMake: true
        )
        XCTAssertNil(AnywayPaymentUpdate(response), "Expected to have failing response.", file: file, line: line)
        
        return response
    }
    
    private func makeResponse(
    ) -> SUT.Response {
        
        return makeCreateAnywayTransferResponse()
    }
    
    private func makeFirstField(
        name: String = anyMessage(),
        icon: String? = nil
    ) -> AnywayElement.Field {
        
        return .init(
            id: "_selected_service",
            title: "Услуга",
            value: name,
            icon: icon.map { .md5Hash($0) }
        )
    }
}

private extension AnywayTransactionState.Transaction {
    
    var firstInitialField: AnywayElement.Field? {
        
        guard case let .field(field) = context.initial.elements.first
        else { return nil }
        
        return field
    }
    
    var firstField: AnywayElement.Field? {
        
        guard case let .field(field) = context.payment.elements.first
        else { return nil }
        
        return field
    }
}
