//
//  Services+makeFormSessionKeyServiceTests.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 08.11.2023.
//

import CVVPIN_Services
@testable import ForaBank
import XCTest

@available(iOS 16.0.0, *)
final class Services_makeFormSessionKeyServiceTests: XCTestCase {
    
    func test_init_shouldNotCallCollaborators() {
        
        let (_, handleSuccessSpy, sessionCodeLoader, processSpy) = makeSUT()
        
        XCTAssertEqual(handleSuccessSpy.callCount, 0)
        XCTAssertEqual(sessionCodeLoader.callCount, 0)
        XCTAssertEqual(processSpy.callCount, 0)
    }
    
    func test_init_shouldNotCacheOnLoadCodeFailure() {
        
        let (sut, handleSuccessSpy, sessionCodeLoader, _) = makeSUT()
        
        expectFailure(sut, on: {
            
            sessionCodeLoader.completeLoad(with: .failure(anyError()))
        })
        XCTAssertEqual(handleSuccessSpy.callCount, 0)
    }
    
    func test_init_shouldNotCacheOnMakeSecretRequestJSONFailure() {
        
        let (sut, handleSuccessSpy, sessionCodeLoader, _) = makeSUT(
            makeSecretRequestJSONResult: .failure(anyNSError())
        )
        
        expectFailure(sut, on: {
            
            sessionCodeLoader.completeLoad(with: anySuccess())
        })
        XCTAssertEqual(handleSuccessSpy.callCount, 0)
    }
    
    func test_init_shouldNotCacheOnProcessCreateRequestFailure() {
        
        let (sut, handleSuccessSpy, sessionCodeLoader, processSpy) = makeSUT()
        
        expectFailure(sut, on: {
            
            sessionCodeLoader.completeLoad(with: anySuccess())
            processSpy.complete(with: .failure(.createRequest(anyError())))
        })
        XCTAssertEqual(handleSuccessSpy.callCount, 0)
    }
    
    func test_init_shouldNotCacheOnProcessPerformRequestFailure() {
        
        let (sut, handleSuccessSpy, sessionCodeLoader, processSpy) = makeSUT()
        
        expectFailure(sut, on: {
            
            sessionCodeLoader.completeLoad(with: anySuccess())
            processSpy.complete(with: .failure(.performRequest(anyError())))
        })
        XCTAssertEqual(handleSuccessSpy.callCount, 0)
    }
    
    func test_init_shouldNotCacheOnProcessMapResponseInvalidFailure() {
        
        let (sut, handleSuccessSpy, sessionCodeLoader, processSpy) = makeSUT()
        
        expectFailure(sut, on: {
            
            sessionCodeLoader.completeLoad(with: anySuccess())
            processSpy.complete(with: .failure(.mapResponse(.invalid(statusCode: 500, data: anyData()))))
        })
        XCTAssertEqual(handleSuccessSpy.callCount, 0)
    }
    
    func test_init_shouldNotCacheOnProcessMapResponseNetworkFailure() {
        
        let (sut, handleSuccessSpy, sessionCodeLoader, processSpy) = makeSUT()
        
        expectFailure(sut, on: {
            
            sessionCodeLoader.completeLoad(with: anySuccess())
            processSpy.complete(with: .failure(.mapResponse(.network)))
        })
        XCTAssertEqual(handleSuccessSpy.callCount, 0)
    }
    
    func test_init_shouldNotCacheOnProcessMapResponseServerFailure() {
        
        let (sut, handleSuccessSpy, sessionCodeLoader, processSpy) = makeSUT()
        
        expectFailure(sut, on: {
            
            sessionCodeLoader.completeLoad(with: anySuccess())
            processSpy.complete(with: .failure(.mapResponse(.server(statusCode: 500, errorMessage: "Server Failure"))))
        })
        XCTAssertEqual(handleSuccessSpy.callCount, 0)
    }
    
    func test_init_shouldNotCacheOnMakeSessionKeyFailure() {
        
        let (sut, handleSuccessSpy, sessionCodeLoader, processSpy) = makeSUT(
            makeSessionKeyResult: .failure(anyError())
        )
        
        expectFailure(sut, on: {
            
            sessionCodeLoader.completeLoad(with: anySuccess())
            processSpy.complete(with: anySuccess())
        })
        XCTAssertEqual(handleSuccessSpy.callCount, 0)
    }
    
    func test_init_shouldCacheOnSuccess() {
        
        let (sut, handleSuccessSpy, sessionCodeLoader, processSpy) = makeSUT()
        
        expectSuccess(sut, on: {
            
            sessionCodeLoader.completeLoad(with: anySuccess())
            processSpy.complete(with: anySuccess())
        })
        XCTAssertEqual(handleSuccessSpy.callCount, 1)
    }
    
    // MARK: - Helpers
    
    private typealias SUT = Services.CachingFormSessionKeyService
    private typealias SessionCodeLoader = LoaderSpy<SessionCode>
    private typealias MakeSecretRequestJSONResult = FormSessionKeyService.SecretRequestJSONResult
    private typealias MakeSessionKeyResult = FormSessionKeyService.MakeSessionKeyResult
    private typealias ProcessSpy = ServiceSpy<Services.FormSessionKeyProcessResult, FormSessionKeyService.ProcessPayload>
    
    private func makeSUT(
        makeSecretRequestJSONResult: MakeSecretRequestJSONResult = anySuccess(),
        makeSessionKeyResult: MakeSessionKeyResult = anySuccess(),
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: any SUT,
        handleSuccessSpy: HandleSuccessSpy,
        sessionCodeLoader: SessionCodeLoader,
        processSpy: ProcessSpy
    ) {
        let sessionCodeLoader = SessionCodeLoader()
        let processSpy = ProcessSpy()
        let handleSuccessSpy = HandleSuccessSpy()
        let sut = Services.makeFormSessionKeyService(
            sessionCodeLoader: sessionCodeLoader,
            formSessionKeyProcess: processSpy.process,
            makeSecretRequestJSON: { $0(makeSecretRequestJSONResult) },
            makeSessionKey: { _, completion in completion(makeSessionKeyResult) },
            cacheFormSessionKeySuccess: handleSuccessSpy.handle
        )
        
        trackForMemoryLeaks(handleSuccessSpy, file: file, line: line)
        trackForMemoryLeaks(sessionCodeLoader, file: file, line: line)
        trackForMemoryLeaks(processSpy, file: file, line: line)
        
        return (sut, handleSuccessSpy, sessionCodeLoader, processSpy)
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
        typealias Message = (payload: Payload, completion: Completion)
        
        private var messages = [Message]()
        var callCount: Int { messages.count }
        
        func process(
            _ payload: Payload,
            completion: @escaping Completion
        ) {
            messages.append((payload, completion))
        }
        
        func complete(
            with result: T,
            at index: Int = 0
        ) {
            messages[index].completion(result)
        }
    }
    
    private final class HandleSuccessSpy {
        
        typealias Success = FormSessionKeyService.Success
        
        private(set) var successes = [Success]()
        
        var callCount: Int { successes.count }
        
        func handle(_ success: Success) {
            
            successes.append(success)
        }
    }
}

private func anySuccess(
    _ data: Data = anyData()
) -> FormSessionKeyService.SecretRequestJSONResult {
    
    .success(data)
}

private func anySuccess(
    _ sessionKeyValue: Data = anyData()
) -> FormSessionKeyService.MakeSessionKeyResult {
    
    .success(.init(sessionKeyValue: sessionKeyValue))
}

private func anySuccess(
    _ sessionCodeValue: String = UUID().uuidString
) -> Result<SessionCode, Error> {
    
    .success(.init(sessionCodeValue: sessionCodeValue))
}

private func anySuccess(
    publicServerSessionKey: String = UUID().uuidString,
    eventID: String = UUID().uuidString,
    sessionTTL: Int = 43
) -> Services.FormSessionKeyProcessResult {
    
    .success(.init(
        publicServerSessionKey: publicServerSessionKey,
        eventID: eventID,
        sessionTTL: sessionTTL
    ))
}
