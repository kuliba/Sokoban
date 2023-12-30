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
                
            case let (.success(consentList), .failure(defaultBankError)):
                handleGetDefaultBankError(consentList, defaultBankError, completion)
                
            default:
                fatalError()
            }
        }
    }
    
    private func handleGetDefaultBankError(
        _ consentList: [BankID],
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
                break
            }
        }
    }
}

extension GetConsentListAndDefaultBankServiceAdapter {
    
    enum GetConsentListAndDefaultBankError: Error, Equatable {
        
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
    
    func test_process_shouldDeliverSameResultsOnSuccesses_empty_true() {
        
        let consentList = makeConsentList(count: 0)
        let defaultBank: DefaultBank = true
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
    
    func test_process_shouldDeliverSameResultsOnSuccesses_empty_false() {
        
        let consentList = makeConsentList(count: 0)
        let defaultBank: DefaultBank = false
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
    
    func test_process_shouldDeliverSameResultsOnSuccesses_one_true() {
        
        let consentList = makeConsentList(count: 1)
        let defaultBank: DefaultBank = true
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
    
    func test_process_shouldDeliverSameResultsOnSuccesses_one_false() {
        
        let consentList = makeConsentList(count: 1)
        let defaultBank: DefaultBank = false
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
    
    func test_process_shouldDeliverSameResultsOnSuccesses_many_true() {
        
        let consentList = makeConsentList(count: 2)
        let defaultBank: DefaultBank = true
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
    
    func test_process_shouldDeliverSameResultsOnSuccesses_many_false() {
        
        let consentList = makeConsentList(count: 2)
        let defaultBank: DefaultBank = false
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
    
    func test_process_shouldDeliverLoadedDefaultBankOnDefaultBankFailure_empty_connectivity_false() {
        
        let consentList = makeConsentList(count: 0)
        let defaultBankError: GetDefaultBankError = .connectivity
        let loadedDefaultBank: DefaultBank = false
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
        let loadedDefaultBank: DefaultBank = false
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
    
    func test_process_shouldDeliverLoadedDefaultBankOnDefaultBankFailure_many_connectivity_false() {
        
        let consentList = makeConsentList(count: 2)
        let defaultBankError: GetDefaultBankError = .connectivity
        let loadedDefaultBank: DefaultBank = false
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
    func test_process_shouldDeliverLoadedDefaultBankOnDefaultBankFailure_empty_server_false() {
        
        let consentList = makeConsentList(count: 0)
        let defaultBankError: GetDefaultBankError = .server(statusCode: 123, errorMessage: UUID().uuidString)
        let loadedDefaultBank: DefaultBank = false
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
    
    func test_process_shouldDeliverLoadedDefaultBankOnDefaultBankFailure_one_server_false() {
        
        let consentList = makeConsentList(count: 1)
        let defaultBankError: GetDefaultBankError = .server(statusCode: 123, errorMessage: UUID().uuidString)
        let loadedDefaultBank: DefaultBank = false
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
    
    func test_process_shouldDeliverLoadedDefaultBankOnDefaultBankFailure_many_server_false() {
        
        let consentList = makeConsentList(count: 2)
        let defaultBankError: GetDefaultBankError = .server(statusCode: 123, errorMessage: UUID().uuidString)
        let loadedDefaultBank: DefaultBank = false
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
