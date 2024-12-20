//
//  BindPublicKeyWithEventIDServiceTests.swift
//  
//
//  Created by Igor Malyarov on 04.11.2023.
//

import CVVPIN_Services
import XCTest

final class BindPublicKeyWithEventIDServiceTests: XCTestCase {
    
    func test_init_shouldNotCallCollaborators() {
        
        let (_, loadEventIDSpy, makeSecretJSONSpy, processSpy) = makeSUT()
        
        XCTAssertNoDiff(loadEventIDSpy.callCount, 0)
        XCTAssertNoDiff(makeSecretJSONSpy.callCount, 0)
        XCTAssertNoDiff(processSpy.callCount, 0)
    }
    
    func test_bind_shouldDeliverErrorOnLoadEventIDFailure() {
        
        let (sut, loadEventIDSpy, _, _) = makeSUT()
        
        expect(sut, toDeliver: [.failure(.serviceError(.missingEventID))], on: {
            
            loadEventIDSpy.complete(with: .failure(anyError()))
        })
    }
    
    func test_bind_shouldDeliverErrorOnMakeSecretJSONFailure() {
        
        let (sut, loadEventIDSpy, makeSecretJSONSpy, _) = makeSUT()
        
        expect(sut, toDeliver: [.failure(.serviceError(.makeJSONFailure))], on: {
            
            loadEventIDSpy.complete(with: anySuccess())
            makeSecretJSONSpy.complete(with: .failure(anyError()))
        })
    }
    
    func test_bind_shouldDeliverErrorOnProcessInvalidFailure() {
        
        let statusCode = 500
        let invalidData = anyData()
        let (sut, loadEventIDSpy, makeSecretJSONSpy, processSpy) = makeSUT()
        
        expect(sut, toDeliver: [
            .failure(.invalid(statusCode: statusCode, data: invalidData))
        ], on: {
            loadEventIDSpy.complete(with: anySuccess())
            makeSecretJSONSpy.complete(with: anySuccess())
            processSpy.complete(with: .failure(.invalid(statusCode: statusCode, data: invalidData)))
        })
    }
    
    func test_bind_shouldDeliverErrorOnProcessNetworkFailure() {
        
        let (sut, loadEventIDSpy, makeSecretJSONSpy, processSpy) = makeSUT()
        
        expect(sut, toDeliver: [.failure(.network)], on: {
            
            loadEventIDSpy.complete(with: anySuccess())
            makeSecretJSONSpy.complete(with: anySuccess())
            processSpy.complete(with: .failure(.network))
        })
    }
    
    func test_bind_shouldDeliverErrorOnProcessRetryFailure() {
        
        let statusCode = 500
        let errorMessage = "With Retry Failure"
        let retryAttempts = 5
        let (sut, loadEventIDSpy, makeSecretJSONSpy, processSpy) = makeSUT()
        
        expect(sut, toDeliver: [
            .failure(.retry(statusCode: statusCode, errorMessage: errorMessage, retryAttempts: retryAttempts))
        ], on: {
            loadEventIDSpy.complete(with: anySuccess())
            makeSecretJSONSpy.complete(with: anySuccess())
            processSpy.complete(with: .failure(.retry(statusCode: statusCode, errorMessage: errorMessage, retryAttempts: retryAttempts)))
        })
    }
    
    func test_bind_shouldDeliverErrorOnProcessServerFailure() {
        
        let statusCode = 500
        let errorMessage = "With Retry Failure"
        let (sut, loadEventIDSpy, makeSecretJSONSpy, processSpy) = makeSUT()
        
        expect(sut, toDeliver: [
            .failure(.server(statusCode: statusCode, errorMessage: errorMessage))
        ], on: {
            loadEventIDSpy.complete(with: anySuccess())
            makeSecretJSONSpy.complete(with: anySuccess())
            processSpy.complete(with: .failure(.server(statusCode: statusCode, errorMessage: errorMessage)))
        })
    }
    
    func test_bind_shouldDeliverVoidOnSuccess() {
        
        let (sut, loadEventIDSpy, makeSecretJSONSpy, processSpy) = makeSUT()
        
        expect(sut, toDeliver: [.success(())], on: {
            
            loadEventIDSpy.complete(with: anySuccess())
            makeSecretJSONSpy.complete(with: anySuccess())
            processSpy.complete(with: anySuccess())
        })
    }
    
    func test_bind_shouldNotDeliverLoadIDResultOnInstanceDeallocation() {
        
        var sut: SUT?
        let loadEventIDSpy: LoadEventIDSpy
        (sut, loadEventIDSpy, _, _) = makeSUT()
        var receivedResults = [SUT.Result]()
        
        sut?.bind(with: anyOTP()) { receivedResults.append($0) }
        sut = nil
        loadEventIDSpy.complete(with: anySuccess())
        
        XCTAssert(receivedResults.isEmpty)
    }
    
    func test_bind_shouldNotDeliverMakeSecretJSONResultOnInstanceDeallocation() {
        
        var sut: SUT?
        let loadEventIDSpy: LoadEventIDSpy
        let makeSecretJSONSpy: MakeSecretJSONSpy
        (sut, loadEventIDSpy, makeSecretJSONSpy, _) = makeSUT()
        var receivedResults = [SUT.Result]()
        
        sut?.bind(with: anyOTP()) { receivedResults.append($0) }
        loadEventIDSpy.complete(with: anySuccess())
        sut = nil
        makeSecretJSONSpy.complete(with: anySuccess())
        
        XCTAssert(receivedResults.isEmpty)
    }
    
    func test_bind_shouldNotDeliverProcessResultOnInstanceDeallocation() {
        
        var sut: SUT?
        let loadEventIDSpy: LoadEventIDSpy
        let makeSecretJSONSpy: MakeSecretJSONSpy
        let processSpy: ProcessSpy
        (sut, loadEventIDSpy, makeSecretJSONSpy, processSpy) = makeSUT()
        var receivedResults = [SUT.Result]()
        
        sut?.bind(with: anyOTP()) { receivedResults.append($0) }
        loadEventIDSpy.complete(with: anySuccess())
        makeSecretJSONSpy.complete(with: anySuccess())
        sut = nil
        processSpy.complete(with: anySuccess())
        
        XCTAssert(receivedResults.isEmpty)
    }
    
    // MARK: - Helper
    
    private typealias SUT = BindPublicKeyWithEventIDService
    private typealias LoadEventIDSpy = Spy<Void, SUT.EventID, Error>
    private typealias MakeSecretJSONSpy = Spy<SUT.OTP, Data, Error>
    private typealias ProcessSpy = Spy<SUT.ProcessPayload, Void, SUT.APIError>
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        loadEventIDSpy: LoadEventIDSpy,
        makeSecretJSONSpy: MakeSecretJSONSpy,
        processSpy: ProcessSpy
    ) {
        let loadEventIDSpy = LoadEventIDSpy()
        let makeSecretJSONSpy = MakeSecretJSONSpy()
        let processSpy = ProcessSpy()
        let sut = SUT(
            loadEventID: loadEventIDSpy.process(completion:),
            makeSecretJSON: makeSecretJSONSpy.process(_:completion:),
            process: processSpy.process(_:completion:)
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return (sut, loadEventIDSpy, makeSecretJSONSpy, processSpy)
    }
    
    private func expect(
        _ sut: SUT,
        toDeliver expectedResults: [SUT.Result],
        on action: @escaping () -> Void,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        var receivedResults = [SUT.Result]()
        let exp = expectation(description: "wait for completion")
        
        sut.bind(with: anyOTP()) {
            
            receivedResults.append($0)
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 1.0)
        
        assert(
            receivedResults.mapToEquatable(),
            equals: expectedResults.mapToEquatable(),
            file: file, line: line
        )
    }
}

private func anyOTP(
    otpValue: String = .init(UUID().uuidString.prefix(6))
) -> BindPublicKeyWithEventIDService.OTP {
    
    .init(otpValue: otpValue)
}

private extension Array where Element == BindPublicKeyWithEventIDService.Result {
    
    func mapToEquatable() -> [BindPublicKeyWithEventIDService.Result.EquatableResult] {
        
        map { $0.mapToEquatable() }
    }
}

private extension BindPublicKeyWithEventIDService.Result {
    
    func mapToEquatable() -> EquatableResult {
        
        self
            .map(EquatableVoid.init)
            .mapError(EquatableError.init)
    }
    
    typealias EquatableResult = Result<EquatableVoid, EquatableError>
    
    struct EquatableVoid: Equatable {
        
        init(_ void: Void) {}
    }
    
    enum EquatableError: Error & Equatable {
        
        case invalid(statusCode: Int, data: Data)
        case network
        case retry(statusCode: Int, errorMessage: String, retryAttempts: Int)
        case server(statusCode: Int, errorMessage: String)
        case serviceError(ServiceError)
        
        init(error: BindPublicKeyWithEventIDService.Error) {
            
            switch error {
            case let .invalid(statusCode: statusCode, data: data):
                self = .invalid(statusCode: statusCode, data: data)
                
            case .network:
                self = .network
                
            case let .retry(statusCode: statusCode, errorMessage: errorMessage, retryAttempts: retryAttempts):
                self = .retry(statusCode: statusCode, errorMessage: errorMessage, retryAttempts: retryAttempts)
                
            case let .server(statusCode: statusCode, errorMessage: errorMessage):
                self = .server(statusCode: statusCode, errorMessage: errorMessage)
                
            case let .serviceError(serviceError):
                switch serviceError {
                case .makeJSONFailure:
                    self = .serviceError(.makeJSONFailure)
                    
                case .missingEventID:
                    self = .serviceError(.missingEventID)
                }
            }
        }
        
        public enum ServiceError {
            
            case makeJSONFailure
            case missingEventID
        }
    }
}

private func anySuccess(
    eventIDValue: String = UUID().uuidString
) -> BindPublicKeyWithEventIDService.EventIDResult {
    
    .success(.init(eventIDValue: eventIDValue))
}

private func anySuccess(
    bitCount: Int = 256
) -> BindPublicKeyWithEventIDService.SecretJSONResult {
    
    .success(anyData(bitCount: bitCount))
}

private func anySuccess(
) -> BindPublicKeyWithEventIDService.ProcessResult {
    
    .success(())
}
