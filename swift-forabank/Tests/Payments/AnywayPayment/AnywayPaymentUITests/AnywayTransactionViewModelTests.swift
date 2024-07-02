//
//  AnywayTransactionViewModelTests.swift
//
//
//  Created by Igor Malyarov on 15.06.2024.
//

import AnywayPaymentDomain
import AnywayPaymentUI
import Combine
import XCTest

final class AnywayTransactionViewModelTests: XCTestCase {
    
    // MARK: - init
    
    func test_init_shouldSetTransactionOnEmptyTransaction() throws {
        
        let initial = makeTransaction()
        let emptyTransaction = makeTransaction()
        let (_, spy, _,_) = makeSUT(
            initial: initial,
            stubs: [(emptyTransaction, nil)]
        )
        
        XCTAssertNoDiff(spy.values.map(\.transaction), [emptyTransaction])
        XCTAssertTrue(isEmpty(emptyTransaction))
    }
    
    func test_init_shouldNotSetModelsOnEmptyTransaction() throws {
        
        let emptyTransaction = makeTransaction()
        let (_, spy, _,_) = makeSUT(
            initial: emptyTransaction,
            stubs: [(emptyTransaction, nil)]
        )
        
        let models = try XCTUnwrap(spy.values.map(\.models).first)
        XCTAssertTrue(models.isEmpty)
        XCTAssertTrue(isEmpty(emptyTransaction))
    }
    
    func test_init_shouldSetTransactionOnNonEmptyTransaction() {
        
        let transaction = makeTransaction(
            elements: [makeFieldAnywayElement()]
        )
        let (_, spy, _,_) = makeSUT(
            initial: transaction,
            stubs: [(transaction, nil)]
        )
        
        XCTAssertNoDiff(spy.values.map(\.transaction), [transaction])
        XCTAssertFalse(isEmpty(transaction))
    }
    
    func test_init_shouldSetModelsOnNonEmptyTransaction() {
        
        let field = makeFieldAnywayElement()
        let parameter = makeParameterAnywayElement()
        let transaction = makeTransaction(
            elements: [field, parameter]
        )
        let (_, spy, _,_) = makeSUT(
            initial: transaction,
            stubs: [(transaction, nil)]
        )
        
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
        let (sut, spy, _,_) = makeSUT(
            initial: initial,
            stubs: [
                (initial, nil),
                (transaction, nil)
            ]
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
        
        let (sut, spy, _,_) = makeSUT(
            initial: initial,
            stubs: [
                (initial, nil),
                (transaction, nil)
            ]
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
        let (sut, spy, _,_) = makeSUT(
            initial: initial,
            stubs: [
                (initial, nil),
                (transaction, nil)
            ]
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
        let (sut, _,_,_) = makeSUT(
            stubs: [makeStub(), (makeTransaction(), effect)],
            handleEffect: effectSpy.handleEffect
        )
        
        sut.event(.continue)
        
        XCTAssertNoDiff(effectSpy.messages.map(\.effect), [effect])
    }
    
    // TODO: fix test - need to model transaction stubs in a real way
    // that would stop roundtrip between model and footer
    //    func test_event_shouldDeliverEventOnHandleEffectCompletion() {
    //
    //        let (initial, transaction1, transaction2) = (makeTransaction(), makeTransaction(), makeTransaction())
    //        let effectSpy = EffectHandlerSpy<SUT.Event, SUT.Effect>()
    //        let (sut, spy, _,_) = makeSUT(
    //            initial: initial,
    //            stubs: [
    //                makeStub(),
    //                (initial, nil),
    //                (transaction1, makeEffect()),
    //                (transaction2, nil),
    //            ],
    //            handleEffect: effectSpy.handleEffect
    //        )
    //
    //        sut.event(.continue)
    //        effectSpy.complete(with: .dismissRecoverableError)
    //
    //        XCTAssertNoDiff(spy.values.map(\.transaction), [
    //            initial,
    //            transaction1,
    //            transaction2
    //        ])
    //        XCTAssertNotEqual(initial, transaction1)
    //        XCTAssertNotEqual(transaction1, transaction2)
    //    }
    
    // TODO: add tests for footer
    
    func test_footer_tap_shouldCallReduceWithContinueEvent() {
        
        let (sut, _, reducer, footer) = makeSUT(stubs: [makeStub(), makeStub()])
        
        tapContinue(footer)
        
        XCTAssertNoDiff(reducer.messages.map(\.event), [
            .payment(.widget(.amount(0))),
            .continue
        ])
        XCTAssertNotNil(sut)
    }
    
    func test_footer_amount_shouldCallReduceWithWidgetAmountEvent() {
        
        let amount = anyAmount()
        let (sut, _, reducer, footer) = makeSUT(stubs: [makeStub(), makeStub()])
        
        footer.state = .amount(amount)
        
        XCTAssertNoDiff(reducer.messages.map(\.event), [
            .payment(.widget(.amount(0))),
            .payment(.widget(.amount(amount)))
        ])
        XCTAssertNotNil(sut)
    }
    
    func test_transaction_change_shouldSetFooterButtonState() {
        
        let (sut, _,_, footer) = makeSUT([
            makeTransaction(isValid: false),
            makeTransaction(isValid: true),
            makeTransaction(isValid: false),
            makeTransaction(isValid: false),
            makeTransaction(isValid: false),
            makeTransaction(isValid: true),
        ])
        
        sut.event(.continue)
        sut.event(.continue)
        sut.event(.continue)
        sut.event(.continue)
        sut.event(.continue)
        
        XCTAssertNoDiff(footer.messages.map(\.isEnabled), [
            false,
            true,
            false,
            false,
            false,
            true,
        ])
        XCTAssertNotNil(sut)
    }
    
    func test_transaction_change_shouldSetFooterButtonStateOnIsValidAndInlightStatus() {
        
        let (sut, _,_, footer) = makeSUT([
            makeTransaction(isValid: false),
            makeTransaction(isValid: true),
            makeTransaction(isValid: true, status: .inflight),
            makeTransaction(isValid: true),
        ])
        
        sut.event(.continue)
        sut.event(.continue)
        sut.event(.continue)
        
        XCTAssertNoDiff(footer.messages.map(\.isEnabled), [
            false,
            true,
            false,
            true,
        ])
        XCTAssertNotNil(sut)
    }
    
    func test_transactionAmountChange_shouldSetFooterStyle() {
        
        let (sut, _,_, footer) = makeSUT([
            makeTransactionWithContinue(),
            makeTransactionWithAmount(amount: 10),
            makeTransactionWithAmount(amount: 30),
            makeTransactionWithAmount(amount: 40),
            makeTransactionWithContinue(),
            makeTransactionWithAmount(amount: 20),
        ])
        
        sut.event(.continue)
        sut.event(.continue)
        sut.event(.continue)
        sut.event(.continue)
        sut.event(.continue)
        
        XCTAssertNoDiff(footer.messages.map(\.style), [
            .button,
            .amount,
            .amount,
            .amount,
            .button,
            .amount
        ])
        XCTAssertNotNil(sut)
    }
    
    func test_transactionAmountChange_shouldCallFooterWithAmount() {
        
        let (sut, _,_, footer) = makeSUT([
            makeTransactionWithContinue(),
            makeTransactionWithAmount(amount: 10.01),
            makeTransactionWithAmount(amount: 20.02),
            makeTransactionWithAmount(amount: 30.03),
        ])
        
        sut.event(.continue)
        sut.event(.continue)
        sut.event(.continue)
        
        XCTAssertNoDiff(footer.values, [
            10.01,
            20.02,
            30.03,
        ])
        XCTAssertNotNil(sut)
    }
    
    // TODO: ad tests for model receive messages
    
    // MARK: - Helpers
    
    private typealias SUT = AnywayTransactionViewModel<TestFooter, Model, DocumentStatus, Response>
    private typealias AmountViewModel = String
    private typealias DocumentStatus = Int
    private typealias Response = String
    
    private typealias TransactionStatus = SUT.TransactionStatus
    
    private typealias Spy = ValueSpy<SUT.State>
    
    private typealias Reducer = ReducerSpy<SUT.State.Transaction, SUT.Event, SUT.Effect>
    private typealias Stub = (SUT.State.Transaction, SUT.Effect?)
    
    private func makeSUT(
        _ stubs: [SUT.State.Transaction],
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        spy: Spy,
        reducerSpy: Reducer,
        footer: TestFooter
    ) {
        makeSUT(
            stubs: stubs.map { ($0, nil) },
            file: file,
            line: line
        )
    }
    
    private func makeSUT(
        initial: SUT.State.Transaction = makeTransaction(),
        stubs: [Stub] = [],
        handleEffect: @escaping SUT.HandleEffect = { _,_ in },
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        spy: Spy,
        reducerSpy: Reducer,
        footer: TestFooter
    ) {
        let footer = TestFooter()
        let reducer = Reducer(stub: stubs)
        let sut = SUT(
            transaction: initial,
            mapToModel: { event in { .init(value: $0) } },
            footer: footer,
            reduce: reducer.reduce(_:_:),
            handleEffect: handleEffect,
            scheduler: .immediate
        )
        let spy = ValueSpy(sut.$state)
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(spy, file: file, line: line)
        trackForMemoryLeaks(reducer, file: file, line: line)
        trackForMemoryLeaks(footer, file: file, line: line)
        
        return (sut, spy, reducer, footer)
    }
    
    private func makeStub(
    ) -> Stub {
        
        return (makeTransaction(), nil)
    }
    
    private func makeEffect(
    ) -> SUT.Effect {
        
        return .continue(makeAnywayPaymentDigest())
    }
    
    private final class Model: Receiver {

        private(set) var value: AnywayElement
        private(set) var messages = [AnywayMessage]()
        
        init(value: AnywayElement) {
            
            self.value = value
        }
        
        func receive(_ message: AnywayMessage) {
            
            messages.append(message)
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
    
    private final class TestFooter: FooterInterface, Receiver, ObservableObject {
        
        @Published var state: Projection = .amount(0)
        
        private(set) var messages = [FooterTransactionProjection]()
        private(set) var values = [Decimal]()
        
        var projectionPublisher: AnyPublisher<Projection, Never> {
            
            $state.eraseToAnyPublisher()
        }
        
        func project(_ event: FooterTransactionProjection) {
            
            messages.append(event)
        }
        
        func receive(_ value: Decimal) {
            values.append(value)
        }
    }
    
    // MARK: - DSL
    
    private func tapContinue(_ footer: TestFooter) {
        
        footer.state = .buttonTapped
    }
}
