//
//  ShowCVVServiceTests.swift
//  
//
//  Created by Igor Malyarov on 04.11.2023.
//

import CVVPIN_Services
import XCTest

final class ShowCVVServiceTests: XCTestCase {
    
    func test_init_shouldNotCallCollaborators() {
        
        let (_, authenticateSpy, makeJSONSpy, processSpy, decryptCVVSpy) = makeSUT()
        
        XCTAssertNoDiff(authenticateSpy.callCount, 0)
        XCTAssertNoDiff(makeJSONSpy.callCount, 0)
        XCTAssertNoDiff(processSpy.callCount, 0)
        XCTAssertNoDiff(decryptCVVSpy.callCount, 0)
    }
    
    func test_showCVV_shouldDeliverErrorOnAuthenticateActivationFailure() {
        
        let (sut, authenticateSpy, _, _, _) = makeSUT()
        
        expect(sut, toDeliver: [.failure(.activationFailure)], on: {
            
            authenticateSpy.complete(with: .failure(.activationFailure))
        })
    }
    
    func test_showCVV_shouldDeliverErrorOnAuthenticateAuthenticationFailure() {
        
        let (sut, authenticateSpy, _, _, _) = makeSUT()
        
        expect(sut, toDeliver: [.failure(.authenticationFailure)], on: {
            
            authenticateSpy.complete(with: .failure(.authenticationFailure))
        })
    }
    
    func test_showCVV_shouldDeliverErrorOnMakeJSONFailure() {
        
        let (sut, authenticateSpy, makeJSONSpy, _, _) = makeSUT()
        
        expect(sut, toDeliver: [.failure(.serviceError(.makeJSONFailure))], on: {
            
            authenticateSpy.complete(with: anySuccess())
            makeJSONSpy.complete(with: .failure(anyError()))
        })
    }
    
    func test_showCVV_shouldDeliverErrorOnProcessInvalidFailure() {
        
        let statusCode = 500
        let invalidData = anyData()
        let (sut, authenticateSpy, makeJSONSpy, processSpy, _) = makeSUT()
        
        expect(sut, toDeliver: [.failure(.invalid(statusCode: statusCode, data: invalidData))], on: {
            
            authenticateSpy.complete(with: anySuccess())
            makeJSONSpy.complete(with: anySuccess())
            processSpy.complete(with: .failure(.invalid(statusCode: statusCode, data: invalidData)))
        })
    }
    
    func test_showCVV_shouldDeliverErrorOnProcessConnectivityFailure() {
        
        let (sut, authenticateSpy, makeJSONSpy, processSpy, _) = makeSUT()
        
        expect(sut, toDeliver: [.failure(.network)], on: {
            
            authenticateSpy.complete(with: anySuccess())
            makeJSONSpy.complete(with: anySuccess())
            processSpy.complete(with: .failure(.connectivity))
        })
    }
    
    func test_showCVV_shouldDeliverErrorOnProcessServerFailure() {
        
        let statusCode = 500
        let errorMessage = "Process Failure"
        let (sut, authenticateSpy, makeJSONSpy, processSpy, _) = makeSUT()
        
        expect(sut, toDeliver: [.failure(.server(statusCode: statusCode, errorMessage: errorMessage))], on: {
            
            authenticateSpy.complete(with: anySuccess())
            makeJSONSpy.complete(with: anySuccess())
            processSpy.complete(with: .failure(.server(statusCode: statusCode, errorMessage: errorMessage)))
        })
    }
    
    func test_showCVV_shouldDeliverErrorOnDecryptCVVFailure() {
        
        let (sut, authenticateSpy, makeJSONSpy, processSpy, decryptCVVSpy) = makeSUT()
        
        expect(sut, toDeliver: [.failure(.serviceError(.decryptionFailure))], on: {
            
            authenticateSpy.complete(with: anySuccess())
            makeJSONSpy.complete(with: anySuccess())
            processSpy.complete(with: anySuccess())
            decryptCVVSpy.complete(with: .failure(anyError()))
        })
    }
    
    func test_showCVV_shouldDeliverSuccessOnSuccess() {
        
        let cvvValue = "468"
        let (sut, authenticateSpy, makeJSONSpy, processSpy, decryptCVVSpy) = makeSUT()
        
        expect(sut, toDeliver: [.success(.init(cvvValue: cvvValue))], on: {
            
            authenticateSpy.complete(with: anySuccess())
            makeJSONSpy.complete(with: anySuccess())
            processSpy.complete(with: anySuccess())
            decryptCVVSpy.complete(with: .success(.init(cvvValue: cvvValue)))
        })
    }
    
    func test_showCVV_shouldNotDeliverAuthenticateResultOnInstanceDeallocation() {
        
        var sut: SUT?
        let authenticateSpy: AuthenticateSpy
        (sut, authenticateSpy, _, _, _) = makeSUT()
        var receivedResults = [SUT.Result]()
        
        sut?.showCVV(cardID: anyCardID()) { receivedResults.append($0) }
        sut = nil
        authenticateSpy.complete(with: .failure(.activationFailure))
        
        XCTAssert(receivedResults.isEmpty)
    }
    
    func test_showCVV_shouldNotDeliverMakeJSONResultOnInstanceDeallocation() {
        
        var sut: SUT?
        let authenticateSpy: AuthenticateSpy
        let makeJSONSpy: MakeJSONSpy
        (sut, authenticateSpy, makeJSONSpy, _, _) = makeSUT()
        var receivedResults = [SUT.Result]()
        
        sut?.showCVV(cardID: anyCardID()) { receivedResults.append($0) }
        authenticateSpy.complete(with: anySuccess())
        sut = nil
        makeJSONSpy.complete(with: .failure(anyError()))
        
        XCTAssert(receivedResults.isEmpty)
    }
    
    func test_showCVV_shouldNotDeliverProcessResultOnInstanceDeallocation() {
        
        var sut: SUT?
        let authenticateSpy: AuthenticateSpy
        let makeJSONSpy: MakeJSONSpy
        let processSpy: ProcessSpy
        (sut, authenticateSpy, makeJSONSpy, processSpy, _) = makeSUT()
        var receivedResults = [SUT.Result]()
        
        sut?.showCVV(cardID: anyCardID()) { receivedResults.append($0) }
        authenticateSpy.complete(with: anySuccess())
        makeJSONSpy.complete(with: anySuccess())
        sut = nil
        processSpy.complete(with: .failure(.connectivity))
        
        XCTAssert(receivedResults.isEmpty)
    }
    
    func test_showCVV_shouldNotDeliverDecryptCVVResultOnInstanceDeallocation() {
        
        var sut: SUT?
        let authenticateSpy: AuthenticateSpy
        let makeJSONSpy: MakeJSONSpy
        let processSpy: ProcessSpy
        let decryptCVVSpy: DecryptCVVSpy
        (sut, authenticateSpy, makeJSONSpy, processSpy, decryptCVVSpy) = makeSUT()
        var receivedResults = [SUT.Result]()
        
        sut?.showCVV(cardID: anyCardID()) { receivedResults.append($0) }
        authenticateSpy.complete(with: anySuccess())
        makeJSONSpy.complete(with: anySuccess())
        processSpy.complete(with: anySuccess())
        sut = nil
        decryptCVVSpy.complete(with: .failure(anyError()))
        
        XCTAssert(receivedResults.isEmpty)
    }
    
    // MARK: - Helpers
    
    private typealias SUT = ShowCVVService
    private typealias AuthenticateSpy = Spy<Void, SUT.SessionID, SUT.AuthenticateError>
    private typealias MakeJSONSpy = Spy<(SUT.CardID, SUT.SessionID), Data, Error>
    private typealias ProcessSpy = Spy<SUT.Payload, SUT.EncryptedCVV, SUT.APIError>
    private typealias DecryptCVVSpy = Spy<SUT.EncryptedCVV, SUT.CVV, Error>
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        authenticateSpy: AuthenticateSpy,
        makeJSONSpy: MakeJSONSpy,
        processSpy: ProcessSpy,
        decryptCVVSpy: DecryptCVVSpy
    ) {
        let authenticateSpy = AuthenticateSpy()
        let makeJSONSpy = MakeJSONSpy()
        let processSpy = ProcessSpy()
        let decryptCVVSpy = DecryptCVVSpy()
        
        let sut = SUT(
            authenticate: authenticateSpy.process(completion:),
            makeJSON: makeJSONSpy.process(cardID:sessionID:completion:),
            process: processSpy.process(_:completion:),
            decryptCVV: decryptCVVSpy.process(_:completion:)
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(authenticateSpy, file: file, line: line)
        trackForMemoryLeaks(makeJSONSpy, file: file, line: line)
        trackForMemoryLeaks(processSpy, file: file, line: line)
        trackForMemoryLeaks(decryptCVVSpy, file: file, line: line)
        
        return (sut, authenticateSpy, makeJSONSpy, processSpy, decryptCVVSpy)
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
        
        sut.showCVV(cardID: anyCardID()) {
            
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

private func anyCardID() -> ShowCVVService.CardID {
    
    .init(cardIDValue: 12345678909)
}

private extension Array where Element == ShowCVVService.Result {
    
    func mapToEquatable() -> [ShowCVVService.Result.EquatableResult] {
        
        map { $0.mapToEquatable() }
    }
}

private extension ShowCVVService.Result {
    
    func mapToEquatable() -> EquatableResult {
        
        self
            .map(EquatableCVV.init)
            .mapError(EquatableError.init)
    }
    
    typealias EquatableResult = Swift.Result<EquatableCVV, EquatableError>
    
    struct EquatableCVV: Equatable {
        
        let cvvValue: String
        
        init(cvv: ShowCVVService.CVV) {
            
            self.cvvValue = cvv.cvvValue
        }
    }
    
    enum EquatableError: Error & Equatable {
        
        case activationFailure
        case authenticationFailure
        case invalid(statusCode: Int, data: Data)
        case connectivity
        case server(statusCode: Int, errorMessage: String)
        case serviceError(ServiceError)
        
        init(error: ShowCVVService.Error) {
            
            switch error {
            case .activationFailure:
                self = .activationFailure
                
            case .authenticationFailure:
                self = .authenticationFailure
                
            case let .invalid(statusCode: statusCode, data: data):
                self = .invalid(statusCode: statusCode, data: data)
                
            case .network:
                self = .connectivity
                
            case let .server(statusCode: statusCode, errorMessage: errorMessage):
                self = .server(statusCode: statusCode, errorMessage: errorMessage)
                
            case let .serviceError(serviceError):
                switch serviceError {
                case .decryptionFailure:
                    self = .serviceError(.decryptionFailure)
                    
                case .makeJSONFailure:
                    self = .serviceError(.makeJSONFailure)
                }
            }
        }
        
        enum ServiceError {
            
            case decryptionFailure
            case makeJSONFailure
        }
    }
}

private func anySuccess(
    sessionIDValue: String = UUID().uuidString
) -> ShowCVVService.AuthenticateResult {
    
    .success(.init(sessionIDValue: sessionIDValue))
}

private func anySuccess(
    data: Data = anyData()
) -> ShowCVVService.MakeJSONResult {
    
    .success(data)
}

private func anySuccess(
    encryptedCVVValue: String = UUID().uuidString
) -> ShowCVVService.ProcessResult {
    
    .success(.init(encryptedCVVValue: encryptedCVVValue))
}

private extension Spy
where Payload == (ShowCVVService.CardID, ShowCVVService.SessionID) {
    
    func process(
        cardID: ShowCVVService.CardID,
        sessionID: ShowCVVService.SessionID,
        completion: @escaping Completion
    ) {
        process((cardID, sessionID), completion: completion)
    }
}
