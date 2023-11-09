//
//  Services+makeGetCodeServiceTests.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 08.11.2023.
//

import CVVPIN_Services
@testable import ForaBank
import XCTest

@available(iOS 16.0.0, *)
final class Services_makeGetCodeServiceTests: XCTestCase {
    
    func test_init_shouldNotCallCollaborators() {
        
        let (_, handleSuccessSpy, processSpy) = makeSUT()
        
        XCTAssertEqual(handleSuccessSpy.callCount, 0)
        XCTAssertEqual(processSpy.callCount, 0)
    }
    
    func test_init_shouldNotCacheOnProcessFailure() {
        
        let (sut, handleSuccessSpy, processSpy) = makeSUT()
        
        expectFailure(sut, on: {
            
            processSpy.complete(with: .failure(.createRequest(anyError())))
        })
        XCTAssertEqual(handleSuccessSpy.callCount, 0)
    }

    func test_init_shouldCacheOnSuccess() {

        let (sut, handleSuccessSpy, processSpy) = makeSUT()

        expectSuccess(sut, on: {

            processSpy.complete(with: .success(.init(code: UUID().uuidString, phone: UUID().uuidString)))
        })
        XCTAssertEqual(handleSuccessSpy.callCount, 1)
    }
    
    // MARK: - Helpers
    
    private typealias SUT = Services.GetCodeService
    private typealias ProcessResult = Result<GetProcessingSessionCodeService.Response, MappingRemoteServiceError<GetProcessingSessionCodeService.APIError>>
    private typealias ProcessSpy = ServiceSpy<ProcessResult, Void>
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: any SUT,
        handleSuccessSpy: HandleSuccessSpy,
        processSpy: ProcessSpy
    ) {
        let processSpy = ProcessSpy()
        let handleSuccessSpy = HandleSuccessSpy()
        let sut = Services.makeGetCodeService(
            getCodeServiceProcess: processSpy.process,
            cacheGetProcessingSessionCode: handleSuccessSpy.handle
        )
        
        trackForMemoryLeaks(handleSuccessSpy, file: file, line: line)
        trackForMemoryLeaks(processSpy, file: file, line: line)
        
        return (sut, handleSuccessSpy, processSpy)
    }
    
    private func expectSuccess(
        _ sut: any SUT,
        on action: @escaping () -> Void,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let exp = expectation(description: "wait for completion")
        
        sut.fetch { receivedResult in
            
            switch receivedResult {
            case .failure:
                XCTFail("Expected success, but got failure.", file: file, line: line)
                
            case .success:
                break
            }
            
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 1.0)
    }
    
    private func expectFailure(
        _ sut: any SUT,
        on action: @escaping () -> Void,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let exp = expectation(description: "wait for completion")
        
        sut.fetch { receivedResult in
            
            switch receivedResult {
            case .failure:
                break
                
            case .success:
                XCTFail("Expected failure, but got success.", file: file, line: line)
            }
            
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 1.0)
    }
    
    final class ServiceSpy<T, Payload> {
        
        typealias Completion = (T) -> Void
        
        private var completions = [Completion]()
        var callCount: Int { completions.count }
        
        func process(
            completion: @escaping Completion
        ) {
            completions.append(completion)
        }
        
        func complete(
            with result: T,
            at index: Int = 0
        ) {
            completions[index](result)
        }
    }
    
    private final class HandleSuccessSpy {
        
        typealias Success = GetProcessingSessionCodeService.Response
        
        private(set) var successes = [Success]()
        
        var callCount: Int { successes.count }
        
        func handle(_ success: Success) {
            
            successes.append(success)
        }
    }
}
