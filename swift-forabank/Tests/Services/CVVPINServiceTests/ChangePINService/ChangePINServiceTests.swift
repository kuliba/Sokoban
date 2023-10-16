//
//  ChangePINServiceTests.swift
//  
//
//  Created by Igor Malyarov on 04.10.2023.
//

import CVVPINService
import XCTest

final class ChangePINServiceTests: XCTestCase {
    
    func test_init_shouldNotCallCollaborators() {
        
        let (sut, sessionIDLoader, symmetricKeyLoader, eventIDLoader, rsaPrivateKeyLoader, service) = makeSUT()
        
        XCTAssertEqual(sessionIDLoader.callCount, 0)
        XCTAssertEqual(symmetricKeyLoader.callCount, 0)
        XCTAssertEqual(eventIDLoader.callCount, 0)
        XCTAssertEqual(rsaPrivateKeyLoader.callCount, 0)
        XCTAssertEqual(service.callCount, 0)
        _ = sut
    }
    
    func test_changePIN_shouldDeliverLoadSessionIDFailureOnSessionIDLoadError() {
        
        let loadSessionIDError = anyError("SessionIDLoader Failure")
        let (sut, sessionIDLoader, _, _, _, _) = makeSUT()
        
        assert(
            sut,
            delivers: .missing(.sessionID),
            on: {
                sessionIDLoader.complete(with: .failure(loadSessionIDError))
            }
        )
    }
    
    func test_changePIN_shouldDeliverLoadSymmetricKeyFailureOnSymmetricKeyLoadError() {
        
        let loadSymmetricKeyError = anyError("SymmetricKeyLoader Failure")
        let (sut, sessionIDLoader, symmetricKeyLoader, _, _, _) = makeSUT()
        
        assert(
            sut,
            delivers: .missing(.symmetricKey),
            on: {
                sessionIDLoader.complete(with: anySuccess())
                symmetricKeyLoader.complete(with: .failure(loadSymmetricKeyError))
            }
        )
    }
    
    func test_changePIN_shouldDeliverLoadEventIDFailureOnEventIDLoadError() {
        
        let loadEventIDError = anyError("EventIDLoader Failure")
        let (sut, sessionIDLoader, symmetricKeyLoader, eventIDLoader, _, _) = makeSUT()
        
        assert(
            sut,
            delivers: .missing(.eventID),
            on: {
                sessionIDLoader.complete(with: anySuccess())
                symmetricKeyLoader.complete(with: anySuccess())
                eventIDLoader.complete(with: .failure(loadEventIDError))
            }
        )
    }
    
    func test_changePIN_shouldDeliverLoadRSAPrivateKeyFailureOnRSAPrivateKeyLoadError() {
        
        let loadRSAPrivateKeyError = anyError("RSAPrivateKeyLoader Failure")
        let (sut, sessionIDLoader, symmetricKeyLoader, eventIDLoader, rsaPrivateKeyLoader, _) = makeSUT()
        
        assert(
            sut,
            delivers: .missing(.rsaPrivateKey),
            on: {
                sessionIDLoader.complete(with: anySuccess())
                symmetricKeyLoader.complete(with: anySuccess())
                eventIDLoader.complete(with: anySuccess())
                rsaPrivateKeyLoader.complete(with: .failure(loadRSAPrivateKeyError))
            }
        )
    }
    
    func test_changePIN_shouldDeliverMakeSecretPINRequestFailureOnMakeSecretPINRequestError() {
        
        let makeSecretPINRequestError = anyError("MakeSecretPINRequest Failure")
        let (sut, sessionIDLoader, symmetricKeyLoader, eventIDLoader, rsaPrivateKeyLoader, _) = makeSUT(
            pinRequestStub: .failure(makeSecretPINRequestError)
        )
        
        assert(
            sut,
            delivers: .makeSecretPINRequestFailure,
            on: {
                sessionIDLoader.complete(with: anySuccess())
                symmetricKeyLoader.complete(with: anySuccess())
                eventIDLoader.complete(with: anySuccess())
                rsaPrivateKeyLoader.complete(with: anySuccess())
            }
        )
    }
    
    func test_changePIN_shouldDeliverWeakPinOnProcessWeakPin() {
        
        let weakPIN = ChangePINError.APIError.weakPIN(
            statusCode: 7506,
            errorMessage: "Возникла техническая ошибка 7506. Свяжитесь с поддержкой банка для уточнения"
        )
        let (sut, sessionIDLoader, symmetricKeyLoader, eventIDLoader, rsaPrivateKeyLoader, service) = makeSUT()
        
        assert(
            sut,
            delivers: ChangePINError.apiError(weakPIN),
            on: {
                sessionIDLoader.complete(with: anySuccess())
                symmetricKeyLoader.complete(with: anySuccess())
                eventIDLoader.complete(with: anySuccess())
                rsaPrivateKeyLoader.complete(with: anySuccess())
                service.complete(with: weakPIN)
            })
    }
    
    func test_changePIN_shouldDeliverRetryOnProcessRetry() {
        
        let retry = ChangePINError.APIError.retry(
            statusCode: 7512,
            errorMessage: "Возникла техническая ошибка 7512. Свяжитесь с поддержкой банка для уточнения",
            retryAttempts: 2
        )
        let (sut, sessionIDLoader, symmetricKeyLoader, eventIDLoader, rsaPrivateKeyLoader, service) = makeSUT()
        
        assert(
            sut,
            delivers: ChangePINError.apiError(retry),
            on: {
                sessionIDLoader.complete(with: anySuccess())
                symmetricKeyLoader.complete(with: anySuccess())
                eventIDLoader.complete(with: anySuccess())
                rsaPrivateKeyLoader.complete(with: anySuccess())
                service.complete(with: retry)
            }
        )
    }
    
    func test_changePIN_shouldDeliverFailureOnProcessError() {
        
        let (sut, sessionIDLoader, symmetricKeyLoader, eventIDLoader, rsaPrivateKeyLoader, service) = makeSUT()
        
        assert(
            sut,
            delivers: .apiError(.error(
                statusCode: 7506,
                errorMessage: "Возникла техническая ошибка 7506. Свяжитесь с поддержкой банка для уточнения"
            )),
            on: {
                sessionIDLoader.complete(with: anySuccess())
                symmetricKeyLoader.complete(with: anySuccess())
                eventIDLoader.complete(with: anySuccess())
                rsaPrivateKeyLoader.complete(with: anySuccess())
                service.complete(with: .error(
                    statusCode: 7506,
                    errorMessage: "Возникла техническая ошибка 7506. Свяжитесь с поддержкой банка для уточнения"
                ))
            }
        )
    }
    
    func test_changePIN_shouldDeliverSuccessOnSuccess() {
        
        let (sut, sessionIDLoader, symmetricKeyLoader, eventIDLoader, rsaPrivateKeyLoader, service) = makeSUT()
        
        assert(
            sut,
            delivers: nil,
            on: {
                sessionIDLoader.complete(with: anySuccess())
                symmetricKeyLoader.complete(with: anySuccess())
                eventIDLoader.complete(with: anySuccess())
                rsaPrivateKeyLoader.complete(with: anySuccess())
                service.complete(with: nil)
            }
        )
    }
    
    func test_changePIN_shouldNotDeliverOnInstanceDeallocationBeforeLoadSessionIDComplete() {
        
        let (infra, sessionIDLoader, _, _, _, _) = makeInfra()
        var sut: SUT? = .init(
            infra: infra,
            makePINChangeJSON: { _,_,_,_,_,_ in .init() },
            makeSecretPINRequest: { _,_,_ in .init() }
        )
        var results = [ChangePINError?]()
        
        sut?.changePIN { results.append($0) }
        sut = nil
        sessionIDLoader.complete(with: anySuccess())
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.1)
        
        XCTAssertEqual(results, [])
    }
    
    func test_changePIN_shouldNotDeliverOnInstanceDeallocationBeforeLoadSymmetricKeyComplete() {
        
        let (infra, sessionIDLoader, symmetricKeyLoader, _, _, _) = makeInfra()
        var sut: SUT? = .init(
            infra: infra,
            makePINChangeJSON: { _,_,_,_,_,_ in .init() },
            makeSecretPINRequest: { _,_,_ in .init() }
        )
        var results = [ChangePINError?]()
        
        sut?.changePIN { results.append($0) }
        sessionIDLoader.complete(with: anySuccess())
        sut = nil
        symmetricKeyLoader.complete(with: anySuccess())
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.1)
        
        XCTAssertEqual(results, [])
    }
    
    func test_changePIN_shouldNotDeliverOnInstanceDeallocationBeforeLoadEventIDComplete() {
        
        let (infra, sessionIDLoader, symmetricKeyLoader, eventIDLoader, _, _) = makeInfra()
        var sut: SUT? = .init(
            infra: infra,
            makePINChangeJSON: { _,_,_,_,_,_ in .init() },
            makeSecretPINRequest: { _,_,_ in .init() }
        )
        var results = [ChangePINError?]()
        
        sut?.changePIN { results.append($0) }
        sessionIDLoader.complete(with: anySuccess())
        symmetricKeyLoader.complete(with: anySuccess())
        sut = nil
        eventIDLoader.complete(with: anySuccess())
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.1)
        
        XCTAssertEqual(results, [])
    }
    
    func test_changePIN_shouldNotDeliverOnInstanceDeallocationBeforeLoadRSAPrivateKeyComplete() {
        
        let (infra, sessionIDLoader, symmetricKeyLoader, eventIDLoader, rsaPrivateKeyLoader, _) = makeInfra()
        var sut: SUT? = .init(
            infra: infra,
            makePINChangeJSON: { _,_,_,_,_,_ in .init() },
            makeSecretPINRequest: { _,_,_ in .init() }
        )
        var results = [ChangePINError?]()
        
        sut?.changePIN { results.append($0) }
        sessionIDLoader.complete(with: anySuccess())
        symmetricKeyLoader.complete(with: anySuccess())
        eventIDLoader.complete(with: anySuccess())
        sut = nil
        rsaPrivateKeyLoader.complete(with: anySuccess())
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.1)
        
        XCTAssertEqual(results, [])
    }
    
    func test_changePIN_shouldNotDeliverOnInstanceDeallocationBeforeProcessComplete() {
        
        let (infra, sessionIDLoader, symmetricKeyLoader, eventIDLoader, rsaPrivateKeyLoader, service) = makeInfra()
        var sut: SUT? = .init(
            infra: infra,
            makePINChangeJSON: { _,_,_,_,_,_ in .init() },
            makeSecretPINRequest: { _,_,_ in .init() }
        )
        var results = [ChangePINError?]()
        
        sut?.changePIN { results.append($0) }
        sessionIDLoader.complete(with: anySuccess())
        symmetricKeyLoader.complete(with: anySuccess())
        eventIDLoader.complete(with: anySuccess())
        rsaPrivateKeyLoader.complete(with: anySuccess())
        sut = nil
        service.complete(with: nil)
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.1)
        
        XCTAssertEqual(results, [])
    }
    
    // MARK: - Helpers
    
    fileprivate typealias SUT = ChangePINService<CardID, EventID, OTP, PIN, RSAPrivateKey, SessionID, SymmetricKey>
    private typealias SessionIDLoaderSpy = LoaderSpyOf<SessionID>
    private typealias SymmetricKeyLoaderSpy = LoaderSpyOf<SymmetricKey>
    private typealias EventIDLoaderSpy = LoaderSpyOf<EventID>
    private typealias RSAPrivateKeyLoaderSpy = LoaderSpyOf<RSAPrivateKey>
    
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
        rsaPrivateKeyLoader: RSAPrivateKeyLoaderSpy,
        service: ServiceSpyOf<ChangePINError.APIError?>
    ) {
        let (infra, sessionIDLoader, symmetricKeyLoader, eventIDLoader, rsaPrivateKeyLoader, service) = makeInfra(file: file, line: line)
        let sut = SUT(
            infra: infra,
            makePINChangeJSON: { _,_,_,_,_,_ in try pinChangeStub.get() },
            makeSecretPINRequest: { _,_,_ in try pinRequestStub.get() }
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return (sut, sessionIDLoader, symmetricKeyLoader, eventIDLoader, rsaPrivateKeyLoader, service)
    }
    
    private func makeInfra(
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        infra: SUT.Infra,
        sessionIDLoader: SessionIDLoaderSpy,
        symmetricKeyLoader: SymmetricKeyLoaderSpy,
        eventIDLoader: EventIDLoaderSpy,
        rsaPrivateKeyLoader: RSAPrivateKeyLoaderSpy,
        service: ServiceSpyOf<ChangePINError.APIError?>
    ) {
        let sessionIDLoader = SessionIDLoaderSpy()
        let symmetricKeyLoader = SymmetricKeyLoaderSpy()
        let eventIDLoader = EventIDLoaderSpy()
        let rsaPrivateKeyLoader = RSAPrivateKeyLoaderSpy()
        let service = ServiceSpyOf<ChangePINError.APIError?>()
        let infra = SUT.Infra(
            loadSessionID: sessionIDLoader.load(completion:),
            loadSymmetricKey: symmetricKeyLoader.load(completion:),
            loadEventID: eventIDLoader.load(completion:),
            loadRSAPrivateKey: rsaPrivateKeyLoader.load(completion:),
            process: service.process
        )
        
        trackForMemoryLeaks(sessionIDLoader, file: file, line: line)
        trackForMemoryLeaks(symmetricKeyLoader, file: file, line: line)
        trackForMemoryLeaks(eventIDLoader, file: file, line: line)
        trackForMemoryLeaks(rsaPrivateKeyLoader, file: file, line: line)
        trackForMemoryLeaks(service, file: file, line: line)
        
        return (infra, sessionIDLoader, symmetricKeyLoader, eventIDLoader, rsaPrivateKeyLoader, service)
    }
    
    private func assert(
        _ sut: SUT,
        delivers expectedError: ChangePINError?,
        on action: @escaping () -> Void,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        var results = [ChangePINError?]()
        let exp = expectation(description: "wait for completion")
        
        sut.changePIN {
            
            results.append($0)
            exp.fulfill()
        }
        action()
        wait(for: [exp], timeout: 0.1)
        
        XCTAssertEqual(results, [expectedError], file: file, line: line)
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

private func anySuccess(
    _ value: String = "RSAPrivateKey 123456"
) -> ChangePINServiceTests.SUT.Infra.RSAPrivateKeyDomain.Result {
    
    .success(.init(value))
}

// MARK: - DSL

extension ChangePINServiceTests.SUT {
    
    func changePIN(completion: @escaping Completion) {
        
        self.changePIN(cardID: makeCardID(), otp: makeOTP(), pin: makePIN(), completion: completion)
    }
}
