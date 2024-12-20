//
//  StateValueBinderTests.swift
//
//
//  Created by Igor Malyarov on 28.08.2024.
//

import Combine
import PayHub
import XCTest

final class StateValueBinderTests: XCTestCase {
    
    func test_init_shouldNotCallCollaborators() {
        
        let (sut, _, processSpy, receiveSpy) = makeSUT()
        
        XCTAssertEqual(processSpy.callCount, 0)
        XCTAssertEqual(receiveSpy.callCount, 0)
        XCTAssertNotNil(sut)
    }
    
    func test_shouldCallProcessWithStateOnStateEmission() {
        
        let state = makeState()
        let (sut, emitter, processSpy, _) = makeSUT()
        
        let cancellable = sut.bind()
        emitter.emit(state)
        
        XCTAssertNoDiff(processSpy.payloads, [state])
        XCTAssertNotNil(cancellable)
    }
    
    func test_shouldDeliverValueOnStateEmission() {
        
        let value = makeValue()
        let (sut, emitter, processSpy, receiveSpy) = makeSUT()
        
        let cancellable = sut.bind()
        emitter.emit(makeState())
        processSpy.complete(with: value)
        
        XCTAssertNoDiff(receiveSpy.payloads, [value])
        XCTAssertNotNil(cancellable)
    }
    
    // MARK: - Helpers
    
    private typealias SUT = StateValueBinder<State, Value>
    private typealias ProcessSpy = Spy<State, Value>
    private typealias ReceiveSpy = CallSpy<Value, Void>
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        emitter: Emitter,
        processSpy: ProcessSpy,
        receiveSpy: ReceiveSpy
    ) {
        let emitter = Emitter()
        let processSpy = ProcessSpy()
        let receiveSpy = ReceiveSpy()
        let sut = SUT(
            publisher: emitter.publisher,
            process: processSpy.process(_:completion:),
            receive: receiveSpy.call(payload:)
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(emitter, file: file, line: line)
        trackForMemoryLeaks(processSpy, file: file, line: line)
        trackForMemoryLeaks(receiveSpy, file: file, line: line)
        
        return (sut, emitter, processSpy, receiveSpy)
    }
    
    private struct State: Equatable {
        
        let value: String
    }
    
    private func makeState(
        _ value: String = anyMessage()
    ) -> State {
        
        return .init(value: value)
    }
    
    private struct Value: Equatable {
        
        let value: String
    }
    
    private func makeValue(
        _ value: String = anyMessage()
    ) -> Value {
        
        return .init(value: value)
    }
    
    private final class Emitter {
        
        private let subject = PassthroughSubject<State, Never>()
        
        var publisher: AnyPublisher<State, Never> {
            
            subject.eraseToAnyPublisher()
        }
        
        func emit(_ state: State) {
            
            subject.send(state)
        }
    }
}
