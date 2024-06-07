//
//  CachedAnywayTransactionEffectHandlerTests.swift
//
//
//  Created by Igor Malyarov on 07.06.2024.
//

import AnywayPaymentCore
import AnywayPaymentDomain
import Combine

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
