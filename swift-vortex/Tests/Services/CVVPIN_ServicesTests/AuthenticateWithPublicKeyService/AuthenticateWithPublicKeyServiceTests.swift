//
//  AuthenticateWithPublicKeyServiceTests.swift
//  
//
//  Created by Igor Malyarov on 03.11.2023.
//

import CVVPIN_Services
import XCTest

final class AuthenticateWithPublicKeyServiceTests: XCTestCase {
    
    func test_init_shouldNotMessageCollaborators() {
        
        let (_, prepareKeyExchangeSpy, processSpy, makeSessionKeySpy) = makeSUT()
        
        XCTAssertEqual(prepareKeyExchangeSpy.callCount, 0)
        XCTAssertEqual(processSpy.callCount, 0)
        XCTAssertEqual(makeSessionKeySpy.callCount, 0)
    }
    
    func test_authenticateWithPublicKey_shouldDeliverErrorOnPrepareKeyExchangeFailure() {
        
        let (sut, prepareKeyExchangeSpy, _, _) = makeSUT()
        
        expect(sut, toDeliver: [
            .failure(.serviceError(.prepareKeyExchangeFailure))
        ], on: {
            prepareKeyExchangeSpy.complete(with: .failure(anyError()))
        })
    }
    
    func test_authenticateWithPublicKey_shouldDeliverErrorOnProcessInvalidFailure() {
        
        let statusCode = 500
        let invalidData = anyData()
        let (sut, prepareKeyExchangeSpy, processSpy, _) = makeSUT()
        
        expect(sut, toDeliver: [
            .failure(.invalid(statusCode: statusCode, data: invalidData))
        ], on: {
            prepareKeyExchangeSpy.complete(with: .success(anyData()))
            processSpy.complete(with: .failure(.invalid(statusCode: statusCode, data: invalidData)))
        })
    }
    
    func test_authenticateWithPublicKey_shouldDeliverErrorOnProcessNetworkFailure() {
        
        let (sut, prepareKeyExchangeSpy, processSpy, _) = makeSUT()
        
        expect(sut, toDeliver: [.failure(.network)], on: {
            
            prepareKeyExchangeSpy.complete(with: .success(anyData()))
            processSpy.complete(with: .failure(.network))
        })
    }
    
    func test_authenticateWithPublicKey_shouldDeliverErrorOnProcessServerFailure() {
        
        let statusCode = 500
        let errorMessage = "Process Failure"
        let (sut, prepareKeyExchangeSpy, processSpy, _) = makeSUT()
        
        expect(sut, toDeliver: [
            .failure(.server(statusCode: statusCode, errorMessage: errorMessage))
        ], on: {
            prepareKeyExchangeSpy.complete(with: .success(anyData()))
            processSpy.complete(with: .failure(.server(statusCode: statusCode, errorMessage: errorMessage)))
        })
    }
    
    func test_authenticateWithPublicKey_shouldDeliverErrorOnMakeSessionKeyFailure() {
        
        let (sut, prepareKeyExchangeSpy, processSpy, makeSessionKeySpy) = makeSUT()
        
        expect(sut, toDeliver: [
            .failure(.serviceError(.makeSessionKeyFailure))
        ], on: {
            prepareKeyExchangeSpy.complete(with: .success(anyData()))
            processSpy.complete(with: anySuccess())
            makeSessionKeySpy.complete(with: .failure(anyError()))
        })
    }
    
    func test_authenticateWithPublicKey_shouldDeliverSuccessOnSuccess() {
        
        let sessionID: String = UUID().uuidString
        let publicServerSessionKey: String = UUID().uuidString
        let sessionTTL = 5
        let keyData = anyData()
        let processResult: SUT.ProcessResult = .success(makeResponse(
            sessionID: sessionID,
            publicServerSessionKey: publicServerSessionKey,
            sessionTTL: sessionTTL
        ))
        let (sut, prepareKeyExchangeSpy, processSpy, makeSessionKeySpy) = makeSUT()
        
        expect(sut, toDeliver: [
            .success(makeSuccess(
                sessionIDValue: sessionID,
                sessionKeyValue: keyData,
                sessionTTL: sessionTTL
            ))
        ], on: {
            prepareKeyExchangeSpy.complete(with: anySuccess())
            processSpy.complete(with: processResult)
            makeSessionKeySpy.complete(with: .success(.init(sessionKeyValue: keyData)))
        })
    }
    
    func test_authenticateWithPublicKey_shouldNotDeliverPrepareKeyExchangeResultOnInstanceDeallocation() {
        
        var sut: SUT?
        let prepareKeyExchangeSpy: PrepareKeyExchangeSpy
        (sut, prepareKeyExchangeSpy, _, _) = makeSUT()
        var receivedResults = [SUT.Result]()
        
        sut?.authenticateWithPublicKey { receivedResults.append($0) }
        sut = nil
        prepareKeyExchangeSpy.complete(with: .success(anyData()))
        
        XCTAssert(receivedResults.isEmpty)
    }
    
    func test_authenticateWithPublicKey_shouldNotDeliverProcessResultOnInstanceDeallocation() {
        
        var sut: SUT?
        let prepareKeyExchangeSpy: PrepareKeyExchangeSpy
        let processSpy: ProcessSpy
        (sut, prepareKeyExchangeSpy, processSpy, _) = makeSUT()
        var receivedResults = [SUT.Result]()
        
        sut?.authenticateWithPublicKey { receivedResults.append($0) }
        prepareKeyExchangeSpy.complete(with: anySuccess())
        sut = nil
        processSpy.complete(with: anySuccess())
        
        XCTAssert(receivedResults.isEmpty)
    }
    
    func test_authenticateWithPublicKey_shouldNotDeliverMakeSessionKeySpyResultOnInstanceDeallocation() {
        
        var sut: SUT?
        let prepareKeyExchangeSpy: PrepareKeyExchangeSpy
        let processSpy: ProcessSpy
        let makeSessionKeySpy: MakeSessionKeySpy
        (sut, prepareKeyExchangeSpy, processSpy, makeSessionKeySpy) = makeSUT()
        var receivedResults = [SUT.Result]()
        
        sut?.authenticateWithPublicKey { receivedResults.append($0) }
        prepareKeyExchangeSpy.complete(with: .success(anyData()))
        processSpy.complete(with: anySuccess())
        sut = nil
        makeSessionKeySpy.complete(with: anySuccess())
        
        XCTAssert(receivedResults.isEmpty)
    }
    
    // MARK: - Helpers
    
    private typealias SUT = AuthenticateWithPublicKeyService
    private typealias PrepareKeyExchangeSpy = Spy<Void, Data, Error>
    private typealias ProcessSpy = Spy<Data, SUT.Response, SUT.APIError>
    private typealias MakeSessionKeySpy = Spy<SUT.Response, SUT.Success.SessionKey, Error>
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        prepareKeyExchangeSpy: PrepareKeyExchangeSpy,
        processSpy: ProcessSpy,
        makeSessionKeySpy: MakeSessionKeySpy
    ) {
        
        let prepareKeyExchangeSpy = PrepareKeyExchangeSpy()
        let processSpy = ProcessSpy()
        let makeSessionKeySpy = MakeSessionKeySpy()
        
        let sut = SUT(
            prepareKeyExchange: prepareKeyExchangeSpy.process(completion:),
            process: processSpy.process(_:completion:),
            makeSessionKey: makeSessionKeySpy.process(_:completion:)
        )
        
        trackForMemoryLeaks(sut, file: file, line:  line)
        trackForMemoryLeaks(prepareKeyExchangeSpy, file: file, line:  line)
        trackForMemoryLeaks(processSpy, file: file, line:  line)
        trackForMemoryLeaks(makeSessionKeySpy, file: file, line:  line)
        
        return (sut, prepareKeyExchangeSpy, processSpy, makeSessionKeySpy)
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
        
        sut.authenticateWithPublicKey {
            
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

private extension Array where Element == AuthenticateWithPublicKeyService.Result {
    
    func mapToEquatable() -> [AuthenticateWithPublicKeyService.Result.EquatableResult] {
        
        map { $0.mapToEquatable() }
    }
}

private extension AuthenticateWithPublicKeyService.Result {
    
    func mapToEquatable() -> EquatableResult {
        
        self
            .map(EquatableSuccess.init)
            .mapError(EquatableError.init(error:))
    }
    
    typealias EquatableResult = Result<EquatableSuccess, EquatableError>
    
    struct EquatableSuccess: Equatable {
        
        public let sessionID: String
        public let sessionKey: Data
        public let sessionTTL: Int
        
        init(success: AuthenticateWithPublicKeyService.Success) {
            
            self.sessionID = success.sessionID.sessionIDValue
            self.sessionKey = success.sessionKey.sessionKeyValue
            self.sessionTTL = success.sessionTTL
        }
    }
    
    enum EquatableError: Swift.Error & Equatable {
        
        case invalid(statusCode: Int, data: Data)
        case network
        case server(statusCode: Int, errorMessage: String)
        case serviceError(ServiceError)
        
        init(error: AuthenticateWithPublicKeyService.Error) {
            
            switch error {
            case let .invalid(statusCode: statusCode, data: data):
                self = .invalid(statusCode: statusCode, data: data)
                
            case .network:
                self = .network
                
            case let .server(statusCode: statusCode, errorMessage: errorMessage):
                self = .server(statusCode: statusCode, errorMessage: errorMessage)
                
            case let .serviceError(serviceError):
                switch serviceError {
                case .activationFailure:
                    self = .serviceError(.activationFailure)
                    
                case .makeSessionKeyFailure:
                    self = .serviceError(.makeSessionKeyFailure)
                    
                case .missingRSAPublicKey:
                    self = .serviceError(.missingRSAPublicKey)
                    
                case .prepareKeyExchangeFailure:
                    self = .serviceError(.prepareKeyExchangeFailure)
                }
            }
        }
        
        public enum ServiceError {
            
            case activationFailure
            case makeSessionKeyFailure
            case missingRSAPublicKey
            case prepareKeyExchangeFailure
        }
    }
}

private func anySuccess(
    bitCount: Int = 256
) -> AuthenticateWithPublicKeyService.PrepareKeyExchangeResult {
    
    .success(anyData(bitCount: bitCount))
}

private func anySuccess(
) -> AuthenticateWithPublicKeyService.ProcessResult {
    
    .success(makeResponse(
        sessionID: UUID().uuidString,
        publicServerSessionKey: UUID().uuidString,
        sessionTTL: 60
    ))
}

private func anySuccess(
    bitCount: Int = 256
) -> AuthenticateWithPublicKeyService.MakeSessionKeyResult {
    
    .success(.init(sessionKeyValue: anyData(bitCount: bitCount)))
}

private func makeResponse(
    sessionID: String,
    publicServerSessionKey: String,
    sessionTTL: Int
) -> AuthenticateWithPublicKeyService.Response {
    
    .init(
        sessionID: sessionID,
        publicServerSessionKey: publicServerSessionKey,
        sessionTTL: sessionTTL
    )
}

private func makeSuccess(
    sessionIDValue: String,
    sessionKeyValue: Data,
    sessionTTL: AuthenticateWithPublicKeyService.Success.SessionTTL
) -> AuthenticateWithPublicKeyService.Success {
    
    .init(
        sessionID: .init(sessionIDValue: sessionIDValue),
        sessionKey: .init(sessionKeyValue: sessionKeyValue),
        sessionTTL: sessionTTL
    )
}
