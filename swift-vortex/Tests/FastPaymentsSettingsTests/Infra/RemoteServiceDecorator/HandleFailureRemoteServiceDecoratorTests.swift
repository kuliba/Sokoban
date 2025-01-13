//
//  HandleFailureRemoteServiceDecoratorTests.swift
//
//
//  Created by Igor Malyarov on 10.01.2024.
//

import FastPaymentsSettings
import XCTest

final class HandleFailureRemoteServiceDecoratorTests: XCTestCase {
    
    func test_init_shouldNotCallCollaborator() {
        
        let (_, decoratorSpy, handleFailureSpy) = makeSUT()
        
        XCTAssertNoDiff(decoratorSpy.callCount, 0)
        XCTAssertNoDiff(handleFailureSpy.callCount, 0)
    }
    
    func test_process_shouldPassInputToDecoratee() {
        
        let input = makeInput()
        let (sut, spy, _) = makeSUT()
        
        sut.process(input) { _ in }
        
        XCTAssertNoDiff(spy.payloads, [input])
    }
    
    func test_process_shouldCompleteWithDecorateeFailure() {
        
        let failure = SUT.ProcessError()
        let (sut, spy, handleFailureSpy) = makeSUT()
        
        expect(sut, toDeliver: .failure(failure), on: {
            
            spy.complete(with: .failure(failure))
            handleFailureSpy.complete()
        })
    }
    
    func test_process_shouldCompleteWithDecorateeSuccess() {
        
        let success = SUT.Output()
        let (sut, spy, _) = makeSUT()
        
        expect(sut, toDeliver: .success(success), on: {
            
            spy.complete(with: .success(success))
        })
    }
    
    func test_process_shouldDecorateDecorateeFailure() {
        
        let failure = SUT.ProcessError()
        let (sut, decoratorSpy, handleFailureSpy) = makeSUT()
        
        sut.process(makeInput()) { _ in }
        decoratorSpy.complete(with: .failure(failure))
        
        XCTAssertNoDiff(handleFailureSpy.values, [failure])
    }
    
    func test_process_shouldNotDecorateDecorateeSuccess() {
        
        let success = SUT.Output()
        let (sut, decoratorSpy, handleFailureSpy) = makeSUT()
        
        sut.process(makeInput()) { _ in }
        decoratorSpy.complete(with: .success(success))
        
        XCTAssertNoDiff(handleFailureSpy.values, [])
    }
    
    // MARK: - Helpers
    
    private typealias SUT = RemoteServiceDecorator<Input, Response, ProcessError>
    private typealias Input = UUID
    private typealias Result = Swift.Result<SUT.Output, SUT.ProcessError>
    private typealias DecoratorSpy = SpyOf<Input, Response, ProcessError>
    private typealias HandleFailureSpy = _DecorationSpy<ProcessError>
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        decoratorSpy: DecoratorSpy,
        handleFailureSpy: HandleFailureSpy
    ) {
        let decoratorSpy = DecoratorSpy()
        let handleFailureSpy = HandleFailureSpy()
        let sut = SUT(
            decoratee: SpyAdapter(spy: decoratorSpy),
            handleFailure: handleFailureSpy.process
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(decoratorSpy, file: file, line: line)
        trackForMemoryLeaks(handleFailureSpy, file: file, line: line)
        
        return (sut, decoratorSpy, handleFailureSpy)
    }
    
    private func expect(
        _ sut: SUT,
        with payload: Input = makeInput(),
        toDeliver expectedResult: Result,
        on action: @escaping () -> Void,
        timeout: TimeInterval = 0.05,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let exp = expectation(description: "wait for completion")
        
        sut.process(makeInput()) {
            
            assert($0, equals: expectedResult, file: file, line: line)
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: timeout)
    }
    
    private struct Response: Equatable {
        
        let value: String
        
        init(value: String = UUID().uuidString) {
            
            self.value = value
        }
    }
    
    private struct ProcessError: Error, Equatable {
        
        let value: UUID
        
        init(value: UUID = .init()) {
            
            self.value = value
        }
    }
    
    private final class _DecorationSpy<Value> {
        
        private(set) var messages = [Message]()
        
        var values: [Value] { messages.map(\.value) }
        var callCount: Int { messages.count }
        
        func process(
            _ value: Value,
            _ completion: @escaping () -> Void
        ) {
            messages.append((value, completion))
        }
        
        func complete(at index: Int = 0) {
            
            messages[index].completion()
        }
        
        typealias Message = (value: Value, completion: () -> Void)
    }
}

private func makeInput(
    _ value: UUID = .init()
) -> UUID {
    
    value
}
