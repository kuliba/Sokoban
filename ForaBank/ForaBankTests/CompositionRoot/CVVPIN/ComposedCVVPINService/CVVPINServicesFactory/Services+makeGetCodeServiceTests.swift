//
//  Services+makeGetCodeServiceTests.swift
//  VortexTests
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
    
    func test_init_shouldNotCacheOnProcessCreateRequestFailure() {
        
        let (sut, handleSuccessSpy, processSpy) = makeSUT()
        
        expectFailure(sut, on: {
            
            processSpy.complete(with: .failure(.createRequest(anyError())))
        })
        XCTAssertEqual(handleSuccessSpy.callCount, 0)
    }

    func test_init_shouldNotCacheOnProcessPerformRequestFailure() {
        
        let (sut, handleSuccessSpy, processSpy) = makeSUT()
        
        expectFailure(sut, on: {
            
            processSpy.complete(with: .failure(.performRequest(anyError())))
        })
        XCTAssertEqual(handleSuccessSpy.callCount, 0)
    }

    func test_init_shouldNotCacheOnProcessMapResponseInvalidFailure() {
        
        let (sut, handleSuccessSpy, processSpy) = makeSUT()
        
        expectFailure(sut, on: {
            
            processSpy.complete(with: .failure(.mapResponse(.invalid(statusCode: 500, data: anyData()))))
        })
        XCTAssertEqual(handleSuccessSpy.callCount, 0)
    }

    func test_init_shouldNotCacheOnProcessMapResponseNetworkFailure() {
        
        let (sut, handleSuccessSpy, processSpy) = makeSUT()
        
        expectFailure(sut, on: {
            
            processSpy.complete(with: .failure(.mapResponse(.network)))
        })
        XCTAssertEqual(handleSuccessSpy.callCount, 0)
    }

    func test_init_shouldNotCacheOnProcessMapResponseServerFailure() {
        
        let (sut, handleSuccessSpy, processSpy) = makeSUT()
        
        expectFailure(sut, on: {
            
            processSpy.complete(with: .failure(.mapResponse(.server(statusCode: 500, errorMessage: "Server Failure"))))
        })
        XCTAssertEqual(handleSuccessSpy.callCount, 0)
    }

    func test_init_shouldCacheOnSuccess() {

        let (sut, handleSuccessSpy, processSpy) = makeSUT()

        expectSuccess(sut, on: {

            processSpy.complete(with: .success(.init(code: UUID().uuidString, phone: UUID().uuidString)))
            handleSuccessSpy.complete(with: .success(()))
        })
        XCTAssertEqual(handleSuccessSpy.callCount, 1)
    }
    
    // MARK: - Helpers
    
    private typealias SUT = Services.GetCodeService
    private typealias ProcessSpy = Spy<Void, Services.ProcessGetCodeSuccess, Services.ProcessGetCodeError>
    private typealias HandleSuccessSpy = Spy<GetProcessingSessionCodeService.Response, Void, Error>
    
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
            processGetCode: processSpy.process(completion:),
            cacheGetProcessingSessionCode: handleSuccessSpy.process(_:completion:)
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
}
