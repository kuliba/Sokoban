//
//  ChangePINServiceTests.swift
//  
//
//  Created by Igor Malyarov on 04.10.2023.
//

import CVVPINServices
import XCTest

final class ChangePINServiceTests: XCTestCase {
    
    func test_init_shouldNotCallCollaborators() {
        
        let (sut, sessionIDLoader, symmetricKeyLoader, eventIDLoader, service) = makeSUT()
        
        XCTAssertEqual(sessionIDLoader.callCount, 0)
        XCTAssertEqual(symmetricKeyLoader.callCount, 0)
        XCTAssertEqual(eventIDLoader.callCount, 0)
        XCTAssertEqual(service.callCount, 0)
        _ = sut
    }
    
    func test_changePIN_shouldDeliverLoadSessionIDFailureOnSessionIDLoadError() {
        
        let loadSessionIDError = anyError("SessionIDLoader Failure")
        let (sut, sessionIDLoader, _, _, _) = makeSUT()
        
        assert(
            sut,
            delivers: .failure(.missing(.sessionID)),
            on: {
                sessionIDLoader.complete(with: .failure(loadSessionIDError))
            }
        )
    }
    
    func test_changePIN_shouldDeliverLoadSymmetricKeyFailureOnSymmetricKeyLoadError() {
        
        let loadSymmetricKeyError = anyError("SymmetricKeyLoader Failure")
        let (sut, sessionIDLoader, symmetricKeyLoader, _, _) = makeSUT()
        
        assert(
            sut,
            delivers: .failure(.missing(.symmetricKey)),
            on: {
                sessionIDLoader.complete(with: anySuccess())
                symmetricKeyLoader.complete(with: .failure(loadSymmetricKeyError))
            }
        )
    }
    
    func test_changePIN_shouldDeliverLoadEventIDFailureOnEventIDLoadError() {
        
        let loadEventIDError = anyError("EventIDLoader Failure")
        let (sut, sessionIDLoader, symmetricKeyLoader, eventIDLoader, _) = makeSUT()
        
        assert(
            sut,
            delivers: .failure(.missing(.eventID)),
            on: {
                sessionIDLoader.complete(with: anySuccess())
                symmetricKeyLoader.complete(with: anySuccess())
                eventIDLoader.complete(with: .failure(loadEventIDError))
            }
        )
    }
    
    func test_changePIN_shouldDeliverMakeSecretPINRequestFailureOnMakeSecretPINRequestError() {
        
        let makeSecretPINRequestError = anyError("MakeSecretPINRequest Failure")
        let (sut, sessionIDLoader, symmetricKeyLoader, eventIDLoader, _) = makeSUT(
            pinRequestStub: .failure(makeSecretPINRequestError)
        )
        
        assert(
            sut,
            delivers: .failure(.makeSecretPINRequestFailure),
            on: {
                sessionIDLoader.complete(with: anySuccess())
                symmetricKeyLoader.complete(with: anySuccess())
                eventIDLoader.complete(with: anySuccess())
            }
        )
    }
    
    func test_changePIN_shouldDeliverWeakPinOnProcessWeakPin() {
        
        let weakPIN = APIError.weakPIN(
            statusCode: 7506,
            errorMessage: "Возникла техническая ошибка 7506. Свяжитесь с поддержкой банка для уточнения"
        )
        let (sut, sessionIDLoader, symmetricKeyLoader, eventIDLoader, service) = makeSUT()
        
        assert(
            sut,
            delivers: .failure(.apiError(weakPIN)),
            on: {
                sessionIDLoader.complete(with: anySuccess())
                symmetricKeyLoader.complete(with: anySuccess())
                eventIDLoader.complete(with: anySuccess())
                service.complete(with: .failure(weakPIN))
            })
    }
    
    func test_changePIN_shouldDeliverRetryOnProcessRetry() {
        
        let retry = APIError.retry(
            statusCode: 7512,
            errorMessage: "Возникла техническая ошибка 7512. Свяжитесь с поддержкой банка для уточнения",
            retryAttempts: 2
        )
        let (sut, sessionIDLoader, symmetricKeyLoader, eventIDLoader, service) = makeSUT()
        
        assert(
            sut,
            delivers: .failure(.apiError(retry)),
            on: {
                sessionIDLoader.complete(with: anySuccess())
                symmetricKeyLoader.complete(with: anySuccess())
                eventIDLoader.complete(with: anySuccess())
                service.complete(with: .failure(retry))
            }
        )
    }
    
    func test_changePIN_shouldDeliverFailureOnProcessError() {
        
        let (sut, sessionIDLoader, symmetricKeyLoader, eventIDLoader, service) = makeSUT()
        
        assert(
            sut,
            delivers: .failure(.apiError(.error(
                statusCode: 7506,
                errorMessage: "Возникла техническая ошибка 7506. Свяжитесь с поддержкой банка для уточнения"
            ))),
            on: {
                sessionIDLoader.complete(with: anySuccess())
                symmetricKeyLoader.complete(with: anySuccess())
                eventIDLoader.complete(with: anySuccess())
                service.complete(with: .failure(.error(
                    statusCode: 7506,
                    errorMessage: "Возникла техническая ошибка 7506. Свяжитесь с поддержкой банка для уточнения"
                )))
            }
        )
    }
    
    func test_changePIN_shouldDeliverSuccessOnSuccess() {
        
        let (sut, sessionIDLoader, symmetricKeyLoader, eventIDLoader, service) = makeSUT()
        
        assert(
            sut,
            delivers: .success(()),
            on: {
                sessionIDLoader.complete(with: anySuccess())
                symmetricKeyLoader.complete(with: anySuccess())
                eventIDLoader.complete(with: anySuccess())
                service.complete(with: .success(()))
            }
        )
    }
    
    func test_changePIN_shouldNotDeliverOnInstanceDeallocationBeforeLoadSessionIDComplete() {
        
        let (infra, sessionIDLoader, _, _, _) = makeInfra()
        var sut: SUT? = .init(
            infra: infra,
            makePINChangeJSON: { _,_,_,_,_ in .init() },
            makeSecretPINRequest: { _,_,_ in .init() }
        )
        var results = [Result<Void, PINError>]()
        
        sut?.changePIN { results.append($0) }
        sut = nil
        sessionIDLoader.complete(with: anySuccess())
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.1)
        
        XCTAssertTrue(results.isEmpty)
    }
    
    func test_changePIN_shouldNotDeliverOnInstanceDeallocationBeforeLoadSymmetricKeyComplete() {
        
        let (infra, sessionIDLoader, symmetricKeyLoader, _, _) = makeInfra()
        var sut: SUT? = .init(
            infra: infra,
            makePINChangeJSON: { _,_,_,_,_ in .init() },
            makeSecretPINRequest: { _,_,_ in .init() }
        )
        var results = [Result<Void, PINError>]()
        
        sut?.changePIN { results.append($0) }
        sessionIDLoader.complete(with: anySuccess())
        sut = nil
        symmetricKeyLoader.complete(with: anySuccess())
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.1)
        
        XCTAssertTrue(results.isEmpty)
    }
    
    func test_changePIN_shouldNotDeliverOnInstanceDeallocationBeforeLoadEventIDComplete() {
        
        let (infra, sessionIDLoader, symmetricKeyLoader, eventIDLoader, _) = makeInfra()
        var sut: SUT? = .init(
            infra: infra,
            makePINChangeJSON: { _,_,_,_,_ in .init() },
            makeSecretPINRequest: { _,_,_ in .init() }
        )
        var results = [Result<Void, PINError>]()
        
        sut?.changePIN { results.append($0) }
        sessionIDLoader.complete(with: anySuccess())
        symmetricKeyLoader.complete(with: anySuccess())
        sut = nil
        eventIDLoader.complete(with: anySuccess())
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.1)
        
        XCTAssertTrue(results.isEmpty)
    }
    
    func test_changePIN_shouldNotDeliverOnInstanceDeallocationBeforeProcessComplete() {
        
        let (infra, sessionIDLoader, symmetricKeyLoader, eventIDLoader, service) = makeInfra()
        var sut: SUT? = .init(
            infra: infra,
            makePINChangeJSON: { _,_,_,_,_ in .init() },
            makeSecretPINRequest: { _,_,_ in .init() }
        )
        var results = [Result<Void, PINError>]()
        
        sut?.changePIN { results.append($0) }
        sessionIDLoader.complete(with: anySuccess())
        symmetricKeyLoader.complete(with: anySuccess())
        eventIDLoader.complete(with: anySuccess())
        sut = nil
        service.complete(with: .success(()))
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.1)
        
        XCTAssertTrue(results.isEmpty)
    }
    
    // MARK: - Helpers
    
    fileprivate typealias APIError = ResponseMapper.ChangePINMappingError
    fileprivate typealias SUT = ChangePINService<APIError, CardID, EventID, OTP, PIN, RSAPrivateKey, SessionID, SymmetricKey>
    private typealias SessionIDLoaderSpy = LoaderSpyOf<SessionID>
    private typealias SymmetricKeyLoaderSpy = LoaderSpyOf<SymmetricKey>
    private typealias EventIDLoaderSpy = LoaderSpyOf<EventID>
    private typealias RSAPrivateKeyLoaderSpy = LoaderSpyOf<RSAPrivateKey>
    private typealias PINError = ChangePINError<APIError>
    
    private func makeSUT(
        pinChangeStub: Result<Data, Error> = .success(.init()),
        pinRequestStub: Result<Data, Error> = .success(.init()),
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        sessionIDLoader: SessionIDLoaderSpy,
        symmetricKeyLoader: SymmetricKeyLoaderSpy,
        eventIDLoader: EventIDLoaderSpy,
        service: ServiceSpy<Result<Void, APIError>, (SessionID, Data)>
    ) {
        let (infra, sessionIDLoader, symmetricKeyLoader, eventIDLoader, service) = makeInfra(file: file, line: line)
        let sut = SUT(
            infra: infra,
            makePINChangeJSON: { _,_,_,_,_ in try pinChangeStub.get() },
            makeSecretPINRequest: { _,_,_ in try pinRequestStub.get() }
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return (sut, sessionIDLoader, symmetricKeyLoader, eventIDLoader, service)
    }
    
    private func makeInfra(
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        infra: SUT.Infra,
        sessionIDLoader: SessionIDLoaderSpy,
        symmetricKeyLoader: SymmetricKeyLoaderSpy,
        eventIDLoader: EventIDLoaderSpy,
        service: ServiceSpy<Result<Void, APIError>, (SessionID, Data)>
    ) {
        let sessionIDLoader = SessionIDLoaderSpy()
        let symmetricKeyLoader = SymmetricKeyLoaderSpy()
        let eventIDLoader = EventIDLoaderSpy()
        let service = ServiceSpy<Result<Void, APIError>, (SessionID, Data)>()
        let infra = SUT.Infra(
            loadSessionID: sessionIDLoader.load(completion:),
            loadSymmetricKey: symmetricKeyLoader.load(completion:),
            loadEventID: eventIDLoader.load(completion:),
            process: service.process
        )
        
        trackForMemoryLeaks(sessionIDLoader, file: file, line: line)
        trackForMemoryLeaks(symmetricKeyLoader, file: file, line: line)
        trackForMemoryLeaks(eventIDLoader, file: file, line: line)
        trackForMemoryLeaks(service, file: file, line: line)
        
        return (infra, sessionIDLoader, symmetricKeyLoader, eventIDLoader, service)
    }
    
    private func assert(
        _ sut: SUT,
        delivers expectedError: Result<Void, PINError>,
        on action: @escaping () -> Void,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        var results = [Result<Void, PINError>]()
        let exp = expectation(description: "wait for completion")
        
        sut.changePIN {
            
            results.append($0)
            exp.fulfill()
        }
        action()
        wait(for: [exp], timeout: 0.1)
        
        assertVoid(results, equalsTo: [expectedError], file: file, line: line)
    }
}

private func anySuccess(
    _ rawValue: String = "Session ID 123"
) -> ChangePINServiceTests.SUT.Infra.SessionIDDomain.Result {
    
    .success(.init(rawValue: rawValue))
}

private func anySuccess(
    _ rawValue: String = "Symmetric Key"
) -> ChangePINServiceTests.SUT.Infra.SymmetricKeyDomain.Result {
    
    .success(.init(rawValue))
}

private func anySuccess(
    _ value: String = "Event ID abc"
) -> ChangePINServiceTests.SUT.Infra.EventIDDomain.Result {
    
    .success(.init(rawValue: value))
}

// MARK: - DSL

extension ChangePINServiceTests.SUT {
    
    func changePIN(completion: @escaping Completion) {
        
        self.changePIN(cardID: makeCardID(), otp: makeOTP(), pin: makePIN(), completion: completion)
    }
}
