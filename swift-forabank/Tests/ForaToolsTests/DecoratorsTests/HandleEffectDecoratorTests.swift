//
//  HandleEffectDecoratorTests.swift
//
//
//  Created by Igor Malyarov on 18.05.2024.
//

/// A decorator class that handles side effects in an event-driven system.
/// It allows you to add additional behavior before and after the main effect processing.
final class HandleEffectDecorator<Event, Effect> {
    
    private let decoratee: Decoratee
    private let decoration: Decoration
    
    /// Initialises a new `HandleEffectDecorator` with the given decoratee and decoration.
    ///
    /// - Parameters:
    ///   - decoratee: The effect handler function to be decorated.
    ///   - decoration: The decoration actions to be performed before and after the effect handling.
    init(
        decoratee: @escaping Decoratee,
        decoration: Decoration
    ) {
        self.decoratee = decoratee
        self.decoration = decoration
    }
}

extension HandleEffectDecorator {
    
    /// Handles an effect by invoking the decorated effect handler and dispatching the resulting event.
    /// The decoration actions are performed before and after the effect handling.
    ///
    /// - Parameters:
    ///   - effect: The effect to be handled.
    ///   - dispatch: The function to be called with the resulting event.
    ///
    /// - Note: This method uses a weak reference to `self` to avoid retain cycles. If the decorator instance is deallocated before the decorated function completes, the completion handler will not be called.
    func handleEffect(
        _ effect: Effect,
        _ dispatch: @escaping Dispatch
    ) {
        decoratee(effect) { [weak self] event in
            
            guard let self else { return }
            
            decoration.onEffectStart()
            dispatch(event)
            decoration.onEffectFinish()
        }
    }
    
    /// Strong reference
    func callAsFunction() {}
}

extension HandleEffectDecorator {
    
    /// A structure to define decoration actions to be performed before and after the effect handling.
    struct Decoration {
        
        /// Closure to be called before the effect handling starts.
        let onEffectStart: () -> Void
        /// Closure to be called after the effect handling finishes.
        let onEffectFinish: () -> Void
    }
    
    /// Type alias for the decorated effect handler function.
    typealias Decoratee = (Effect, @escaping Dispatch) -> Void
    /// Type alias for the dispatch function that handles events.
    typealias Dispatch = (Event) -> Void
}

import XCTest

final class HandleEffectDecoratorTests: XCTestCase {
    
    func test_init_shouldNotCallDecoratee() {
        
        let (_, decorateeSpy, decorationSpy) = makeSUT()
        
        XCTAssertEqual(decorateeSpy.callCount, 0)
        XCTAssertEqual(decorationSpy.callCount, 0)
    }
    
    func test_handleEffect_shouldCallDecorateeWithEffect() {
        
        let effect = makeEffect()
        let (sut, decorateeSpy, _) = makeSUT()
        
        sut.handleEffect(effect) { _ in }
        
        XCTAssertNoDiff(decorateeSpy.payloads, [effect])
    }
    
    func test_handleEffect_shouldDeliverDecorateeEvent() {
        
        let event = makeEvent()
        let (sut, decorateeSpy, _) = makeSUT()
        let exp = expectation(description: "wait for dispatch")
        var receivedEvent: Event?
        
        sut.handleEffect(makeEffect()) {
            
            receivedEvent = $0
            exp.fulfill()
        }
        
        decorateeSpy.complete(with: event)
        
        wait(for: [exp], timeout: 1.0)
        
        XCTAssertNoDiff(receivedEvent, event)
    }
    
    func test_handleEffect_shouldNotDeliverDecorateeEventOnInstanceDeallocation() {
        
        var sut: SUT?
        let decorateeSpy: DecorateeSpy
        (sut, decorateeSpy, _) = makeSUT()
        var receivedEvent: Event?
        
        sut?.handleEffect(makeEffect()) { receivedEvent = $0 }
        sut = nil
        decorateeSpy.complete(with: makeEvent())
        
        XCTAssertNil(receivedEvent)
    }
    
    func test_handleEffect_shouldDecorateDecorateeCompletion() {
        
        let (sut, decorateeSpy, decorationSpy) = makeSUT()
        
        sut.handleEffect(makeEffect()) { _ in decorationSpy.dispatchEvent() }
        decorateeSpy.complete(with: makeEvent())
        
        XCTAssertNoDiff(decorationSpy.messages, [.startEffect, .dispatchEvent, .finishEffect])
    }
    
    // MARK: - Helpers
    
    private typealias SUT = HandleEffectDecorator<Event, Effect>
    private typealias DecorateeSpy = Spy<Effect, Event>
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        decorateeSpy: DecorateeSpy,
        decorationSpy: DecorationSpy
    ) {
        let decorateeSpy = DecorateeSpy()
        let decorationSpy = DecorationSpy()
        let sut = SUT(
            decoratee: decorateeSpy.process(_:completion:),
            decoration: .init(
                onEffectStart: decorationSpy.startEffect,
                onEffectFinish: decorationSpy.finishEffect
            )
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(decorateeSpy, file: file, line: line)
        trackForMemoryLeaks(decorationSpy, file: file, line: line)
        
        return (sut, decorateeSpy, decorationSpy)
    }
    
    private struct Effect: Equatable {
        
        let value: String
    }
    
    private struct Event: Equatable {
        
        let value: String
    }
    
    private func makeEffect(
        value: String = UUID().uuidString
    ) -> Effect {
        
        .init(value: value)
    }
    
    private func makeEvent(
        value: String = UUID().uuidString
    ) -> Event {
        
        .init(value: value)
    }
    
    private final class DecorationSpy {
        
        private(set) var messages = [Message]()
        
        var callCount: Int { messages.count }
        
        func finishEffect() {
            
            messages.append(.finishEffect)
        }
        
        func dispatchEvent() {
            
            messages.append(.dispatchEvent)
        }
        
        func startEffect() {
            
            messages.append(.startEffect)
        }
        
        enum Message {
            
            case finishEffect
            case dispatchEvent
            case startEffect
        }
    }
}
