//
//  Publisher+runOnceOnNonNilValueTests.swift
//  
//
//  Created by Igor Malyarov on 11.10.2024.
//

import Combine
import ForaTools
import XCTest

final class Publisher_runOnceOnNonNilValueTests: XCTestCase {
    
    func test_shouldNotPerformWorkOnEmittedNil() {
        
        let (subject, exp, cancellable) = makeSUT(isInverted: true)
        
        subject.send(nil)
        
        wait(for: exp, with: cancellable)
    }
    
    func test_shouldNotPerformWorkOnRepeatedNil() {
        
        let (subject, exp, cancellable) = makeSUT(isInverted: true)
        
        subject.send(nil)
        subject.send(nil)
        
        wait(for: exp, with: cancellable)
    }
    
    func test_shouldPerformWorkOnEmittedValue() {
        
        let (subject, exp, cancellable) = makeSUT()
        
        subject.send(makeValue())
        
        wait(for: exp, with: cancellable)
    }
    
    func test_shouldPerformWorkOnceOnEmittedValues() {
        
        let (subject, exp, cancellable) = makeSUT()
        
        subject.send(makeValue())
        subject.send(makeValue())
        
        wait(for: exp, with: cancellable)
    }
    
    func test_shouldPerformWorkOnceOnMixedEmitted() {
        
        let (subject, exp, cancellable) = makeSUT()
        
        subject.send(makeValue())
        subject.send(nil)
        subject.send(makeValue())
        
        wait(for: exp, with: cancellable)
    }
    
    func test_shouldPerformWorkOnceOnDelayedEmission() {
        
        let (subject, exp, cancellable) = makeSUT()
        
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.5) {
         
            subject.send(self.makeValue())
            subject.send(nil)
            subject.send(self.makeValue())
        }
        
        wait(for: exp, with: cancellable, timeout: 1)
    }
    
    func test_shouldNotPerformWorkOnCancelation() {
        
        let (subject, exp, cancellable) = makeSUT(isInverted: true)
        
        cancellable.cancel()
        subject.send(nil)
        
        wait(for: exp, with: cancellable)
    }
    
    func test_shouldNotPerformWorkOnCompletion() {
        
        let (subject, exp, cancellable) = makeSUT(isInverted: true)
        
        subject.send(completion: .finished)
        
        wait(for: exp, with: cancellable)
    }
    
    // MARK: - Helpers
    
    private typealias Subject = PassthroughSubject<Value?, Never>
    
    private func makeSUT(
        isInverted: Bool = false,
        file: StaticString = #file,
        line: UInt = #line
    ) -> (Subject, XCTestExpectation, AnyCancellable) {
        
        let subject = Subject()
        let exp = expectation(description: "wait for work")
        exp.isInverted = isInverted
        let cancellable = subject.runOnceOnNonNilValue(exp.fulfill)
        
        trackForMemoryLeaks(subject, file: file, line: line)
        trackForMemoryLeaks(cancellable, file: file, line: line)
        
        return (subject, exp, cancellable)
    }
    
    private struct Value: Equatable {
        
        let value: String
    }
    
    private func makeValue(
        _ value: String = anyMessage()
    ) -> Value {
        
        return .init(value: value)
    }
    
    private func wait(
        for exp: XCTestExpectation,
        with cancellable: AnyCancellable,
        timeout: TimeInterval = 0.5,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        wait(for: [exp], timeout: timeout)
        XCTAssertNotNil(cancellable, file: file, line: line)
    }
}
