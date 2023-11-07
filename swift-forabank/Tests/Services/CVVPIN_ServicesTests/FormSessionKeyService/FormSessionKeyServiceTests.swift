//
//  FormSessionKeyServiceTests.swift
//  
//
//  Created by Igor Malyarov on 04.11.2023.
//

import CVVPIN_Services
import XCTest

final class FormSessionKeyServiceTests: XCTestCase {
    
    func test_init_shouldNotCallCollaborators() {
        
        let (_, loadCodeSpy, makeJSONSpy, processSpy, makeSessionKeySpy) = makeSUT()
        
        XCTAssertNoDiff(loadCodeSpy.callCount, 0)
        XCTAssertNoDiff(makeJSONSpy.callCount, 0)
        XCTAssertNoDiff(processSpy.callCount, 0)
        XCTAssertNoDiff(makeSessionKeySpy.callCount, 0)
    }
    
    func test_formSessionKey_shouldDeliverErrorOnLoadCodeFailure() {
        
        let (sut, loadCodeSpy, _, _, _) = makeSUT()
        
        expect(sut, toDeliver: [.failure(.serviceError(.missingCode))], on: {
            
            loadCodeSpy.complete(with: .failure(anyError()))
        })
    }
    
    func test_formSessionKey_shouldDeliverErrorOnMakeJSONFailure() {
        
        let (sut, loadCodeSpy, makeJSONSpy, _, _) = makeSUT()
        
        expect(sut, toDeliver: [.failure(.serviceError(.makeJSONFailure))], on: {
            
            loadCodeSpy.complete(with: anySuccess())
            makeJSONSpy.complete(with: .failure(anyError()))
        })
    }
    
    func test_formSessionKey_shouldDeliverErrorOnProcessInvalidFailure() {
        
        let statusCode = 500
        let invalidData = anyData()
        let (sut, loadCodeSpy, makeJSONSpy, processSpy, _) = makeSUT()
        
        expect(sut, toDeliver: [
            .failure(.invalid(statusCode: statusCode, data: invalidData))
        ], on: {
            loadCodeSpy.complete(with: anySuccess())
            makeJSONSpy.complete(with: .success(anyData()))
            processSpy.complete(with: .failure(.invalid(statusCode: statusCode, data: invalidData)))
        })
    }
    
    func test_formSessionKey_shouldDeliverErrorOnProcessNetworkFailure() {
        
        let (sut, loadCodeSpy, makeJSONSpy, processSpy, _) = makeSUT()
        
        expect(sut, toDeliver: [.failure(.network)], on: {
            
            loadCodeSpy.complete(with: anySuccess())
            makeJSONSpy.complete(with: .success(anyData()))
            processSpy.complete(with: .failure(.network))
        })
    }
    
    func test_formSessionKey_shouldDeliverErrorOnProcessServerFailure() {
        
        let statusCode = 500
        let errorMessage = "Process Error"
        let (sut, loadCodeSpy, makeJSONSpy, processSpy, _) = makeSUT()
        
        expect(sut, toDeliver: [
            .failure(.server(statusCode: statusCode, errorMessage: errorMessage))
        ], on: {
            loadCodeSpy.complete(with: anySuccess())
            makeJSONSpy.complete(with: .success(anyData()))
            processSpy.complete(with: .failure(.server(statusCode: statusCode, errorMessage: errorMessage)))
        })
    }
    
    func test_formSessionKey_shouldDeliverErrorOnMakeSessionKeyFailure() {
        
        let (sut, loadCodeSpy, makeJSONSpy, processSpy, makeSessionKeySpy) = makeSUT()
        
        expect(sut, toDeliver: [
            .failure(.serviceError(.makeSessionKeyFailure))
        ], on: {
            loadCodeSpy.complete(with: anySuccess())
            makeJSONSpy.complete(with: .success(anyData()))
            processSpy.complete(with: anySuccess())
            makeSessionKeySpy.complete(with: .failure(anyError()))
        })
    }
    
    func test_formSessionKey_shouldDeliverSuccessOnSuccess() {
        
        let sessionKeyValue = anyData()
        let eventIDValue = UUID().uuidString
        let sessionTTL = 62
        let (sut, loadCodeSpy, makeJSONSpy, processSpy, makeSessionKeySpy) = makeSUT()
        
        expect(sut, toDeliver: [
            .success(.init(
                sessionKey: .init(sessionKeyValue: sessionKeyValue),
                eventID: .init(eventIDValue: eventIDValue),
                sessionTTL: sessionTTL
            ))
        ], on: {
            loadCodeSpy.complete(with: anySuccess())
            makeJSONSpy.complete(with: .success(anyData()))
            processSpy.complete(with: anySuccess(
                eventID: eventIDValue,
                sessionTTL: sessionTTL
            ))
            makeSessionKeySpy.complete(with: .success(.init(sessionKeyValue: sessionKeyValue)))
        })
    }
    
    func test_formSessionKey_shouldNotDeliverLoadCodeResultOnInstanceDeallocation() {
        
        var sut: SUT?
        let loadCodeSpy: LoadCodeSpy
        (sut, loadCodeSpy, _, _, _) = makeSUT()
        var receivedResults = [SUT.Result]()
        
        sut?.formSessionKey { receivedResults.append($0) }
        sut = nil
        loadCodeSpy.complete(with: anySuccess())
        
        XCTAssert(receivedResults.isEmpty)
    }
    
    func test_formSessionKey_shouldNotDeliverMakeJSONResultOnInstanceDeallocation() {
        
        var sut: SUT?
        let loadCodeSpy: LoadCodeSpy
        let makeJSONSpy: MakeJSONSpy
        (sut, loadCodeSpy, makeJSONSpy, _, _) = makeSUT()
        var receivedResults = [SUT.Result]()
        
        sut?.formSessionKey { receivedResults.append($0) }
        loadCodeSpy.complete(with: anySuccess())
        sut = nil
        makeJSONSpy.complete(with: .success(anyData()))
        
        XCTAssert(receivedResults.isEmpty)
    }
    
    func test_formSessionKey_shouldNotDeliverProcessResultOnInstanceDeallocation() {
        
        var sut: SUT?
        let loadCodeSpy: LoadCodeSpy
        let makeJSONSpy: MakeJSONSpy
        let processSpy: ProcessSpy
        (sut, loadCodeSpy, makeJSONSpy, processSpy, _) = makeSUT()
        var receivedResults = [SUT.Result]()
        
        sut?.formSessionKey { receivedResults.append($0) }
        loadCodeSpy.complete(with: anySuccess())
        makeJSONSpy.complete(with: .success(anyData()))
        sut = nil
        processSpy.complete(with: anySuccess())
        
        XCTAssert(receivedResults.isEmpty)
    }
    
    func test_formSessionKey_shouldNotDeliverMaskeSessionResultOnInstanceDeallocation() {
        
        var sut: SUT?
        let loadCodeSpy: LoadCodeSpy
        let makeJSONSpy: MakeJSONSpy
        let processSpy: ProcessSpy
        let makeSessionKeySpy: MakeSessionKeySpy
        (sut, loadCodeSpy, makeJSONSpy, processSpy, makeSessionKeySpy) = makeSUT()
        var receivedResults = [SUT.Result]()
        
        sut?.formSessionKey { receivedResults.append($0) }
        loadCodeSpy.complete(with: anySuccess())
        makeJSONSpy.complete(with: .success(anyData()))
        processSpy.complete(with: anySuccess())
        sut = nil
        makeSessionKeySpy.complete(with: .success(.init(sessionKeyValue: anyData())))
        
        XCTAssert(receivedResults.isEmpty)
    }
    
    // MARK: - Helpers
    
    private typealias SUT = FormSessionKeyService
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        loadCodeSpy: LoadCodeSpy,
        makeJSONSpy: MakeJSONSpy,
        processSpy: ProcessSpy,
        makeSessionKeySpy: MakeSessionKeySpy
    ) {
        let loadCodeSpy = LoadCodeSpy()
        let makeJSONSpy = MakeJSONSpy()
        let processSpy = ProcessSpy()
        let makeSessionKeySpy = MakeSessionKeySpy()
        
        let sut = SUT(
            loadCode: loadCodeSpy.load(completion:),
            makeSecretRequestJSON: makeJSONSpy.make(completion:),
            process: processSpy.process,
            makeSessionKey: makeSessionKeySpy.make
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(loadCodeSpy, file: file, line: line)
        trackForMemoryLeaks(makeJSONSpy, file: file, line: line)
        trackForMemoryLeaks(processSpy, file: file, line: line)
        trackForMemoryLeaks(makeSessionKeySpy, file: file, line: line)
        
        return (sut, loadCodeSpy, makeJSONSpy, processSpy, makeSessionKeySpy)
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
        
        sut.formSessionKey {
            
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
    
    private final class LoadCodeSpy {
        
        private(set) var completions = [SUT.CodeCompletion]()
        
        var callCount: Int { completions.count }
        
        func load(
            completion: @escaping SUT.CodeCompletion
        ) {
            completions.append(completion)
        }
        
        func complete(
            with result: SUT.CodeResult,
            at index: Int = 0
        ) {
            completions[index](result)
        }
    }
    
    private final class MakeJSONSpy {
        
        private(set) var completions = [SUT.SecretRequestJSONCompletion]()
        
        var callCount: Int { completions.count }
        
        func make(
            completion: @escaping SUT.SecretRequestJSONCompletion
        ) {
            completions.append(completion)
        }
        
        func complete(
            with result: SUT.SecretRequestJSONResult,
            at index: Int = 0
        ) {
            completions[index](result)
        }
    }
    
    private final class ProcessSpy {
        
        typealias Message = (payload: SUT.ProcessPayload, completion: SUT.ProcessCompletion)
        
        private(set) var messages = [Message]()
        
        var callCount: Int { messages.count }
        
        func process(
            _ payload: SUT.ProcessPayload,
            completion: @escaping SUT.ProcessCompletion
        ) {
            messages.append((payload, completion))
        }
        
        func complete(
            with result: SUT.ProcessResult,
            at index: Int = 0
        ) {
            messages[index].completion(result)
        }
    }
    
    private final class MakeSessionKeySpy {
        
        typealias Message = (payload: String, completion: SUT.MakeSessionKeyCompletion)
        
        private(set) var messages = [Message]()
        
        var callCount: Int { messages.count }
        
        func make(
            _ payload: String,
            completion: @escaping SUT.MakeSessionKeyCompletion
        ) {
            messages.append((payload, completion))
        }
        
        func complete(
            with result: SUT.MakeSessionKeyResult,
            at index: Int = 0
        ) {
            messages[index].completion(result)
        }
    }
}

private extension Array where Element == FormSessionKeyService.Result {
    
    func mapToEquatable() -> [FormSessionKeyService.Result.EquatableResult] {
        
        map { $0.mapToEquatable() }
    }
}

private extension FormSessionKeyService.Result {
    
    func mapToEquatable() -> EquatableResult {
        
        self
            .map(EquatableSuccess.init)
            .mapError(EquatableError.init)
    }
    
    typealias EquatableResult = Swift.Result<EquatableSuccess, EquatableError>
    
    struct EquatableSuccess: Equatable {
        
        let sessionKey: Data
        let eventID: String
        let sessionTTL: Int
        
        init(success: FormSessionKeyService.Success) {
            
            self.sessionKey = success.sessionKey.sessionKeyValue
            self.eventID = success.eventID.eventIDValue
            self.sessionTTL = success.sessionTTL
        }
    }
    
    enum EquatableError: Error & Equatable {
        
        case invalid(statusCode: Int, data: Data)
        case network
        case server(statusCode: Int, errorMessage: String)
        case serviceError(ServiceError)
        
        init(error: FormSessionKeyService.Error) {
            
            switch error {
            case let .invalid(statusCode: statusCode, data: data):
                self = .invalid(statusCode: statusCode, data: data)
                
            case .network:
                self = .network
                
            case let .server(statusCode: statusCode, errorMessage: errorMessage):
                self = .server(statusCode: statusCode, errorMessage: errorMessage)
                
            case let .serviceError(serviceError):
                switch serviceError {
                case .missingCode:
                    self = .serviceError(.missingCode)
                    
                case .makeJSONFailure:
                    self = .serviceError(.makeJSONFailure)
                    
                case .makeSessionKeyFailure:
                    self = .serviceError(.makeSessionKeyFailure)
                }
            }
        }
        
        enum ServiceError {
            
            case missingCode
            case makeJSONFailure
            case makeSessionKeyFailure
        }
    }
}

private func anySuccess(
    codeValue: String = UUID().uuidString
) -> FormSessionKeyService.CodeResult {
    
    .success(.init(codeValue: codeValue))
}

private func anySuccess(
    publicServerSessionKey: String = UUID().uuidString,
    eventID: String = UUID().uuidString,
    sessionTTL: Int = 31
) -> FormSessionKeyService.ProcessResult {
    
    .success(
        .init(
            publicServerSessionKey: publicServerSessionKey,
            eventID: eventID,
            sessionTTL: sessionTTL
        )
    )
}
