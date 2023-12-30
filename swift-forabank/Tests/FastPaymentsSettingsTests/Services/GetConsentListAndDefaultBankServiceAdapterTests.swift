//
//  GetConsentListAndDefaultBankServiceAdapterTests.swift
//
//
//  Created by Igor Malyarov on 30.12.2023.
//

import Tagged

#warning("keep to preserve API; move to compsition root")
extension ComposedGetConsentListAndDefaultBankService: GetConsentListAndDefaultBankService {}

final class GetConsentListAndDefaultBankServiceAdapter {
    
    typealias Service = GetConsentListAndDefaultBankService
    
    typealias LoadCompletion = (DefaultBank) -> Void
    typealias Load = (@escaping LoadCompletion) -> Void
    
    private let service: Service
    private let load: Load
    
    init(
        service: Service,
        load: @escaping Load
    ) {
        self.service = service
        self.load = load
    }
}

extension GetConsentListAndDefaultBankServiceAdapter {
    
    typealias GetConsentListAndDefaultBankResult = Result<GetConsentListAndDefaultBank, GetConsentListAndDefaultBankError>
    typealias Completion = (GetConsentListAndDefaultBankResult) -> Void
    
    func process(
        _ payload: PhoneNumber,
        completion: @escaping Completion
    ) {
        service.process(payload) { [weak self] results in
            
            guard let self else { return }
            
            switch (results.consentListResult, results.defaultBankResult) {
                
            case let (.success(consentList), .success(defaultBank)):
                completion(.success(.init(
                    consentList: consentList,
                    defaultBank: defaultBank
                )))
                
            case let (.failure(.connectivity), .success(defaultBank)):
                completion(.success(.init(
                    consentList: [],
                    defaultBank: defaultBank
                )))
                
            case let (
                .failure(.server(_, errorMessage: errorMessage)),
                .success(defaultBank)
            ):
                completion(.failure(.server(
                    message: errorMessage,
                    .init(consentList: [], defaultBank: defaultBank)
                )))
                
            case let (
                .failure(.connectivity),
                .failure(defaultBankError)
            ):
                handleGetDefaultBankError([], defaultBankError, completion)
                
            case let (
                .failure(.server(_, errorMessage: errorMessage)),
                .failure(.connectivity)
            ),
                let (
                    .failure(.server(_, errorMessage: errorMessage)),
                    .failure(.server)
                ):
                handleErrors(errorMessage, completion)
                
            case let (
                .failure(.server),
                .failure(.limit(message: message))
            ):
                // defaultBankError has higher priority, consentListError is ignored
                handleLimit(message, completion)
                
            case let (.success(consentList), .failure(defaultBankError)):
                handleGetDefaultBankError(consentList, defaultBankError, completion)
            }
        }
    }
    
    private func handleErrors(
        _ errorMessage: String,
        _ completion: @escaping Completion
    ) {
        load { [weak self] defaultBank in
            
            guard self != nil else { return }
            
            completion(.failure(.server(
                message: errorMessage,
                .init(consentList: [], defaultBank: defaultBank)
            )))
        }
    }
    
    private func handleLimit(
        _ message: String,
        _ completion: @escaping Completion
    ) {
        load { [weak self] defaultBank in
            
            guard self != nil else { return }
            
            completion(.failure(.limit(
                message: message,
                .init(consentList: [], defaultBank: defaultBank)
            )))
        }
    }
    
    private func handleGetDefaultBankError(
        _ consentList: ConsentList,
        _ defaultBankError: GetDefaultBankError,
        _ completion: @escaping Completion
    ) {
        load { [weak self] defaultBank in
            
            guard self != nil else { return }
            
            switch defaultBankError {
            case .connectivity, .server:
                completion(.success(.init(
                    consentList: consentList,
                    defaultBank: defaultBank
                )))
                
            case let .limit(message):
                completion(.failure(.limit(
                    message: message,
                    .init(
                        consentList: consentList,
                        defaultBank: defaultBank
                    )
                )))
            }
        }
    }
}

extension GetConsentListAndDefaultBankServiceAdapter {
    
    enum GetConsentListAndDefaultBankError: Error, Equatable {
        
        case limit(message: String, GetConsentListAndDefaultBank)
        case server(message: String, GetConsentListAndDefaultBank)
    }
}

import XCTest

final class GetConsentListAndDefaultBankServiceAdapterTests: XCTestCase {
    
    func test_init_shouldNotCallCollaborators() {
        
        let (_, serviceSpy, loadSpy) = makeSUT()
        
        XCTAssertNoDiff(serviceSpy.callCount, 0)
        XCTAssertNoDiff(loadSpy.callCount, 0)
    }
    
    func test_process_shouldNotCallLoadOnSuccesses() {
        
        let (sut, serviceSpy, loadSpy) = makeSUT()
        
        sut.process(anyPhoneNumber()) { _  in }
        serviceSpy.complete(with: .init(
            consentListResult: .success([]),
            defaultBankResult: .success(true)
        ))
        
        XCTAssertNoDiff(loadSpy.callCount, 0)
    }
    
    func test_process_shouldDeliverSameResultsOnSuccesses_empty() {
        
        let consentList = makeConsentList(count: 0)
        let defaultBank = anyDefaultBank()
        let (sut, serviceSpy, _) = makeSUT()
        
        expect(sut, toDeliver: .success(.init(
            consentList: consentList,
            defaultBank: defaultBank
        ))) {
            serviceSpy.complete(with: .init(
                consentListResult: .success(consentList),
                defaultBankResult: .success(defaultBank)
            ))
        }
    }
    
    func test_process_shouldDeliverSameResultsOnSuccesses_one() {
        
        let consentList = makeConsentList(count: 1)
        let defaultBank = anyDefaultBank()
        let (sut, serviceSpy, _) = makeSUT()
        
        expect(sut, toDeliver: .success(.init(
            consentList: consentList,
            defaultBank: defaultBank
        ))) {
            serviceSpy.complete(with: .init(
                consentListResult: .success(consentList),
                defaultBankResult: .success(defaultBank)
            ))
        }
    }
    
    func test_process_shouldDeliverSameResultsOnSuccesses_many() {
        
        let consentList = makeConsentList(count: 2)
        let defaultBank = anyDefaultBank()
        let (sut, serviceSpy, _) = makeSUT()
        
        expect(sut, toDeliver: .success(.init(
            consentList: consentList,
            defaultBank: defaultBank
        ))) {
            serviceSpy.complete(with: .init(
                consentListResult: .success(consentList),
                defaultBankResult: .success(defaultBank)
            ))
        }
    }
    
    func test_process_shouldCallLoadOnDefaultBankFailure_empty_connectivity() {
        
        let consentList = makeConsentList(count: 0)
        let defaultBankError: GetDefaultBankError = .connectivity
        let (sut, serviceSpy, loadSpy) = makeSUT()
        
        sut.process(anyPhoneNumber()) { _ in }
        serviceSpy.complete(with: .init(
            consentListResult: .success(consentList),
            defaultBankResult: .failure(defaultBankError)
        ))
        
        XCTAssertNoDiff(loadSpy.callCount, 1)
    }
    
    func test_process_shouldCallLoadOnDefaultBankFailure_one_connectivity() {
        
        let consentList = makeConsentList(count: 1)
        let defaultBankError: GetDefaultBankError = .connectivity
        let (sut, serviceSpy, loadSpy) = makeSUT()
        
        sut.process(anyPhoneNumber()) { _ in }
        serviceSpy.complete(with: .init(
            consentListResult: .success(consentList),
            defaultBankResult: .failure(defaultBankError)
        ))
        
        XCTAssertNoDiff(loadSpy.callCount, 1)
    }
    
    func test_process_shouldCallLoadOnDefaultBankFailure_many_connectivity() {
        
        let consentList = makeConsentList(count: 2)
        let defaultBankError: GetDefaultBankError = .connectivity
        let (sut, serviceSpy, loadSpy) = makeSUT()
        
        sut.process(anyPhoneNumber()) { _ in }
        serviceSpy.complete(with: .init(
            consentListResult: .success(consentList),
            defaultBankResult: .failure(defaultBankError)
        ))
        
        XCTAssertNoDiff(loadSpy.callCount, 1)
    }
    
    func test_process_shouldCallLoadOnDefaultBankFailure_empty_limit() {
        
        let consentList = makeConsentList(count: 0)
        let defaultBankError: GetDefaultBankError = .limit(message: UUID().uuidString)
        let (sut, serviceSpy, loadSpy) = makeSUT()
        
        sut.process(anyPhoneNumber()) { _ in }
        serviceSpy.complete(with: .init(
            consentListResult: .success(consentList),
            defaultBankResult: .failure(defaultBankError)
        ))
        
        XCTAssertNoDiff(loadSpy.callCount, 1)
    }
    
    func test_process_shouldCallLoadOnDefaultBankFailure_one_limit() {
        
        let consentList = makeConsentList(count: 1)
        let defaultBankError: GetDefaultBankError = .limit(message: UUID().uuidString)
        let (sut, serviceSpy, loadSpy) = makeSUT()
        
        sut.process(anyPhoneNumber()) { _ in }
        serviceSpy.complete(with: .init(
            consentListResult: .success(consentList),
            defaultBankResult: .failure(defaultBankError)
        ))
        
        XCTAssertNoDiff(loadSpy.callCount, 1)
    }
    
    func test_process_shouldCallLoadOnDefaultBankFailure_many_limit() {
        
        let consentList = makeConsentList(count: 2)
        let defaultBankError: GetDefaultBankError = .limit(message: UUID().uuidString)
        let (sut, serviceSpy, loadSpy) = makeSUT()
        
        sut.process(anyPhoneNumber()) { _ in }
        serviceSpy.complete(with: .init(
            consentListResult: .success(consentList),
            defaultBankResult: .failure(defaultBankError)
        ))
        
        XCTAssertNoDiff(loadSpy.callCount, 1)
    }
    
    func test_process_shouldCallLoadOnDefaultBankFailure_empty_server() {
        
        let consentList = makeConsentList(count: 0)
        let defaultBankError: GetDefaultBankError = .server(statusCode: 123, errorMessage: UUID().uuidString)
        let (sut, serviceSpy, loadSpy) = makeSUT()
        
        sut.process(anyPhoneNumber()) { _ in }
        serviceSpy.complete(with: .init(
            consentListResult: .success(consentList),
            defaultBankResult: .failure(defaultBankError)
        ))
        
        XCTAssertNoDiff(loadSpy.callCount, 1)
    }
    
    func test_process_shouldCallLoadOnDefaultBankFailure_one_server() {
        
        let consentList = makeConsentList(count: 1)
        let defaultBankError: GetDefaultBankError = .server(statusCode: 123, errorMessage: UUID().uuidString)
        let (sut, serviceSpy, loadSpy) = makeSUT()
        
        sut.process(anyPhoneNumber()) { _ in }
        serviceSpy.complete(with: .init(
            consentListResult: .success(consentList),
            defaultBankResult: .failure(defaultBankError)
        ))
        
        XCTAssertNoDiff(loadSpy.callCount, 1)
    }
    
    func test_process_shouldCallLoadOnDefaultBankFailure_many_server() {
        
        let consentList = makeConsentList(count: 2)
        let defaultBankError: GetDefaultBankError = .server(statusCode: 123, errorMessage: UUID().uuidString)
        let (sut, serviceSpy, loadSpy) = makeSUT()
        
        sut.process(anyPhoneNumber()) { _ in }
        serviceSpy.complete(with: .init(
            consentListResult: .success(consentList),
            defaultBankResult: .failure(defaultBankError)
        ))
        
        XCTAssertNoDiff(loadSpy.callCount, 1)
    }
    
    func test_process_shouldDeliverLoadedDefaultBankOnDefaultBankFailure_empty_connectivity() {
        
        let consentList = makeConsentList(count: 0)
        let defaultBankError: GetDefaultBankError = .connectivity
        let loadedDefaultBank = anyDefaultBank()
        let (sut, serviceSpy, loadSpy) = makeSUT()
        
        expect(sut, toDeliver: .success(.init(
            consentList: consentList,
            defaultBank: loadedDefaultBank
        ))) {
            serviceSpy.complete(with: .init(
                consentListResult: .success(consentList),
                defaultBankResult: .failure(defaultBankError)
            ))
            loadSpy.complete(with: loadedDefaultBank)
        }
    }
    
    func test_process_shouldDeliverLoadedDefaultBankOnDefaultBankFailure_one_connectivity_false() {
        
        let consentList = makeConsentList(count: 1)
        let defaultBankError: GetDefaultBankError = .connectivity
        let loadedDefaultBank = anyDefaultBank()
        let (sut, serviceSpy, loadSpy) = makeSUT()
        
        expect(sut, toDeliver: .success(.init(
            consentList: consentList,
            defaultBank: loadedDefaultBank
        ))) {
            serviceSpy.complete(with: .init(
                consentListResult: .success(consentList),
                defaultBankResult: .failure(defaultBankError)
            ))
            loadSpy.complete(with: loadedDefaultBank)
        }
    }
    
    func test_process_shouldDeliverLoadedDefaultBankOnDefaultBankFailure_many_connectivity() {
        
        let consentList = makeConsentList(count: 2)
        let defaultBankError: GetDefaultBankError = .connectivity
        let loadedDefaultBank = anyDefaultBank()
        let (sut, serviceSpy, loadSpy) = makeSUT()
        
        expect(sut, toDeliver: .success(.init(
            consentList: consentList,
            defaultBank: loadedDefaultBank
        ))) {
            serviceSpy.complete(with: .init(
                consentListResult: .success(consentList),
                defaultBankResult: .failure(defaultBankError)
            ))
            loadSpy.complete(with: loadedDefaultBank)
        }
    }
    
    func test_process_shouldDeliverLoadedDefaultBankOnDefaultBankFailure_empty_limit() {
        
        let consentList = makeConsentList(count: 0)
        let message = UUID().uuidString
        let defaultBankError: GetDefaultBankError = .limit(message: message)
        let loadedDefaultBank = anyDefaultBank()
        let (sut, serviceSpy, loadSpy) = makeSUT()
        
        expect(sut, toDeliver: .failure(.limit(
            message: message,
            .init(
                consentList: consentList,
                defaultBank: loadedDefaultBank
            )
        ))) {
            serviceSpy.complete(with: .init(
                consentListResult: .success(consentList),
                defaultBankResult: .failure(defaultBankError)
            ))
            loadSpy.complete(with: loadedDefaultBank)
        }
    }
    
    func test_process_shouldDeliverLoadedDefaultBankOnDefaultBankFailure_one_limit() {
        
        let consentList = makeConsentList(count: 1)
        let message = UUID().uuidString
        let defaultBankError: GetDefaultBankError = .limit(message: message)
        let loadedDefaultBank = anyDefaultBank()
        let (sut, serviceSpy, loadSpy) = makeSUT()
        
        expect(sut, toDeliver: .failure(.limit(
            message: message,
            .init(
                consentList: consentList,
                defaultBank: loadedDefaultBank
            )
        ))) {
            serviceSpy.complete(with: .init(
                consentListResult: .success(consentList),
                defaultBankResult: .failure(defaultBankError)
            ))
            loadSpy.complete(with: loadedDefaultBank)
        }
    }
    
    func test_process_shouldDeliverLoadedDefaultBankOnDefaultBankFailure_many_limit() {
        
        let consentList = makeConsentList(count: 2)
        let message = UUID().uuidString
        let defaultBankError: GetDefaultBankError = .limit(message: message)
        let loadedDefaultBank = anyDefaultBank()
        let (sut, serviceSpy, loadSpy) = makeSUT()
        
        expect(sut, toDeliver: .failure(.limit(
            message: message,
            .init(
                consentList: consentList,
                defaultBank: loadedDefaultBank
            )
        ))) {
            serviceSpy.complete(with: .init(
                consentListResult: .success(consentList),
                defaultBankResult: .failure(defaultBankError)
            ))
            loadSpy.complete(with: loadedDefaultBank)
        }
    }
    
    func test_process_shouldDeliverLoadedDefaultBankOnDefaultBankFailure_empty_server() {
        
        let consentList = makeConsentList(count: 0)
        let defaultBankError: GetDefaultBankError = .server(statusCode: 123, errorMessage: UUID().uuidString)
        let loadedDefaultBank = anyDefaultBank()
        let (sut, serviceSpy, loadSpy) = makeSUT()
        
        expect(sut, toDeliver: .success(.init(
            consentList: consentList,
            defaultBank: loadedDefaultBank
        ))) {
            serviceSpy.complete(with: .init(
                consentListResult: .success(consentList),
                defaultBankResult: .failure(defaultBankError)
            ))
            loadSpy.complete(with: loadedDefaultBank)
        }
    }
    
    func test_process_shouldDeliverLoadedDefaultBankOnDefaultBankFailure_one_server() {
        
        let consentList = makeConsentList(count: 1)
        let defaultBankError: GetDefaultBankError = .server(statusCode: 123, errorMessage: UUID().uuidString)
        let loadedDefaultBank = anyDefaultBank()
        let (sut, serviceSpy, loadSpy) = makeSUT()
        
        expect(sut, toDeliver: .success(.init(
            consentList: consentList,
            defaultBank: loadedDefaultBank
        ))) {
            serviceSpy.complete(with: .init(
                consentListResult: .success(consentList),
                defaultBankResult: .failure(defaultBankError)
            ))
            loadSpy.complete(with: loadedDefaultBank)
        }
    }
    
    func test_process_shouldDeliverLoadedDefaultBankOnDefaultBankFailure_many_server() {
        
        let consentList = makeConsentList(count: 2)
        let defaultBankError: GetDefaultBankError = .server(statusCode: 123, errorMessage: UUID().uuidString)
        let loadedDefaultBank = anyDefaultBank()
        let (sut, serviceSpy, loadSpy) = makeSUT()
        
        expect(sut, toDeliver: .success(.init(
            consentList: consentList,
            defaultBank: loadedDefaultBank
        ))) {
            serviceSpy.complete(with: .init(
                consentListResult: .success(consentList),
                defaultBankResult: .failure(defaultBankError)
            ))
            loadSpy.complete(with: loadedDefaultBank)
        }
    }
    
    func test_process_shouldDeliverEmptyConsentListOnGetConsentListFailure_connectivity_defaultBankSuccess() {
        
        let consentListError: GetConsentListError = .connectivity
        let defaultBank = anyDefaultBank()
        let (sut, serviceSpy, _) = makeSUT()
        
        expect(sut, toDeliver: .success(.init(
            consentList: [],
            defaultBank: defaultBank
        ))) {
            serviceSpy.complete(with: .init(
                consentListResult: .failure(consentListError),
                defaultBankResult: .success(defaultBank)
            ))
        }
    }
    
    func test_process_shouldDeliverEmptyConsentListOnGetConsentListFailure_connectivity_defaultBankFailure_connectivity() {
        
        let consentListError: GetConsentListError = .connectivity
        let defaultBankError: GetDefaultBankError = .connectivity
        let loadedDefaultBank = anyDefaultBank()
        let (sut, serviceSpy, loadSpy) = makeSUT()
        
        expect(sut, toDeliver: .success(.init(
            consentList: [],
            defaultBank: loadedDefaultBank
        ))) {
            serviceSpy.complete(with: .init(
                consentListResult: .failure(consentListError),
                defaultBankResult: .failure(defaultBankError)
            ))
            loadSpy.complete(with: loadedDefaultBank)
        }
    }
    
    func test_process_shouldDeliverEmptyConsentListOnGetConsentListFailure_connectivity_defaultBankFailure_limit() {
        
        let consentListError: GetConsentListError = .connectivity
        let message = UUID().uuidString
        let defaultBankError: GetDefaultBankError = .limit(message: message)
        let loadedDefaultBank = anyDefaultBank()
        let (sut, serviceSpy, loadSpy) = makeSUT()
        
        expect(sut, toDeliver: .failure(.limit(
            message: message,
            .init(consentList: [], defaultBank: loadedDefaultBank)
        ))) {
            serviceSpy.complete(with: .init(
                consentListResult: .failure(consentListError),
                defaultBankResult: .failure(defaultBankError)
            ))
            loadSpy.complete(with: loadedDefaultBank)
        }
    }
    
    func test_process_shouldDeliverEmptyConsentListOnGetConsentListFailure_connectivity_defaultBankFailure_server() {
        
        let consentListError: GetConsentListError = .connectivity
        let defaultBankError: GetDefaultBankError = .server(statusCode: 123, errorMessage: UUID().uuidString)
        let loadedDefaultBank = anyDefaultBank()
        let (sut, serviceSpy, loadSpy) = makeSUT()
        
        expect(sut, toDeliver: .success(.init(
            consentList: [],
            defaultBank: loadedDefaultBank
        ))) {
            serviceSpy.complete(with: .init(
                consentListResult: .failure(consentListError),
                defaultBankResult: .failure(defaultBankError)
            ))
            loadSpy.complete(with: loadedDefaultBank)
        }
    }
    
    func test_process_shouldDeliverErrorWithEmptyConsentListOnGetConsentListFailure_server_defaultBankSuccess_b3c1c2() {
        
        let errorMessage = UUID().uuidString
        let consentListError: GetConsentListError = .server(statusCode: 321, errorMessage: errorMessage)
        let defaultBank = anyDefaultBank()
        let (sut, serviceSpy, _) = makeSUT()
        
        expect(sut, toDeliver: .failure(.server(
            message: errorMessage,
            .init(consentList: [],defaultBank: defaultBank)
        ))) {
            serviceSpy.complete(with: .init(
                consentListResult: .failure(consentListError),
                defaultBankResult: .success(defaultBank)
            ))
        }
    }
    
    func test_process_shouldDeliverEmptyConsentListOnGetConsentListFailure_server_defaultBankFailure_connectivity_b3c5() {
        
        let errorMessage = UUID().uuidString
        let consentListError: GetConsentListError = .server(statusCode: 321, errorMessage: errorMessage)
        let defaultBankError: GetDefaultBankError = .connectivity
        let loadedDefaultBank = anyDefaultBank()
        let (sut, serviceSpy, loadSpy) = makeSUT()
        
        expect(sut, toDeliver: .failure(.server(
            message: errorMessage,
            .init(consentList: [], defaultBank: loadedDefaultBank)
        ))) {
            serviceSpy.complete(with: .init(
                consentListResult: .failure(consentListError),
                defaultBankResult: .failure(defaultBankError)
            ))
            loadSpy.complete(with: loadedDefaultBank)
        }
    }
    
    func test_process_shouldDeliverEmptyConsentListOnGetConsentListFailure_server_defaultBankFailure_limit_b3c3() {
        
        let errorMessage = UUID().uuidString
        let consentListError: GetConsentListError = .server(statusCode: 321, errorMessage: errorMessage)
        let message = UUID().uuidString
        let defaultBankError: GetDefaultBankError = .limit(message: message)
        let loadedDefaultBank = anyDefaultBank()
        let (sut, serviceSpy, loadSpy) = makeSUT()
        
        expect(sut, toDeliver: .failure(.limit(
            message: message,
            .init(
                consentList: [],
                defaultBank: loadedDefaultBank
            )
        ))) {
            serviceSpy.complete(with: .init(
                consentListResult: .failure(consentListError),
                defaultBankResult: .failure(defaultBankError)
            ))
            loadSpy.complete(with: loadedDefaultBank)
        }
    }
    
    func test_process_shouldDeliverEmptyConsentListOnGetConsentListFailure_server_defaultBankFailure_server_b3c4() {
        
        let errorMessage = UUID().uuidString
        let consentListError: GetConsentListError = .server(statusCode: 321, errorMessage: errorMessage)
        let defaultBankError: GetDefaultBankError = .server(statusCode: 123, errorMessage: UUID().uuidString)
        let loadedDefaultBank = anyDefaultBank()
        let (sut, serviceSpy, loadSpy) = makeSUT()
        
        expect(sut, toDeliver: .failure(.server(
            message: errorMessage,
            .init(consentList: [], defaultBank: loadedDefaultBank)
        ))) {
            serviceSpy.complete(with: .init(
                consentListResult: .failure(consentListError),
                defaultBankResult: .failure(defaultBankError)
            ))
            loadSpy.complete(with: loadedDefaultBank)
        }
    }
    
#warning("add tests for consent list failure")
    // MARK: - Helpers
    
    private typealias SUT = GetConsentListAndDefaultBankServiceAdapter
    private typealias ServiceSpy = ResponseSpy<PhoneNumber, GetConsentListAndDefaultBankResults>
    private typealias LoadSpy = ResponseSpy<Void, DefaultBank>
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        serviceSpy: ServiceSpy,
        loadSpy: LoadSpy
    ) {
        let serviceSpy = ServiceSpy()
        let loadSpy = LoadSpy()
        let sut = SUT(
            service: serviceSpy,
            load: loadSpy.process
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(serviceSpy, file: file, line: line)
        trackForMemoryLeaks(loadSpy, file: file, line: line)
        
        return (sut, serviceSpy, loadSpy)
    }
    
    private func expect(
        _ sut: SUT,
        with payload: PhoneNumber = anyPhoneNumber(),
        toDeliver expectedResult: SUT.GetConsentListAndDefaultBankResult,
        on action: @escaping () -> Void,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let exp = expectation(description: "wait for completion")
        
        sut.process(payload) { receivedResult in
            
            assert(receivedResult, equals: expectedResult, file: file, line: line)
            
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 1.0)
    }
}

extension ResponseSpy: GetConsentListAndDefaultBankService
where Payload == PhoneNumber,
      Response == GetConsentListAndDefaultBankResults {}
