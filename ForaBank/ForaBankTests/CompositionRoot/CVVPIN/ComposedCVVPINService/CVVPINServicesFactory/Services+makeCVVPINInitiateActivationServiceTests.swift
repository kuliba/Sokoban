//
//  Services+makeCVVPINInitiateActivationServiceTests.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 13.11.2023.
//

import Fetcher

// MARK: - Mappers

private extension CVVPINInitiateActivationService.GetCodeSuccess {
    
    init(_ response: GetProcessingSessionCodeService.Response) {
        
        self.init(
            code: .init(codeValue: response.code),
            phone: .init(phoneValue: response.phone)
        )
    }
}

private extension CVVPINInitiateActivationService.FormSessionKeySuccess {
    
    init(_ success: FormSessionKeyService.Success) {
        
        self.init(
            sessionKey: .init(sessionKeyValue: success.sessionKey.sessionKeyValue),
            eventID: .init(eventIDValue: success.eventID.eventIDValue),
            sessionTTL: success.sessionTTL
        )
    }
}

// MARK: - Error Mappers

private extension CVVPINInitiateActivationService.GetCodeResponseError {
    
    init(_ error: MappingRemoteServiceError<GetProcessingSessionCodeService.APIError>) {
        
        switch error {
        case .createRequest, .performRequest:
            self = .network
            
        case let .mapResponse(mapResponseError):
            switch mapResponseError {
                
            case let .invalid(statusCode: statusCode, data: data):
                self = .invalid(statusCode: statusCode, data: data)
                
            case .network:
                self = .network
                
            case let .server(statusCode: statusCode, errorMessage: errorMessage):
                self = .server(statusCode: statusCode, errorMessage: errorMessage)
            }
        }
    }
}

private extension CVVPINInitiateActivationService.FormSessionKeyError {
    
    init(_ error: FormSessionKeyService.Error) {
        
        switch error {
        case let .invalid(statusCode: statusCode, data: data):
            self = .invalid(statusCode: statusCode, data: data)
            
        case .network:
            self = .network
            
        case let .server(statusCode: statusCode, errorMessage: errorMessage):
            self = .server(statusCode: statusCode, errorMessage: errorMessage)
            
        case .serviceError:
            self = .serviceFailure
        }
    }
}

private extension FormSessionKeyService.APIError {
    
    init(_ error: MappingRemoteServiceError<FormSessionKeyService.APIError>) {
        
        switch error {
        case .createRequest, .performRequest:
            self = .network
            
        case let .mapResponse(mapResponseError):
            self = mapResponseError
        }
    }
}

extension Services {
    
    typealias CacheLog = (LoggerAgentLevel, String, StaticString, UInt) -> Void
    typealias MakeSecretRequestJSON = () throws -> Data
    typealias ExtractSharedSecret = (String) throws -> Data
    
    static func makeCVVPINInitiateActivationServiceTests(
        processGetCode: @escaping Services.ProcessGetCode,
        processFormSessionKey: @escaping Services.ProcessFormSessionKey,
        extractSharedSecret: @escaping ExtractSharedSecret,
        makeSecretRequestJSON: @escaping MakeSecretRequestJSON,
        cacheLog: @escaping CacheLog,
        currentDate: @escaping () -> Date = Date.init,
        ephemeralLifespan: TimeInterval
    ) -> CVVPINInitiateActivationService {
        
        // MARK: Ephemeral Stores & Loaders
        
        let sessionCodeStore = InMemoryStore<SessionCode>()
        
        let sessionCodeLoader = loggingLoader(
            store: sessionCodeStore
        )
        
        // MARK: - Configure Sub-Services
        
        let cachingGetCodeService = FetchDecorator(
            processGetCode,
            handleResult: cacheSessionCode
        )
        
        let adaptedGetCodeService = FetchAdapter(
            cachingGetCodeService.fetch(completion:),
            map: CVVPINInitiateActivationService.GetCodeSuccess.init,
            mapError: CVVPINInitiateActivationService.GetCodeResponseError.init
        )
        
        let formSessionKeyService = FormSessionKeyService(
            makeSecretRequestJSON: _makeSecretRequestJSON,
            process: process(payload:completion:),
            makeSessionKey: makeSessionKey
        )
        
        let adaptedFormSessionKeyService = FetchAdapter(
            fetch: formSessionKeyService.formSessionKey(_:completion:),
            map: CVVPINInitiateActivationService.FormSessionKeySuccess.init,
            mapError: CVVPINInitiateActivationService.FormSessionKeyError.init
        )
        
        return CVVPINInitiateActivationService(
            getCode: adaptedGetCodeService.fetch,
            formSessionKey: { code, completion in
                
                adaptedFormSessionKeyService.fetch(.init(codeValue: code.codeValue), completion: completion)
            }
        )
        
        // MARK: - Helpers
        
        func loggingLoader<T>(
            store: any Store<T>
        ) -> any Loader<T> {
            
            LoggingLoaderDecorator(
                decoratee: GenericLoaderOf(
                    store: store,
                    currentDate: currentDate
                ),
                log: cacheLog
            )
        }
        
        // MARK: - GetProcessingSessionCode Adapters
        
        func cacheSessionCode(
            from result: Services.ProcessGetCodeResult,
            completion: @escaping () -> Void
        ) {
            switch result {
            case let .failure(_):
#warning("error not handled!!")
                completion()
                
            case let .success(success):
                
                // Добавляем в базу данных Redis с индексом 1, запись (пару ключ-значение ) с коротким TTL (например 15 секунд), у которой ключом является session:code:to-process:<code>, где <code> - сгенерированный короткоживущий токен CODE, а значением является JSON (BSON) содержащий параметры необходимые для формирования связки клиента с его открытым ключом
                let validUntil = currentDate().addingTimeInterval(ephemeralLifespan)
                
                sessionCodeLoader.save(
                    .init(sessionCodeValue: success.code),
                    validUntil: validUntil,
                    completion: { _ in completion() }
                )
            }
        }
        
        // MARK: - FormSessionKey Adapters
        
        func process(
            payload: FormSessionKeyService.ProcessPayload,
            completion: @escaping FormSessionKeyService.ProcessCompletion
        ) {
            processFormSessionKey(
                .init(code: payload.code, data: payload.data)
            ) {
                completion($0.mapError { .init($0) })
            }
        }
        
        func _makeSecretRequestJSON(
            completion: @escaping FormSessionKeyService.SecretRequestJSONCompletion
        ) {
            completion(.init(catching: makeSecretRequestJSON))
        }
        
        func makeSessionKey(
            string: String,
            completion: @escaping FormSessionKeyService.MakeSessionKeyCompletion
        ) {
            completion(.init {
                
                try .init(sessionKeyValue: extractSharedSecret(string))
            })
        }
    }
}

import CVVPIN_Services
@testable import ForaBank
import XCTest

final class Services_makeCVVPINInitiateActivationServiceTests: XCTestCase {
    
    func test_init_shouldNotCallCollaborators() {
        
        let (_, processGetCodeSpy, processFormSessionKeySpy) = makeSUT()
        
        XCTAssertEqual(processGetCodeSpy.callCount, 0)
        XCTAssertEqual(processFormSessionKeySpy.callCount, 0)
    }
    
    func test_activate_shouldDeliverErrorOnProcessGetCodeCreateRequestFailure() {
        
        let (sut, processGetCodeSpy, _) = makeSUT()
        
        expect(sut, toDeliver: [.failure(.network)], on: {
            
            processGetCodeSpy.complete(with: .failure(.createRequest(anyError())))
        })
    }
    
    func test_activate_shouldDeliverErrorOnProcessGetCodePerformRequestFailure() {
        
        let (sut, processGetCodeSpy, _) = makeSUT()
        
        expect(sut, toDeliver: [.failure(.network)], on: {
            
            processGetCodeSpy.complete(with: .failure(.performRequest(anyError())))
        })
    }
    
#warning("add mapResponse tests")
    
    func test_activate_shouldDeliverErrorOnMakeSecretRequestJSONFailure() {
        
        let (sut, processGetCodeSpy, _) = makeSUT(
            makeSecretRequestJSONResult: .failure(anyError())
        )
        
        expect(sut, toDeliver: [.failure(.serviceFailure)], on: {
            
            processGetCodeSpy.complete(with: anySuccess())
        })
    }
    
    func test_activate_shouldDeliverError_____Failure() {
        
        let (sut, processGetCodeSpy, _) = makeSUT(
            ephemeralLifespan: 0
        )
        
        expect(sut, toDeliver: [.failure(.serviceFailure)], on: {
            
            processGetCodeSpy.complete(with: anySuccess())
        })
    }
    
    func test_activate_shouldDeliverErrorOnProcessFormSessionKeyCreateRequestFailure() {
        
        let (sut, processGetCodeSpy, processFormSessionKeySpy) = makeSUT()
        
        expect(sut, toDeliver: [.failure(.network)], on: {
            
            processGetCodeSpy.complete(with: anySuccess())
//            _ = XCTWaiter().wait(for: [.init()], timeout: 0.02)
            processFormSessionKeySpy.complete(with: .failure(.createRequest(anyError())))
        })
    }
    
    func test_activate_shouldDeliverErrorOnExtractSharedSecretFailure() {
        
        let (sut, processGetCodeSpy, processFormSessionKeySpy) = makeSUT(
            extractSharedSecretResult: .failure(anyError())
        )
        
        expect(sut, toDeliver: [.failure(.serviceFailure)], on: {
            
            processGetCodeSpy.complete(with: anySuccess())
//            _ = XCTWaiter().wait(for: [.init()], timeout: 0.02)
            processFormSessionKeySpy.complete(with: anySuccess())
        })
    }
    
#warning("add more processFormSessionKeySpy failure tests")
    
    func test_activate_shouldDeliverValueOnSuccess() {
        
        let codeValue = UUID().uuidString
        let phoneValue = UUID().uuidString
        let sessionKeyValue = anyData()
        let eventIDValue = UUID().uuidString
        let sessionTTL = 13
        let (sut, processGetCodeSpy, processFormSessionKeySpy) = makeSUT(
            extractSharedSecretResult: .success(sessionKeyValue)
        )
        
        expect(
            sut,
            toDeliver: [
                .success(.init(
                    code: .init(codeValue: codeValue),
                    phone: .init(phoneValue: phoneValue),
                    sessionKey: .init(sessionKeyValue: sessionKeyValue),
                    eventID: .init(eventIDValue: eventIDValue),
                    sessionTTL: sessionTTL
                ))
            ],
            on: {
                processGetCodeSpy.complete(with: .success(.init(
                    code: codeValue,
                    phone: phoneValue
                )))
                _ = XCTWaiter().wait(for: [.init()], timeout: 0.03)
                processFormSessionKeySpy.complete(with: .success(.init(
                    publicServerSessionKey: UUID().uuidString,
                    eventID: eventIDValue,
                    sessionTTL: sessionTTL
                )))
            }
        )
    }
    
    // MARK: - Helpers
    
    private typealias SUT = CVVPINInitiateActivationService
    private typealias ProcessGetCodeSpy = Spy<Void, Services.ProcessGetCodeSuccess, Services.ProcessGetCodeError>
    private typealias ProcessFormSessionKeySpy = Spy<FormSessionKeyService.ProcessPayload, FormSessionKeyService.Response, Services.ProcessFormSessionKeyError>
    
    private func makeSUT(
        extractSharedSecretResult: Result<Data, Error> = .success(anyData()),
        makeSecretRequestJSONResult: Result<Data, Error> = .success(anyData()),
        currentDate: @escaping () -> Date = Date.init,
        ephemeralLifespan: TimeInterval = 15,
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        processGetCodeSpy: ProcessGetCodeSpy,
        processFormSessionKeySpy: ProcessFormSessionKeySpy
    ) {
        let processGetCodeSpy = ProcessGetCodeSpy()
        let processFormSessionKeySpy = ProcessFormSessionKeySpy()
        
        let sut = Services.makeCVVPINInitiateActivationServiceTests(
            processGetCode: processGetCodeSpy.process,
            processFormSessionKey: processFormSessionKeySpy.process,
            extractSharedSecret: { _ in try extractSharedSecretResult.get() },
            makeSecretRequestJSON: makeSecretRequestJSONResult.get,
            cacheLog: { _, message ,_,_ in print(message) },
            currentDate: currentDate,
            ephemeralLifespan: ephemeralLifespan
        )
        
        //        trackForMemoryLeaks(sut, file: file, line: line)
        //        trackForMemoryLeaks(processGetCodeSpy, file: file, line: line)
        //        trackForMemoryLeaks(processFormSessionKeySpy, file: file, line: line)
        
        return (sut, processGetCodeSpy, processFormSessionKeySpy)
    }
    
    private func expect(
        _ sut: SUT,
        toDeliver expectedResults: [SUT.ActivateResult],
        on action: @escaping () -> Void,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        var receivedResults = [SUT.ActivateResult]()
        let exp = expectation(description: "wait for completion")
        
        sut.activate {
            
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

private extension Array where Element == CVVPINInitiateActivationService.ActivateResult {
    
    func mapToEquatable() -> [CVVPINInitiateActivationService.ActivateResult.EquatableActivateResult] {
        
        map { $0.mapToEquatable() }
    }
}

private extension CVVPINInitiateActivationService.ActivateResult {
    
    func mapToEquatable() -> EquatableActivateResult {
        
        self
            .map(EquatableActivateSuccess.init(response:))
            .mapError(EquatableActivateError.init)
    }
    
    typealias EquatableActivateResult = Swift.Result<EquatableActivateSuccess, EquatableActivateError>
    
    struct EquatableActivateSuccess: Equatable {
        
        let codeValue: String
        let phoneValue: String
        let sessionKeyValue: Data
        let eventIDValue: String
        let sessionTTL: Int
        
        init(response: CVVPINInitiateActivationService.ActivateSuccess) {
            
            self.codeValue = response.code.codeValue
            self.phoneValue = response.phone.phoneValue
            self.sessionKeyValue = response.sessionKey.sessionKeyValue
            self.eventIDValue = response.eventID.eventIDValue
            self.sessionTTL = response.sessionTTL
        }
    }
    
    enum EquatableActivateError: Error & Equatable {
        
        case invalid(statusCode: Int, data: Data)
        case network
        case server(statusCode: Int, errorMessage: String)
        case serviceFailure
        
        init(error: CVVPINInitiateActivationService.ActivateError) {
            
            switch error {
            case let .invalid(statusCode: statusCode, data: data):
                self = .invalid(statusCode: statusCode, data: data)
                
            case .network:
                self = .network
                
            case let .server(statusCode: statusCode, errorMessage: errorMessage):
                self = .server(statusCode: statusCode, errorMessage: errorMessage)
                
            case .serviceFailure:
                self = .serviceFailure
            }
        }
    }
}

private func anySuccess(
    codeValue: String = UUID().uuidString,
    phoneValue: String = UUID().uuidString
) -> Result<Services.ProcessGetCodeSuccess, Services.ProcessGetCodeError> {
    
    .success(.init(code: codeValue, phone: phoneValue))
}

private func anySuccess(
    codeValue: String = UUID().uuidString,
    phoneValue: String = UUID().uuidString
) -> CVVPINInitiateActivationService.GetCodeResult {
    
    .success(.init(
        code: .init(codeValue: codeValue),
        phone: .init(phoneValue: phoneValue)
    ))
}

private func anySuccess(
    sessionKeyValue: Data = anyData(),
    eventIDValue: String = UUID().uuidString,
    sessionTTL: Int = 23
) -> CVVPINInitiateActivationService.FormSessionKeyResult {
    
    .success(
        .init(
            sessionKey: .init(sessionKeyValue: sessionKeyValue),
            eventID: .init(eventIDValue: eventIDValue),
            sessionTTL: sessionTTL
        )
    )
}

private func anySuccess(
    publicServerSessionKey: String = UUID().uuidString,
    eventIDValue: String = UUID().uuidString,
    sessionTTL: Int = 23
) -> Result<FormSessionKeyService.Response, Services.ProcessFormSessionKeyError> {
    
    .success(
        .init(
            publicServerSessionKey: publicServerSessionKey,
            eventID: eventIDValue,
            sessionTTL: sessionTTL
        )
    )
}
