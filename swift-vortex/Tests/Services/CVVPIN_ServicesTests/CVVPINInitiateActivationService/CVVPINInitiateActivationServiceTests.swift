//
//  CVVPINInitiateActivationServiceTests.swift
//  
//
//  Created by Igor Malyarov on 04.11.2023.
//

import CVVPIN_Services
import XCTest

final class CVVPINInitiateActivationServiceTests: XCTestCase {
    
    func test_init_shouldNotCallCollaborators() {
        
        let (_, getCodeSpy, formSessionKeySpy) = makeSUT()
        
        XCTAssertNoDiff(getCodeSpy.callCount, 0)
        XCTAssertNoDiff(formSessionKeySpy.callCount, 0)
    }
    
    // MARK: - activate
    
    func test_activate_shouldDeliverErrorOnGetCodeInvalidFailure() {
        
        let statusCode = 500
        let invalidData = anyData()
        let (sut, getCodeSpy, _) = makeSUT()
        
        expectActivate(sut, toDeliver: [
            .failure(.invalid(statusCode: statusCode, data: invalidData))
        ], on: {
            getCodeSpy.complete(with: .failure(.invalid(statusCode: statusCode, data: invalidData)))
        })
    }
    
    func test_activate_shouldDeliverErrorOnGetCodeNetworkFailure() {
        
        let (sut, getCodeSpy, _) = makeSUT()
        
        expectActivate(sut, toDeliver: [.failure(.network)], on: {
            
            getCodeSpy.complete(with: .failure(.network))
        })
    }
    
    func test_activate_shouldDeliverErrorOnGetCodeServerFailure() {
        
        let statusCode = 500
        let errorMessage = "Get Code Error"
        let (sut, getCodeSpy, _) = makeSUT()
        
        expectActivate(sut, toDeliver: [
            .failure(.server(statusCode: statusCode, errorMessage: errorMessage))
        ], on: {
            getCodeSpy.complete(with: .failure(.server(statusCode: statusCode, errorMessage: errorMessage)))
        })
    }
    
    func test_activate_shouldDeliverErrorOnFormSessionKeyInvalidFailure() {
        
        let statusCode = 500
        let invalidData = anyData()
        let (sut, getCodeSpy, formSessionKeySpy) = makeSUT()
        
        expectActivate(sut, toDeliver: [
            .failure(.invalid(statusCode: statusCode, data: invalidData))
        ], on: {
            getCodeSpy.complete(with: anySuccess())
            formSessionKeySpy.complete(with: .failure(.invalid(statusCode: statusCode, data: invalidData)))
        })
    }
    
    func test_activate_shouldDeliverErrorOnFormSessionKeyNetworkFailure() {
        
        let (sut, getCodeSpy, formSessionKeySpy) = makeSUT()
        
        expectActivate(sut, toDeliver: [.failure(.network)], on: {
            
            getCodeSpy.complete(with: anySuccess())
            formSessionKeySpy.complete(with: .failure(.network))
        })
    }
    
    func test_activate_shouldDeliverErrorOnFormSessionKeyServerFailure() {
        
        let statusCode = 500
        let errorMessage = "Forn Session Key Error"
        let (sut, getCodeSpy, formSessionKeySpy) = makeSUT()
        
        expectActivate(sut, toDeliver: [
            .failure(.server(statusCode: statusCode, errorMessage: errorMessage))
        ], on: {
            getCodeSpy.complete(with: anySuccess())
            formSessionKeySpy.complete(with: .failure(.server(statusCode: statusCode, errorMessage: errorMessage)))
        })
    }
    
    func test_activate_shouldDeliverErrorOnFormSessionKeyServiceFailure() {
        
        let (sut, getCodeSpy, formSessionKeySpy) = makeSUT()
        
        expectActivate(sut, toDeliver: [.failure(.serviceFailure)], on: {
            
            getCodeSpy.complete(with: anySuccess())
            formSessionKeySpy.complete(with: .failure(.serviceFailure))
        })
    }
    
    func test_activate_shouldDeliverValueOnSuccess() {
        
        let codeValue = UUID().uuidString
        let phoneValue = UUID().uuidString
        let sessionKeyValue = anyData()
        let eventIDValue = UUID().uuidString
        let sessionTTL = 13
        let (sut, getCodeSpy, formSessionKeySpy) = makeSUT()
        
        expectActivate(
            sut,
            toDeliver: [.success(.init(
                code: .init(codeValue: codeValue),
                phone: .init(phoneValue: phoneValue),
                sessionKey: .init(sessionKeyValue: sessionKeyValue),
                eventID: .init(eventIDValue: eventIDValue),
                sessionTTL: sessionTTL
                
            ))],
            on: {
                getCodeSpy.complete(with: .success(.init(
                    code: .init(codeValue: codeValue),
                    phone: .init(phoneValue: phoneValue)
                )))
                formSessionKeySpy.complete(with: .success(.init(
                    sessionKey: .init(sessionKeyValue: sessionKeyValue),
                    eventID: .init(eventIDValue: eventIDValue),
                    sessionTTL: sessionTTL
                )))
            }
        )
    }
    
    func test_activate_shouldNotDeliverGetCodeResultOnInstanceDeallocation() {
        
        var sut: SUT?
        let getCodeSpy: GetCodeSpy
        (sut, getCodeSpy, _) = makeSUT()
        var receivedResults = [SUT.ActivateResult]()
        
        sut?.activate { receivedResults.append($0) }
        sut = nil
        getCodeSpy.complete(with: anySuccess())
        
        XCTAssert(receivedResults.isEmpty)
    }
    
    func test_activate_shouldNotDeliverFormSessionKeyResultOnInstanceDeallocation() {
        
        var sut: SUT?
        let getCodeSpy: GetCodeSpy
        let formSessionKeySpy: FormSessionKeySpy
        (sut, getCodeSpy, formSessionKeySpy) = makeSUT()
        var receivedResults = [SUT.ActivateResult]()
        
        sut?.activate { receivedResults.append($0) }
        getCodeSpy.complete(with: anySuccess())
        sut = nil
        formSessionKeySpy.complete(with: anySuccess())
        
        XCTAssert(receivedResults.isEmpty)
    }
    
    // MARK: - Helpers
    
    private typealias SUT = CVVPINInitiateActivationService
    private typealias GetCodeSpy = Spy<Void, SUT.GetCodeSuccess, SUT.GetCodeResponseError>
    private typealias FormSessionKeySpy = Spy<SUT.Code, SUT.FormSessionKeySuccess, SUT.FormSessionKeyError>
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        getCodeSpy: GetCodeSpy,
        formSessionKeySpy: FormSessionKeySpy
    ) {
        let getCodeSpy = GetCodeSpy()
        let formSessionKeySpy = FormSessionKeySpy()
        let sut = SUT(
            getCode: getCodeSpy.process(completion:),
            formSessionKey: formSessionKeySpy.process(_:completion:)
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(getCodeSpy, file: file, line: line)
        trackForMemoryLeaks(formSessionKeySpy, file: file, line: line)
        
        return (sut, getCodeSpy, formSessionKeySpy)
    }
    
    private func expectActivate(
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
