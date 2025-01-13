//
//  BatcherTests.swift
//
//
//  Created by Igor Malyarov on 21.08.2024.
//

import VortexTools
import XCTest

final class BatcherTests: XCTestCase {
    
    // MARK: - init
    
    func test_init_shouldNotCallCollaborator() {
        
        let (sut, spy) = makeSUT()
        
        XCTAssertEqual(spy.callCount, 0)
        XCTAssertNotNil(sut)
    }
    
    // MARK: - process
    
    func test_process_shouldDeliverEmptyOnEmpty() {
        
        let sut = makeSUT().sut
        
        expect(sut, with: [], toDeliver: [], on: {})
    }
    
    func test_process_shouldNotDeliverResultOnInstanceDeallocation() {
        
        var sut: SUT?
        let spy: PerformSpy
        (sut, spy) = makeSUT()
        let exp = expectation(description: "wait for completion")
        exp.isInverted = true
        
        sut?.process([makeParameter()]) { _ in exp.fulfill() }
        sut = nil
        spy.complete(with: anyError())
        
        wait(for: [exp], timeout: 0.1)
    }
    
    func test_process_shouldDeliverEmptyOnSuccessWithOneParameter() {
        
        let parameter = makeParameter()
        let (sut, spy) = makeSUT()
        
        expect(sut, with: [parameter], toDeliver: []) {
            
            spy.complete(with: nil)
        }
    }
    
    func test_process_shouldDeliverParameterOnFailureWithOneParameter() {
        
        let parameter = makeParameter()
        let (sut, spy) = makeSUT()
        
        expect(sut, with: [parameter], toDeliver: [parameter]) {
            
            spy.complete(with: anyError())
        }
    }
    
    func test_process_shouldDeliverEmptyOnBothSuccess() {
        
        let (parameter1, parameter2) = (makeParameter(), makeParameter())
        let (sut, spy) = makeSUT()
        
        expect(sut, with: [parameter1, parameter2], toDeliver: []) {
            
            spy.complete(with: nil, at: 0)
            spy.complete(with: nil, at: 1)
        }
    }
    
    func test_process_shouldDeliverFirstParameterOnSecondSuccess() {
        
        let (parameter1, parameter2) = (makeParameter(), makeParameter())
        let (sut, spy) = makeSUT()
        
        expect(sut, with: [parameter1, parameter2], toDeliver: [parameter1]) {
            
            spy.complete(with: anyError(), at: 0)
            spy.complete(with: nil, at: 1)
        }
    }
    
    func test_process_shouldDeliverSecondParameterOnFirstSuccess() {
        
        let (parameter1, parameter2) = (makeParameter(), makeParameter())
        let (sut, spy) = makeSUT()
        
        expect(sut, with: [parameter1, parameter2], toDeliver: [parameter2]) {
            
            spy.complete(with: nil, at: 0)
            spy.complete(with: anyError(), at: 1)
        }
    }
    
    func test_process_shouldDeliverBothParametersOnBothFailure() {
        
        let (parameter1, parameter2) = (makeParameter(), makeParameter())
        let (sut, spy) = makeSUT()
        
        expect(sut, with: [parameter1, parameter2], toDeliver: [parameter1, parameter2]) {
            
            spy.complete(with: anyError(), at: 0)
            spy.complete(with: anyError(), at: 1)
        }
    }
    
    // MARK: - Helpers
    
    private typealias Parameter = Int
    private typealias SUT = Batcher<Parameter>
    private typealias PerformSpy = Spy<Parameter, Error?>
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        spy: PerformSpy
    ) {
        let spy = PerformSpy()
        let sut = SUT(perform: spy.process(_:completion:))
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(spy, file: file, line: line)
        
        return (sut, spy)
    }
    
    private func makeParameter(
        _ value: Int = .random(in: 1...1_000)
    ) -> Parameter {
        
        return value
    }
    
    private func expect(
        _ sut: SUT,
        with parameters: [Parameter],
        toDeliver expectedResult: [Parameter],
        on action: () -> Void,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let exp = expectation(description: "wait for completion")
        
        sut.process(parameters) {
            
            XCTAssertNoDiff($0, expectedResult, "Expected \(expectedResult), but got \($0) instead.", file: file, line: line)
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 1)
    }
}
