//
//  ObservingCachedTransactionViewModelTests.swift
//
//
//  Created by Igor Malyarov on 06.06.2024.
//

import AnywayPaymentCore
import AnywayPaymentDomain
import Combine
import CombineSchedulers
import Foundation
import RxViewModel

protocol RxObservableObject<State, Event>: ObservableObject {
    
    associatedtype State
    associatedtype Event
    
    var state: State { get }
    var statePublisher: AnyPublisher<State, Never> { get }
    
    func event(_ event: Event)
}

extension RxViewModel: RxObservableObject {
    
    var statePublisher: AnyPublisher<State, Never> {
        
        $state.eraseToAnyPublisher()
    }
}

extension ObservingCachedPaymentViewModel: RxObservableObject {
    
    var statePublisher: AnyPublisher<State, Never> {
        
        $state.eraseToAnyPublisher()
    }
}

typealias CachedAnywayTransactionState<ElementModel> = TransactionOf<OperationDetailID, OperationDetails, DocumentStatus, CachedPaymentContext<ElementModel>>
typealias AnywayTransactionState = TransactionOf<OperationDetailID, OperationDetails, DocumentStatus, AnywayPaymentContext>
typealias AnywayTransactionEvent = TransactionEventOf<OperationDetailID, OperationDetails, DocumentStatus, AnywayPaymentEvent, AnywayPaymentUpdate>

typealias CachedAnywayPaymentContext = CachedPaymentContext<AnywayPaymentElementModel>

typealias AnywayPaymentElementModel = AnywayElement
//typealias AnywayPaymentElementModel = ElementModel<
//    AnywayElement.Field,
//    AnywayElement.Parameter,
//    AnywayElement.Widget
//>

enum ElementModel<Field, Parameter, Widget> {
    
    case field(Field)
    case parameter(Parameter)
    case widget(Widget)
}

final class ObservingCachedPaymentViewModel<ElementModel>: ObservableObject {
    
    @Published private(set) var state: State
    
    private let source: Source
    private var cancellables = Set<AnyCancellable>()
    
    init(
        source: Source,
        map: @escaping Map,
        observe: @escaping Observe,
        scheduler: AnySchedulerOf<DispatchQueue> = .main
    ) {
        self.state = source.state.makeCachedAnywayTransactionState(using: map)
        self.source = source
        
        self.subscribe(source: source, map: map, observe: observe)
    }
    
    typealias State = CachedAnywayTransactionState<ElementModel>
    
    typealias Source = any RxObservableObject<SourceState, Event>
    typealias SourceState = AnywayTransactionState
    typealias Event = AnywayTransactionEvent
    
    typealias Map = (AnywayElement) -> ElementModel
    typealias Observe = (State) -> Void
}

extension ObservingCachedPaymentViewModel {
    
    func event(_ event: Event) {
        
        source.event(event)
    }
}

private extension ObservingCachedPaymentViewModel {
    
    func subscribe(
        source: Source,
        map: @escaping Map,
        observe: @escaping Observe,
        scheduler: AnySchedulerOf<DispatchQueue> = .main
    ) {
        source.statePublisher
            .dropFirst(1) // why?
            .removeDuplicates()
            .compactMap { [weak self] transaction in
                
                guard let self else { return nil }
                
                return transaction.updating(self.state, using: map)
            }
            .receive(on: scheduler)
        // .handleEvents(receiveOutput: observe)
            .assign(to: &$state)
        
        $state
            .dropFirst(1) // why?
            .sink(receiveValue: observe)
            .store(in: &cancellables)
    }
}

extension AnywayTransactionState {
    
    func makeCachedAnywayTransactionState<T>(
        using map: @escaping (AnywayElement) -> T
    ) -> CachedAnywayTransactionState<T> {
        
        return .init(
            payment: .init(payment, using: map),
            isValid: isValid,
            status: status
        )
    }
    
    func updating<T>(
        _ state: CachedAnywayTransactionState<T>,
        using map: @escaping (AnywayElement) -> T
    ) -> CachedAnywayTransactionState<T> {
        
        let updated = state.payment.updating(with: payment, using: map)
        
        return .init(
            payment: updated,
            isValid: state.isValid,
            status: state.status
        )
    }
}

import XCTest
import RxViewModel

final class ObservingCachedTransactionViewModelTests: XCTestCase {
    
    func test_init_shouldSetInitialValue() {
        
        let initialState = makeSourceState()
        let (_,_, spy) = makeSUT(initialState: initialState)
        
        XCTAssertNoDiff(spy.values, [
            initialState.makeCachedAnywayTransactionState(using: { $0 })
        ])
    }
    
    func test_init_shouldSetNonEmptyInitialValueOnNonEmpty() {
        
        let field0 = makeAnywayPaymentField(id: "000")
        let initialState = makeSourceState(
            payment: makeAnywayPaymentContext(
                payment: makeAnywayPayment(fields: [field0])
            )
        )
        let (sut, _, spy) = makeSUT(initialState: initialState)
        
        XCTAssertNoDiff(spy.values, [
            initialState.makeCachedAnywayTransactionState(using: { $0 })
        ])
        XCTAssertNoDiff(spy.values.map(\.payment.payment.models), [
            [.init(id: .fieldID("000"), model: .field(field0))]
        ])
        XCTAssertNotNil(sut)
    }
    
    func test_init_shouldNotDeliverValueToObserve() {
        
        var observedState: SUT.State?
        let (sut, _,_) = makeSUT { observedState = $0 }
        
        XCTAssertNil(observedState)
        XCTAssertNotNil(sut)
    }
    
    func test_event_shouldPassEventToSource() {
        
        let (sut, source, _) = makeSUT()
        
        sut.event(.initiatePayment)
        sut.event(.continue)
        
        XCTAssertNoDiff(source.events, [.initiatePayment, .continue])
    }
    
    func test_source_shouldUpdateState() {
        
        let (sut, source, spy) = makeSUT()
        
        let field = makeAnywayPaymentField(id: "123")
        let context = makeAnywayPaymentContext(
            payment: makeAnywayPayment(fields: [field])
        )
        source.send(.init(payment: context, isValid: false))
        
        XCTAssertNoDiff(spy.values.map(\.payment.payment.models), [[]])
        
        _ = XCTWaiter().wait(for: [.init()], timeout: 1) // why wait?
        XCTAssertNoDiff(spy.values.map(\.payment.payment.models), [
            [],
            [.init(id: .fieldID("123"), model: .field(field))]
        ])
        XCTAssertNotNil(sut)
    }
    
    func test_source_shouldDeliverValueToObserveWithEmptyInitial() {
        
        var observedStates = [SUT.State]()
        let (sut, source,_) = makeSUT { observedStates.append($0) }
        
        let field = makeAnywayPaymentField(id: "123")
        let context = makeAnywayPaymentContext(
            payment: makeAnywayPayment(fields: [field])
        )
        source.send(.init(payment: context, isValid: false))
        
        XCTAssertEqual(observedStates.count, 0) // why 0?
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.05) // why wait?
        XCTAssertEqual(observedStates.count, 1) // why 2?
        XCTAssertNotNil(sut)
        
        XCTAssertNoDiff(observedStates.map(\.payment.payment.models), [
            // [],
            [.init(id: .fieldID("123"), model: .field(field))]
        ])
    }
    
    func test_source_shouldDeliverValueToObserveWithNonEmptyInitial() {
        
        var observedStates = [SUT.State]()
        let field0 = makeAnywayPaymentField(id: "000")
        let initialState = makeSourceState(
            payment: makeAnywayPaymentContext(
                payment: makeAnywayPayment(fields: [field0])
            )
        )
        let (sut, source,_) = makeSUT(
            initialState: initialState,
            observe: { observedStates.append($0) }
        )
        
        let field = makeAnywayPaymentField(id: "123")
        let context = makeAnywayPaymentContext(
            payment: makeAnywayPayment(fields: [field])
        )
        source.send(.init(payment: context, isValid: false))
        
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.05) // why wait?
        XCTAssertEqual(observedStates.count, 1) // why 2?
        XCTAssertNotNil(sut)
        
        XCTAssertNoDiff(observedStates.map(\.payment.payment.models), [
            [.init(id: .fieldID("123"), model: .field(field))]
        ])
    }
    
    // MARK: - Helpers
    
    private typealias SUT = ObservingCachedPaymentViewModel<AnywayElement>
    private typealias Spy = ValueSpy<SUT.State>
    
    enum Event {
        
        case set(Int)
    }
    
    private func makeSUT(
        initialState: SUT.SourceState? = nil,
        observe: @escaping SUT.Observe = { _ in },
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        source: RxObservableObjectSpy,
        spy: Spy
    ) {
        let source = RxObservableObjectSpy(
            initialState: initialState ?? makeSourceState()
        )
        let sut = SUT(
            source: source,
            map: { $0 },
            observe: observe,
            scheduler: .immediate
        )
        let spy = ValueSpy(sut.$state)
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(source, file: file, line: line)
        trackForMemoryLeaks(spy, file: file, line: line)
        
        return (sut, source, spy)
    }
    
    private func makeSourceState(
        payment: AnywayPaymentContext = makeAnywayPaymentContext(),
        isValid: Bool = true,
        status: TransactionStatus<TransactionReport<DocumentStatus, OperationInfo<OperationDetailID, OperationDetails>>>? = nil
    ) -> SUT.SourceState {
        
        return .init(payment: payment, isValid: isValid, status: status)
    }
    
    private final class RxObservableObjectSpy: RxObservableObject {
        
        private(set) var events = [Event]()
        private let subject: CurrentValueSubject<State, Never>
        
        init(initialState: State) {
            
            self.subject = CurrentValueSubject<State, Never>(initialState)
        }
        
        var state: State { subject.value }
        var statePublisher: AnyPublisher<State, Never> {
            
            subject.eraseToAnyPublisher()
        }
        
        func event(_ event: Event) {
            
            self.events.append(event)
        }
        
        func send(_ state: State) {
            
            subject.send(state)
        }
        
        typealias State = SUT.SourceState
        typealias Event = SUT.Event
    }
}
