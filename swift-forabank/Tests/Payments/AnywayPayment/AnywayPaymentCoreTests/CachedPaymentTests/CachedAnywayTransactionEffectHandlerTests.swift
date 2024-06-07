//
//  CachedAnywayTransactionEffectHandlerTests.swift
//
//
//  Created by Igor Malyarov on 07.06.2024.
//

import AnywayPaymentCore
import AnywayPaymentDomain
import Combine

enum CachedAnywayTransactionEvent<State, TransactionEvent> {
    
    case stateUpdate(State)
    case transaction(TransactionEvent)
}

extension CachedAnywayTransactionEvent: Equatable where State: Equatable, TransactionEvent: Equatable {}

enum CachedAnywayTransactionEffect<TransactionEvent> {
    
    case event(TransactionEvent)
}

extension CachedAnywayTransactionEffect: Equatable where TransactionEvent: Equatable {}

final class CachedAnywayTransactionEffectHandler<State, TransactionEvent> {
    
    private let statePublisher: AnyPublisher<State, Never>
    private let eventHandler: (TransactionEvent) -> Void
    
    private var cancellable: AnyCancellable?
    
    init(
        statePublisher: AnyPublisher<State, Never>,
        event: @escaping (TransactionEvent) -> Void
    ) {
        self.statePublisher = statePublisher
        self.eventHandler = event
    }
}

extension CachedAnywayTransactionEffectHandler {
    
    func handleEffect(
        _ effect: Effect,
        _ dispatch: @escaping Dispatch
    ) {
        switch effect {
        case let .event(transactionEvent):
            self.eventHandler(transactionEvent)
            self.cancellable = statePublisher
                .sink { dispatch(.stateUpdate($0)) }
        }
    }
}

extension CachedAnywayTransactionEffectHandler {
    
    typealias Dispatch = (Event) -> Void
    
    typealias Event = CachedAnywayTransactionEvent<State, TransactionEvent>
    typealias Effect = CachedAnywayTransactionEffect<TransactionEvent>
}

import XCTest

final class CachedAnywayTransactionEffectHandlerTests: XCTestCase {
    
    func test_init_shouldNotCallEvent() {
        
        let (_, spy) = makeSUT()
        
        XCTAssertEqual(spy.receivedEvents, [])
    }
    
    func test_handleEffect_shouldPassEventToEvent() {
        
        let (sut, spy) = makeSUT()
        
        sut.handleEffect(.event(.continue), { _ in })
        
        XCTAssertNoDiff(spy.receivedEvents, [.continue])
    }
    
    func test_handleEffect_shouldDeliverStateOnStateUpdate() {
        
        var stateUpdates = [State]()
        let (sut, spy) = makeSUT()
        
        sut.handleEffect(.event(.continue)) { event in
            
            switch event {
            case let .stateUpdate(state):
                stateUpdates.append(state)
                
            default:
                fatalError()
            }
        }
        XCTAssertNoDiff(stateUpdates, [])
        
        let updatedState = makeState()
        spy.send(updatedState)
        
        XCTAssertNoDiff(stateUpdates, [updatedState])
    }
    
    // MARK: - Helpers
    
    private typealias SUT = CachedAnywayTransactionEffectHandler<State, TransactionEvent>
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        spy: Spy
    ) {
        let spy = Spy()
        let sut = SUT(
            statePublisher: spy.statePublisher,
            event: spy.event(_:)
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(spy, file: file, line: line)
        
        return (sut, spy)
    }
    
    private struct State: Equatable {
        
        let value: String
    }
    
    private func makeState(
        _ value: String = anyMessage()
    ) -> State {
        
        return .init(value: value)
    }
    
    private enum TransactionEvent: Equatable {
        
        case `continue`
    }
    
    private final class Spy {
        
        private let subject = PassthroughSubject<State, Never>()
        
        private(set) var receivedEvents = [TransactionEvent]()
        
        var statePublisher: AnyPublisher<State, Never> {
            
            subject.eraseToAnyPublisher()
        }
        
        func event(_ event: TransactionEvent) {
            
            self.receivedEvents.append(event)
        }
        
        func send(_ state: State) {
            
            subject.send(state)
        }
    }
}

final class CachedAnywayTransactionReducer<Input, State, TransactionEvent> {
    
    private let update: Update
    
    init(
        update: @escaping Update
    ) {
        self.update = update
    }
    
    typealias Update = (State, Input) -> State
}

extension CachedAnywayTransactionReducer {
    
    func reduce(
        _ state: State,
        _ event: Event
    ) -> (State, Effect?) {
        
        var state = state
        var effect: Effect?
        
        switch event {
        case let .stateUpdate(input):
            state = update(state, input)
            
        case let .transaction(transactionEvent):
            effect = .event(transactionEvent)
        }
        
        return (state, effect)
    }
}

extension CachedAnywayTransactionReducer {
    
    // typealias State = CachedAnywayTransactionState<Model>
    typealias Event = CachedAnywayTransactionEvent<Input, TransactionEvent>
    typealias Effect = CachedAnywayTransactionEffect<TransactionEvent>
}

final class CachedAnywayTransactionReducerTests: XCTestCase {
    
    // MARK: - stateUpdate
    
    func test_stateUpdate_shouldUpdateState() {
        
        assertState(.stateUpdate(makeInput(1)), on: makeState("a")) {
            
            $0 = self.makeState("a1")
        }
    }
    
    func test_stateUpdate_shouldNotDeliverEffect() {
        
        assert(.stateUpdate(makeInput()), on: makeState(), effect: nil)
    }
    
    // MARK: - transaction
    
    func test_transaction_shouldNotChangeState() {
        
        assertState(.transaction(.continue), on: makeState())
    }
    
    func test_transaction_shouldDeliverEffect() {
        
        assert(.transaction(.continue), on: makeState(), effect: .event(.continue))
    }
    
    // MARK: - Helpers
    
    private typealias SUT = CachedAnywayTransactionReducer<Input, State, TransactionEvent>
    private typealias Event = SUT.Event
    private typealias Effect = SUT.Effect
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> SUT {
        
        let sut = SUT(update: { .init(value: $0.value + "\($1.value)") })
        
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return sut
    }
    
    private func makeInput(
        _ value: Int = .random(in: 1...1_000)
    ) -> Input {
        
        return .init(value: value)
    }
    
    private func makeState(
        _ value: String = anyMessage()
    ) -> State {
        
        return .init(value: value)
    }
    
    private struct Input: Equatable {
        
        let value: Int
    }
    
    private struct State: Equatable {
        
        let value: String
    }
    
    private enum TransactionEvent: Equatable {
        
        case `continue`
    }
    
    private typealias UpdateStateToExpected<State> = (_ state: inout State) -> Void
    
    private func assertState(
        sut: SUT? = nil,
        _ event: Event,
        on state: State,
        updateStateToExpected: UpdateStateToExpected<State>? = nil,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let sut = sut ?? makeSUT()
        
        var expectedState = state
        updateStateToExpected?(&expectedState)
        
        let (receivedState, _) = sut.reduce(state, event)
        
        XCTAssertNoDiff(
            receivedState,
            expectedState,
            "\nExpected \(expectedState), but got \(receivedState) instead.",
            file: file, line: line
        )
    }
    
    private func assert(
        sut: SUT? = nil,
        _ event: Event,
        on state: State,
        effect expectedEffect: Effect?,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let sut = sut ?? makeSUT()
        
        let (_, receivedEffect) = sut.reduce(state, event)
        
        XCTAssertNoDiff(
            receivedEffect,
            expectedEffect,
            "\nExpected \(String(describing: expectedEffect)), but got \(String(describing: receivedEffect)) instead.",
            file: file, line: line
        )
    }
}

final class CachedAnywayTransactionUpdater<Model> {
    
    private let map: Map
    
    init(
        map: @escaping Map
    ) {
        self.map = map
    }
    
    typealias Map = (AnywayElement) -> Model
}

extension CachedAnywayTransactionUpdater {
    
    func update(
        _ transaction: CachedTransaction,
        with input: Transaction
    ) -> CachedTransaction {
        
        return .init(
            payment: .init(
                payment: transaction.payment.payment.updating(
                    with: input.payment.payment,
                    using: map
                ),
                staged: input.payment.staged,
                outline: input.payment.outline,
                shouldRestart: input.payment.shouldRestart
            ),
            isValid: input.isValid,
            status: input.status
        )
    }
    
    typealias CachedTransaction = CachedAnywayTransactionState<Model>
    typealias Transaction = AnywayTransactionState
}

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
    
    private typealias SUT = CachedAnywayTransactionUpdater<Model>
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
