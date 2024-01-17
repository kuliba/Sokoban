//
//  RemoteServiceAdapterTests.swift
//
//
//  Created by Igor Malyarov on 10.01.2024.
//

import FastPaymentsSettings
import XCTest

final class RemoteServiceAdapterTests: XCTestCase {
    
    func test_init_shouldNotCallCollaborators() {
        
        let (_, serviceSpy) = makeSUT()
        
        XCTAssertNoDiff(serviceSpy.callCount, 0)
    }
    
    func test_process_shouldPassInputToService() {
        
        let input = makeInput()
        let (sut, serviceSpy) = makeSUT()
        
        sut.process(input) { _ in }
        
        XCTAssertNoDiff(serviceSpy.payloads, [input])
    }
    
    func test_process_shouldDeliverFailureOnServiceFailure() {
        
        let failure = ProcessError()
        let (sut, serviceSpy) = makeSUT()
        
        expect(sut, toDeliver: .failure(failure), on: {
            
            serviceSpy.complete(with: .failure(failure))
        })
    }
    
    func test_process_shouldDeliverAdaptedSuccessOnServiceSuccess() {
        
        let success = UUID()
        let (sut, serviceSpy) = makeSUT(output: success.uuidString)
        
        expect(sut, toDeliver: .success(success.uuidString), on: {
            
            serviceSpy.complete(with: .success(success))
        })
    }
    
    // MARK: - Helpers
    
    private typealias Input = UUID
    private typealias OldOutput = UUID
    private typealias Output = String
    private typealias SUT = RemoteServiceAdapter<Input, OldOutput, Output, ProcessError>
    private typealias ServiceSpy = SpyOf<Input, OldOutput, ProcessError>
    
    private func makeSUT(
        output: Output = UUID().uuidString,
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        serviceSpy: ServiceSpy
    ) {
        let serviceSpy = ServiceSpy()
        let sut = SUT(
            service: SpyAdapter(spy: serviceSpy),
            adapt: { _ in output }
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(serviceSpy, file: file, line: line)
        
        return (sut, serviceSpy)
    }
    
    private func expect(
        _ sut: SUT,
        with input: Input = makeInput(),
        toDeliver expectedResult: SUT.ProcessResult,
        on action: @escaping () -> Void,
        timeout: TimeInterval = 0.05,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let exp = expectation(description: "wait for completion")
        
        sut.process(input) {
            
            assert($0, equals: expectedResult, file: file, line: line)
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: timeout)
    }
    
    private struct ProcessError: Error, Equatable {
        
        let value: UUID
        
        init(value: UUID = .init()) {
            
            self.value = value
        }
    }
}

private func makeInput(
    _ value: UUID = .init()
) -> UUID {
    
    value
}
