//
//  AnywayTransactionViewModelTests.swift
//
//
//  Created by Igor Malyarov on 15.06.2024.
//

import AnywayPaymentDomain
import AnywayPaymentUI
import XCTest

final class AnywayTransactionViewModelTests: XCTestCase {
    
    // MARK: - init
    
    func test_init_shouldSetTransactionOnEmptyTransaction() throws {
        
        let emptyTransaction = makeTransaction()
        let (_, spy) = makeSUT(initial: emptyTransaction)
        
        XCTAssertNoDiff(spy.values.map(\.transaction), [emptyTransaction])
        XCTAssertTrue(isEmpty(emptyTransaction))
    }
    
    func test_init_shouldNotSetModelsOnEmptyTransaction() throws {
        
        let emptyTransaction = makeTransaction()
        let (_, spy) = makeSUT(initial: emptyTransaction)
        
        let models = try XCTUnwrap(spy.values.map(\.models).first)
        XCTAssertTrue(models.isEmpty)
        XCTAssertTrue(isEmpty(emptyTransaction))
    }
    
    func test_init_shouldSetTransactionOnNonEmptyTransaction() {
        
        let transaction = makeTransaction(
            elements: [makeFieldAnywayElement()]
        )
        let (_, spy) = makeSUT(initial: transaction)
        
        XCTAssertNoDiff(spy.values.map(\.transaction), [transaction])
        XCTAssertFalse(isEmpty(transaction))
    }
    
    func test_init_shouldSetModelsOnNonEmptyTransaction() {
        
        let field = makeFieldAnywayElement()
        let parameter = makeParameterAnywayElement()
        let transaction = makeTransaction(
            elements: [field, parameter]
        )
        let (_, spy) = makeSUT(initial: transaction)
        
        assertModels(spy, match: [[field.id: field, parameter.id: parameter]])
        XCTAssertFalse(isEmpty(transaction))
    }
    
    // MARK: - event
    
    func test_event_shouldChangeTransaction() {
        
        let initial = makeTransaction(
            elements: [makeFieldAnywayElement()]
        )
        let transaction = makeTransaction(
            elements: [makeParameterAnywayElement()]
        )
        let (sut, spy) = makeSUT(
            initial: initial,
            stub: [(transaction, nil)]
        )
        
        sut.event(.continue)
        
        XCTAssertNoDiff(spy.values.map(\.transaction), [
            initial,
            transaction
        ])
        XCTAssertNotEqual(transaction, initial)
    }
    
    func test_event_shouldNotChangeModelsOnSameElements() {
        
        let id = anyMessage()
        let field = makeFieldAnywayElement(id: id)
        let initial = makeTransaction(
            elements: [field]
        )
        
        let updatedField = makeFieldAnywayElement(id: id)
        XCTAssertNotEqual(field, updatedField)
        let transaction = makeTransaction(
            elements: [updatedField]
        )
        
        let (sut, spy) = makeSUT(
            initial: initial,
            stub: [(transaction, nil)]
        )
        
        sut.event(.continue)
        
        let models = spy.values.map(\.models)
        XCTAssertEqual(models.count, 2)
        assertSameModels(models.first, models.last)
    }
    
    func test_event_shouldCreateNewModelsForNewElements() throws {
        
        let field = makeFieldAnywayElement()
        let initial = makeTransaction(
            elements: [field]
        )
        let parameter = makeParameterAnywayElement()
        let transaction = makeTransaction(
            elements: [field, parameter]
        )
        let (sut, spy) = makeSUT(
            initial: initial,
            stub: [(transaction, nil)]
        )
        
        sut.event(.continue)
        
        let models = spy.values.map(\.models)
        XCTAssertEqual(models.count, 2)
        
        let firstFieldModel = try XCTUnwrap(models.first?[field.id])
        let lastFieldModel = try XCTUnwrap(models.last?[field.id])
        XCTAssertTrue(firstFieldModel === lastFieldModel)
        
        let firstParameterModel = models.first?[parameter.id]
        XCTAssertNil(firstParameterModel)
        
        let lastParameterModel = models.last?[parameter.id]
        XCTAssertNotNil(lastParameterModel)
        
    }
    
    func test_event_shouldCallHandleEffectWithEffectOnEffect() {
        
        let effect = makeEffect()
        let effectSpy = EffectHandlerSpy<SUT.Event, SUT.Effect>()
        let (sut, _) = makeSUT(
            stub: [(makeTransaction(), effect)],
            handleEffect: effectSpy.handleEffect
        )
        
        sut.event(.continue)
        
        XCTAssertNoDiff(effectSpy.messages.map(\.effect), [effect])
    }
    
    func test_event_shouldDeliverEventOnHandleEffectCompletion() {
        
        let (initial, transaction1, transaction2) = (makeTransaction(), makeTransaction(), makeTransaction())
        let effectSpy = EffectHandlerSpy<SUT.Event, SUT.Effect>()
        let (sut, spy) = makeSUT(
            initial: initial,
            stub: [
                (transaction1, makeEffect()),
                (transaction2, nil),
            ],
            handleEffect: effectSpy.handleEffect
        )
        
        sut.event(.continue)
        effectSpy.complete(with: .dismissRecoverableError)
        
        XCTAssertNoDiff(spy.values.map(\.transaction), [
            initial,
            transaction1,
            transaction2
        ])
        XCTAssertNotEqual(initial, transaction1)
        XCTAssertNotEqual(transaction1, transaction2)
    }
    
    func test_event_shouldDeliverStatusToObserveWithoutDuplicates() {
        
        let transaction1 = makeTransaction(
            status: .awaitingPaymentRestartConfirmation
        )
        let transaction2 = makeTransaction(
            status: .fraudSuspected
        )
        let transaction2a = makeTransaction(
            status: .fraudSuspected
        )
        let transaction3 = makeTransaction(
            status: nil
        )
        var observed = [TransactionStatus?]()
        let (sut, _) = makeSUT(
            stub: [
                (transaction1, nil),
                (transaction2, nil),
                (transaction2a, nil),
                (transaction3, nil),
            ],
            observe: { observed.append($0) }
        )
        
        sut.event(.continue)
        sut.event(.continue)
        sut.event(.continue)
        sut.event(.continue)
        
        XCTAssertNoDiff(observed, [
            .awaitingPaymentRestartConfirmation,
            .fraudSuspected,
            nil
        ])
    }
    
    // MARK: - Helpers
    
    private typealias SUT = AnywayTransactionViewModel<Model, DocumentStatus, Response>
    private typealias DocumentStatus = Int
    private typealias Response = String
    
    private typealias TransactionStatus = SUT.TransactionStatus
    
    private typealias Spy = ValueSpy<SUT.State>
    
    private typealias Reducer = ReducerSpy<SUT.State.Transaction, SUT.Event, SUT.Effect>
    
    private func makeSUT(
        initial: SUT.State.Transaction = makeTransaction(),
        stub: [(SUT.State.Transaction, SUT.Effect?)] = [],
        handleEffect: @escaping SUT.HandleEffect = { _,_ in },
        observe: @escaping SUT.Observe = { _ in },
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        spy: Spy
    ) {
        let reducer = Reducer(stub: stub)
        let sut = SUT(
            transaction: initial,
            mapToModel: { .init(value: $0) },
            reduce: reducer.reduce(_:_:),
            handleEffect: handleEffect,
            observe: observe,
            scheduler: .immediate
        )
        let spy = ValueSpy(sut.$state)
        
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return (sut, spy)
    }
    
    private func makeEffect(
    ) -> SUT.Effect {
        
        return .continue(makeAnywayPaymentDigest())
    }
    
    private final class Model {
        
        var value: AnywayElement
        
        init(value: AnywayElement) {
            
            self.value = value
        }
    }
    
    private func assertModels(
        _ spy: Spy,
        match: [[AnywayElement.ID: AnywayElement]],
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let matchable = spy.values.map(\.models).map { $0.mapValues(\.value) }
        XCTAssertNoDiff(matchable, match, file: file, line: line)
    }
    
    private func assertSameModels(
        _ lhs: [AnywayElement.ID: Model]?,
        _ rhs: [AnywayElement.ID: Model]?,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        switch (lhs, rhs) {
        case (.none, .none):
            break
            
        case (.none, .some), (.some, .none):
            XCTFail("Expected non nil dictionary", file: file, line: line)
            
        case let (.some(lhs), .some(rhs)):
            XCTAssertNoDiff(
                lhs.mapValues { ObjectIdentifier($0) },
                rhs.mapValues { ObjectIdentifier($0) },
                file: file, line: line
            )
        }
    }
}
