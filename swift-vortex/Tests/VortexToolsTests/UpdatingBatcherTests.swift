//
//  UpdatingBatcherTests.swift
//  
//
//  Created by Igor Malyarov on 17.01.2025.
//

import VortexTools
import XCTest

final class UpdatingBatcherTests: XCTestCase {
    
    // MARK: - init
    
    func test_init_shouldNotCallCollaborators() {
        
        let (sut, loader, update) = makeSUT()
        
        XCTAssertEqual(loader.callCount, 0)
        XCTAssertEqual(update.callCount, 0)
        XCTAssertNotNil(sut)
    }
    
    // MARK: - process
    
    func test_process_shouldNotCallLoaderOnEmpty() {
        
        let (sut, loader, _) = makeSUT()
        
        sut.process([]) { _ in }
        
        XCTAssertEqual(loader.callCount, 0)
    }
    
    func test_process_shouldNotCallUpdateOnEmpty() {
        
        let (sut, _, update) = makeSUT()
        
        sut.process([]) { _ in }
        
        XCTAssertEqual(update.callCount, 0)
    }
    
    func test_process_shouldDeliverEmptyOnEmpty() {
        
        let (sut, _,_) = makeSUT()
        
        expect(sut: sut, with: [], toDeliver: [])
    }
    
    func test_process_shouldDeliverSingleParameterOnFailure() {
        
        let parameter = makeParameter()
        let (sut, loader, _) = makeSUT()
        
        expect(sut: sut, with: [parameter], toDeliver: [parameter]) {
            
            loader.complete(with: nil)
        }
    }
    
    func test_process_shouldUpdateStateWithSingleParameterOnFailure() {
        
        let parameter = makeParameter()
        let (sut, loader, update) = makeSUT()
        
        expect(sut: sut, with: [parameter], toDeliver: [parameter]) {
            
            loader.complete(with: nil)
            
            XCTAssertNoDiff(update.payloads, [
                .init(parameter: parameter, state: .loading),
                .init(parameter: parameter, state: .failed)
            ])
        }
    }
    
    func test_process_shouldDeliverEmptyOnSingleEmptySuccess() {
        
        let (sut, loader, _) = makeSUT()
        
        expect(sut: sut, with: [makeParameter()], toDeliver: []) {
            
            loader.complete(with: [])
        }
    }
    
    func test_process_shouldUpdateStateOnSingleEmptySuccess() {
        
        let parameter = makeParameter()
        let (sut, loader, update) = makeSUT()
        
        expect(sut: sut, with: [parameter], toDeliver: []) {
            
            loader.complete(with: [])
            
            XCTAssertNoDiff(update.payloads, [
                .init(parameter: parameter, state: .loading),
                .init(parameter: parameter, state: .failed)
            ])
        }
    }
    
    func test_process_shouldDeliverEmptyOnSingleSuccessOfOne() {
        
        let (sut, loader, _) = makeSUT()
        
        expect(sut: sut, with: [makeParameter()], toDeliver: []) {
            
            loader.complete(with: [makeValue()])
        }
    }
    
    func test_process_shouldUpdateStateOnSingleSuccessOfOne() {
        
        let parameter = makeParameter()
        let (sut, loader, update) = makeSUT()
        
        expect(sut: sut, with: [parameter], toDeliver: []) {
            
            loader.complete(with: [makeValue()])
            
            XCTAssertNoDiff(update.payloads, [
                .init(parameter: parameter, state: .loading),
                .init(parameter: parameter, state: .completed)
            ])
        }
    }
    
    func test_process_shouldDeliverEmptyOnSingleSuccessOfTwo() {
        
        let (sut, loader, _) = makeSUT()
        
        expect(sut: sut, with: [makeParameter()], toDeliver: []) {
            
            loader.complete(with: [makeValue(), makeValue()])
        }
    }
    
    func test_process_shouldUpdateStateOnSingleSuccessOfTwo() {
        
        let parameter = makeParameter()
        let (sut, loader, update) = makeSUT()
        
        expect(sut: sut, with: [parameter], toDeliver: []) {
            
            loader.complete(with: [makeValue(), makeValue()])
            
            XCTAssertNoDiff(update.payloads, [
                .init(parameter: parameter, state: .loading),
                .init(parameter: parameter, state: .completed)
            ])
        }
    }
    
    func test_process_shouldDeliverFirstParameterOnFailure() {
        
        let parameter = makeParameter()
        let (sut, loader, _) = makeSUT()
        
        expect(sut: sut, with: [parameter, makeParameter()], toDeliver: [parameter]) {
            
            loader.complete(with: nil)
            loader.complete(with: [], at: 1)
        }
    }
    
    func test_process_shouldDeliverSecondParameterOnFailure() {
        
        let parameter = makeParameter()
        let (sut, loader, _) = makeSUT()
        
        expect(sut: sut, with: [makeParameter(), parameter], toDeliver: [parameter]) {
            
            loader.complete(with: [])
            loader.complete(with: nil, at: 1)
        }
    }
    
    func test_process_shouldUpdateStateWithFirstParameterOnFailure() {
        
        let first = makeParameter()
        let second = makeParameter()
        let (sut, loader, update) = makeSUT()
        
        expect(sut: sut, with: [first, second], toDeliver: [first]) {
            
            loader.complete(with: nil)
            loader.complete(with: [], at: 1)
            
            XCTAssertNoDiff(update.payloads, [
                .init(parameter: first, state: .loading),
                .init(parameter: second, state: .loading),
                .init(parameter: first, state: .failed),
                .init(parameter: second, state: .failed)
            ])
        }
    }
    
    func test_process_shouldUpdateStateWithFirstParameterOnFailure2() {
        
        let first = makeParameter()
        let second = makeParameter()
        let (sut, loader, update) = makeSUT()
        
        expect(sut: sut, with: [first, second], toDeliver: [first]) {
            
            loader.complete(with: nil)
            loader.complete(with: [makeValue()], at: 1)
            
            XCTAssertNoDiff(update.payloads, [
                .init(parameter: first, state: .loading),
                .init(parameter: second, state: .loading),
                .init(parameter: first, state: .failed),
                .init(parameter: second, state: .completed)
            ])
        }
    }
    
    func test_process_shouldUpdateStateWithSecondParameterOnFailure() {
        
        let first = makeParameter()
        let second = makeParameter()
        let (sut, loader, update) = makeSUT()
        
        expect(sut: sut, with: [first, second], toDeliver: [second]) {
            
            loader.complete(with: [makeValue()])
            loader.complete(with: nil, at: 1)
            
            XCTAssertNoDiff(update.payloads, [
                .init(parameter: first, state: .loading),
                .init(parameter: second, state: .loading),
                .init(parameter: first, state: .completed),
                .init(parameter: second, state: .failed)
            ])
        }
    }
    
    // MARK: - Helpers
    
    private typealias SUT = Batcher<Parameter>
    private typealias LoaderSpy = Spy<Parameter, [Value]?>
    private typealias UpdateSpy = CallSpy<Update, Void>
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        loader: LoaderSpy,
        update: UpdateSpy
    ) {
        let loader = LoaderSpy()
        let update = UpdateSpy(stubs: .init(repeating: (), count: 100))
        let sut = SUT.updating(
            load: loader.process(_:completion:),
            update: { update.call(payload: .init(parameter: $0, state: $1)) }
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(loader, file: file, line: line)
        trackForMemoryLeaks(update, file: file, line: line)
        
        return (sut, loader, update)
    }
    
    private struct Parameter: Equatable {
        
        let value: String
    }
    
    private func makeParameter(
        _ value: String = anyMessage()
    ) -> Parameter {
        
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
    
    private struct Update: Equatable {
        
        let parameter: Parameter
        let state: LoadState
    }
    
    private func expect(
        sut: SUT,
        with parameters: [Parameter],
        toDeliver expectedFailedParameters: [Parameter],
        on action: () -> Void = {},
        timeout: TimeInterval = 1.0,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let exp = expectation(description: "wait for process completion")
        
        sut.process(parameters) {
            
            XCTAssertNoDiff($0, expectedFailedParameters, "Expected \(expectedFailedParameters) failed parameters, but got \($0) instead.", file: file, line: line)
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: timeout)
    }
}
