//
//  GetConsentListAndDefaultBankServiceAdapterTests.swift
//
//
//  Created by Igor Malyarov on 30.12.2023.
//

import FastPaymentsSettings
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
    
    func test_process_shouldNotDeliverResultsOnInstanceDeallocation() {
        
        var sut: SUT?
        let serviceSpy: ServiceSpy
        (sut, serviceSpy, _) = makeSUT()
        var result: SUT.GetConsentListAndDefaultBankResult?
        
        sut?.process(anyPhoneNumber()) { result = $0 }
        sut = nil
        serviceSpy.complete(with: .init(
            consentListResult: .success([]),
            defaultBankResult: .success(true)
        ))
        
        XCTAssertNil(result)
    }
    
    func test_process_shouldDeliverSameResultsOnSuccesses_empty_b1c1c2() {
        
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
    
    func test_process_shouldDeliverSameResultsOnSuccesses_one_b2c1c2() {
        
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
    
    func test_process_shouldDeliverSameResultsOnSuccesses_many_b2c1c2() {
        
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
    
    func test_process_shouldCallLoadOnDefaultBankFailure_empty_connectivity_b1c5() {
        
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
    
    func test_process_shouldCallLoadOnDefaultBankFailure_one_connectivity_b2c5() {
        
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
    
    func test_process_shouldCallLoadOnDefaultBankFailure_many_connectivity_b2c5() {
        
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
    
    func test_process_shouldCallLoadOnDefaultBankFailure_empty_limit_b1c3() {
        
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
    
    func test_process_shouldNotDeliverLoadResultOnInstanceDeallocation_b1c3() {
        
        var sut: SUT?
        let serviceSpy: ServiceSpy
        let loadSpy: LoadSpy
        (sut, serviceSpy, loadSpy) = makeSUT()
        var result: SUT.GetConsentListAndDefaultBankResult?
        
        sut?.process(anyPhoneNumber()) { result = $0 }
        serviceSpy.complete(with: .init(
            consentListResult: .success([]),
            defaultBankResult: .failure(.limit(message: UUID().uuidString))
        ))
        sut = nil
        loadSpy.complete(with: true)
        
        XCTAssertNil(result)
    }
    
    func test_process_shouldCallLoadOnDefaultBankFailure_one_limit_b2c3() {
        
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
    
    func test_process_shouldCallLoadOnDefaultBankFailure_many_limit_b2c3() {
        
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
    
    func test_process_shouldCallLoadOnDefaultBankFailure_empty_server_b1c4() {
        
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
    
    func test_process_shouldCallLoadOnDefaultBankFailure_one_serverb2c4() {
        
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
    
    func test_process_shouldCallLoadOnDefaultBankFailure_many_server_b2c4() {
        
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
    
    func test_process_shouldDeliverLoadedDefaultBankOnDefaultBankFailure_empty_connectivity_b1c5() {
        
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
    
    func test_process_shouldDeliverLoadedDefaultBankOnDefaultBankFailure_one_connectivity_b2c5() {
        
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
    
    func test_process_shouldDeliverLoadedDefaultBankOnDefaultBankFailure_many_connectivity_b2c5() {
        
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
    
    func test_process_shouldDeliverLoadedDefaultBankOnDefaultBankFailure_empty_limit_b1c3() {
        
        let consentList = makeConsentList(count: 0)
        let message = UUID().uuidString
        let defaultBankError: GetDefaultBankError = .limit(message: message)
        let loadedDefaultBank = anyDefaultBank()
        let (sut, serviceSpy, loadSpy) = makeSUT()
        
        expect(sut, toDeliver: .failure(.init(
            getConsentListAndDefaultBank: .init(
                consentList: consentList,
                defaultBank: loadedDefaultBank
            ),
            message: message,
            type: .limit
        ))) {
            serviceSpy.complete(with: .init(
                consentListResult: .success(consentList),
                defaultBankResult: .failure(defaultBankError)
            ))
            loadSpy.complete(with: loadedDefaultBank)
        }
    }
    
    func test_process_shouldDeliverLoadedDefaultBankOnDefaultBankFailure_one_limit_b2c3() {
        
        let consentList = makeConsentList(count: 1)
        let message = UUID().uuidString
        let defaultBankError: GetDefaultBankError = .limit(message: message)
        let loadedDefaultBank = anyDefaultBank()
        let (sut, serviceSpy, loadSpy) = makeSUT()
        
        expect(sut, toDeliver: .failure(.init(
            getConsentListAndDefaultBank: .init(
                consentList: consentList,
                defaultBank: loadedDefaultBank
            ),
            message: message,
            type: .limit
        ))) {
            serviceSpy.complete(with: .init(
                consentListResult: .success(consentList),
                defaultBankResult: .failure(defaultBankError)
            ))
            loadSpy.complete(with: loadedDefaultBank)
        }
    }
    
    func test_process_shouldDeliverLoadedDefaultBankOnDefaultBankFailure_many_limit_b2c3() {
        
        let consentList = makeConsentList(count: 2)
        let message = UUID().uuidString
        let defaultBankError: GetDefaultBankError = .limit(message: message)
        let loadedDefaultBank = anyDefaultBank()
        let (sut, serviceSpy, loadSpy) = makeSUT()
        
        expect(sut, toDeliver: .failure(.init(
            getConsentListAndDefaultBank: .init(
                consentList: consentList,
                defaultBank: loadedDefaultBank
            ),
            message: message,
            type: .limit
        ))) {
            serviceSpy.complete(with: .init(
                consentListResult: .success(consentList),
                defaultBankResult: .failure(defaultBankError)
            ))
            loadSpy.complete(with: loadedDefaultBank)
        }
    }
    
    func test_process_shouldDeliverLoadedDefaultBankOnDefaultBankFailure_empty_server_b1c4() {
        
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
    
    func test_process_shouldDeliverLoadedDefaultBankOnDefaultBankFailure_one_server_b2c4() {
        
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
    
    func test_process_shouldDeliverLoadedDefaultBankOnDefaultBankFailure_many_server_b2c4() {
        
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
    
    func test_process_shouldDeliverEmptyConsentListOnGetConsentListFailure_connectivity_defaultBankSuccess_b4c1c2() {
        
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
    
    func test_process_shouldDeliverEmptyConsentListOnGetConsentListFailure_connectivity_defaultBankFailure_connectivity_b4c5() {
        
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
    
    func test_process_shouldDeliverEmptyConsentListOnGetConsentListFailure_connectivity_defaultBankFailure_limit_b4c3() {
        
        let consentListError: GetConsentListError = .connectivity
        let message = UUID().uuidString
        let defaultBankError: GetDefaultBankError = .limit(message: message)
        let loadedDefaultBank = anyDefaultBank()
        let (sut, serviceSpy, loadSpy) = makeSUT()
        
        expect(sut, toDeliver: .failure(.init(
            getConsentListAndDefaultBank: .init(
                consentList: [],
                defaultBank: loadedDefaultBank
            ),
            message: message,
            type: .limit
        ))) {
            serviceSpy.complete(with: .init(
                consentListResult: .failure(consentListError),
                defaultBankResult: .failure(defaultBankError)
            ))
            loadSpy.complete(with: loadedDefaultBank)
        }
    }
    
    func test_process_shouldDeliverEmptyConsentListOnGetConsentListFailure_connectivity_defaultBankFailure_server_b4c4() {
        
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
        
        expect(sut, toDeliver: .failure(.init(
            getConsentListAndDefaultBank: .init(
                consentList: [],
                defaultBank: defaultBank
            ),
            message: errorMessage,
            type: .server
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
        
        expect(sut, toDeliver: .failure(.init(
            getConsentListAndDefaultBank: .init(
                consentList: [],
                defaultBank: loadedDefaultBank
            ),
            message: errorMessage,
            type: .server
        ))) {
            serviceSpy.complete(with: .init(
                consentListResult: .failure(consentListError),
                defaultBankResult: .failure(defaultBankError)
            ))
            loadSpy.complete(with: loadedDefaultBank)
        }
    }
    
    func test_process_shouldNotDeliverLoadResultOnInstanceDeallocation_b3c5() {
        
        var sut: SUT?
        let serviceSpy: ServiceSpy
        let loadSpy: LoadSpy
        (sut, serviceSpy, loadSpy) = makeSUT()
        var result: SUT.GetConsentListAndDefaultBankResult?
        
        sut?.process(anyPhoneNumber()) { result = $0 }
        serviceSpy.complete(with: .init(
            consentListResult: .failure(.server(statusCode: 123, errorMessage: UUID().uuidString)),
            defaultBankResult: .failure(.connectivity)
        ))
        sut = nil
        loadSpy.complete(with: true)
        
        XCTAssertNil(result)
    }
    
    func test_process_shouldDeliverEmptyConsentListOnGetConsentListFailure_server_defaultBankFailure_limit_b3c3() {
        
        let errorMessage = UUID().uuidString
        let consentListError: GetConsentListError = .server(statusCode: 321, errorMessage: errorMessage)
        let message = UUID().uuidString
        let defaultBankError: GetDefaultBankError = .limit(message: message)
        let loadedDefaultBank = anyDefaultBank()
        let (sut, serviceSpy, loadSpy) = makeSUT()
        
        expect(sut, toDeliver: .failure(.init(
            getConsentListAndDefaultBank: .init(
                consentList: [],
                defaultBank: loadedDefaultBank
            ),
            message: message,
            type: .limit
        ))) {
            serviceSpy.complete(with: .init(
                consentListResult: .failure(consentListError),
                defaultBankResult: .failure(defaultBankError)
            ))
            loadSpy.complete(with: loadedDefaultBank)
        }
    }
    
    func test_process_shouldNotDeliverLoadResultOnInstanceDeallocation_b3c3() {
        
        var sut: SUT?
        let serviceSpy: ServiceSpy
        let loadSpy: LoadSpy
        (sut, serviceSpy, loadSpy) = makeSUT()
        var result: SUT.GetConsentListAndDefaultBankResult?
        
        sut?.process(anyPhoneNumber()) { result = $0 }
        serviceSpy.complete(with: .init(
            consentListResult: .failure(.server(statusCode: 123, errorMessage: UUID().uuidString)),
            defaultBankResult: .failure(.limit(message: UUID().uuidString))
        ))
        sut = nil
        loadSpy.complete(with: true)
        
        XCTAssertNil(result)
    }
    
    func test_process_shouldDeliverEmptyConsentListOnGetConsentListFailure_server_defaultBankFailure_server_b3c4() {
        
        let errorMessage = UUID().uuidString
        let consentListError: GetConsentListError = .server(statusCode: 321, errorMessage: errorMessage)
        let defaultBankError: GetDefaultBankError = .server(statusCode: 123, errorMessage: UUID().uuidString)
        let loadedDefaultBank = anyDefaultBank()
        let (sut, serviceSpy, loadSpy) = makeSUT()
        
        expect(sut, toDeliver: .failure(.init(
            getConsentListAndDefaultBank: .init(
                consentList: [],
                defaultBank: loadedDefaultBank
            ),
            message: errorMessage,
            type: .server
        ))) {
            serviceSpy.complete(with: .init(
                consentListResult: .failure(consentListError),
                defaultBankResult: .failure(defaultBankError)
            ))
            loadSpy.complete(with: loadedDefaultBank)
        }
    }
    
    // MARK: - Helpers
    
    private typealias SUT = GetConsentListAndDefaultBankServiceAdapter
    private typealias GetConsentListError = GetConsentListAndDefaultBankResults.GetConsentListError
    private typealias GetDefaultBankError = GetConsentListAndDefaultBankResults.GetDefaultBankError
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
