//
//  ComposedGetConsentListAndDefaultBankServiceTests.swift
//
//
//  Created by Igor Malyarov on 30.12.2023.
//

import Tagged

final class ComposedGetConsentListAndDefaultBankService {
    
    typealias GetConsentListResult = GetConsentListAndDefaultBank.ConsentListResult
    typealias GetConsentListCompletion = (GetConsentListResult) -> Void
    typealias GetConsentList = (@escaping GetConsentListCompletion) -> Void
    
    typealias GetDefaultBankResult = GetConsentListAndDefaultBank.DefaultBankResult
    typealias GetDefaultBankCompletion = (GetDefaultBankResult) -> Void
    typealias GetDefaultBank = (PhoneNumber, @escaping GetDefaultBankCompletion) -> Void
    
    private let getConsentList: GetConsentList
    private let getDefaultBank: GetDefaultBank
    
    init(
        getConsentList: @escaping GetConsentList,
        getDefaultBank: @escaping GetDefaultBank
    ) {
        self.getConsentList = getConsentList
        self.getDefaultBank = getDefaultBank
    }
}

extension ComposedGetConsentListAndDefaultBankService {
    
    typealias Completion = (GetConsentListAndDefaultBank) -> Void
    
    func process(
        _ payload: PhoneNumber,
        completion: @escaping Completion
    ) {
        getConsentList { [weak self] in
            
            self?._getDefaultBank(payload, $0, completion)
        }
    }
}

private extension ComposedGetConsentListAndDefaultBankService {
    
    func _getDefaultBank(
        _ payload: PhoneNumber,
        _ getConsentListResult: GetConsentListResult,
        _ completion: @escaping Completion
    ) {
        getDefaultBank(payload) { [weak self] in
            
            guard self != nil else { return }
            
            completion(.init(
                consentListResult: getConsentListResult,
                defaultBankResult: $0
            ))
        }
    }
}

import XCTest

final class ComposedGetConsentListAndDefaultBankServiceTests: XCTestCase {
    
    func test_init_shouldNotCallCollaborators() {
        
        let (_, getConsentListSpy, getDefaultBankSpy) = makeSUT()
        
        XCTAssertNoDiff(getConsentListSpy.callCount, 0)
        XCTAssertNoDiff(getDefaultBankSpy.callCount, 0)
    }
    
    func test_process_shouldDeliverConsentErrorOnGetConsentListFailure_connectivity_defaultBantFailure_connectivity() {
        
        let consentError: GetConsentListError = .connectivity
        let defaultBankError: GetDefaultBankError = .connectivity
        let (sut, getConsentListSpy, getDefaultBankSpy) = makeSUT()
        
        expect(sut, toDeliver: .init(
            consentListResult: .failure(consentError),
            defaultBankResult: .failure(defaultBankError)
        )) {
            getConsentListSpy.complete(with: .failure(consentError))
            getDefaultBankSpy.complete(with: .failure(defaultBankError))
        }
    }
    
    func test_process_shouldDeliverConsentErrorOnGetConsentListFailure_server_defaultBantFailure_connectivity() {
        
        let consentError: GetConsentListError = .server(statusCode: 123, errorMessage: UUID().uuidString)
        let defaultBankError: GetDefaultBankError = .connectivity
        let (sut, getConsentListSpy, getDefaultBankSpy) = makeSUT()
        
        expect(sut, toDeliver: .init(
            consentListResult: .failure(consentError),
            defaultBankResult: .failure(defaultBankError)
        )) {
            getConsentListSpy.complete(with: .failure(consentError))
            getDefaultBankSpy.complete(with: .failure(defaultBankError))
        }
    }
    
    func test_process_shouldDeliverConsentErrorOnGetConsentListFailure_connectivity_defaultBantFailure_limit() {
        
        let consentError: GetConsentListError = .connectivity
        let defaultBankError: GetDefaultBankError = .limit(message: UUID().uuidString)
        let (sut, getConsentListSpy, getDefaultBankSpy) = makeSUT()
        
        expect(sut, toDeliver: .init(
            consentListResult: .failure(consentError),
            defaultBankResult: .failure(defaultBankError)
        )) {
            getConsentListSpy.complete(with: .failure(consentError))
            getDefaultBankSpy.complete(with: .failure(defaultBankError))
        }
    }
    
    func test_process_shouldDeliverConsentErrorOnGetConsentListFailure_server_defaultBantFailure_limit() {
        
        let consentError: GetConsentListError = .server(statusCode: 123, errorMessage: UUID().uuidString)
        let defaultBankError: GetDefaultBankError = .limit(message: UUID().uuidString)
        let (sut, getConsentListSpy, getDefaultBankSpy) = makeSUT()
        
        expect(sut, toDeliver: .init(
            consentListResult: .failure(consentError),
            defaultBankResult: .failure(defaultBankError)
        )) {
            getConsentListSpy.complete(with: .failure(consentError))
            getDefaultBankSpy.complete(with: .failure(defaultBankError))
        }
    }
    
    func test_process_shouldDeliverConsentErrorOnGetConsentListFailure_connectivity_defaultBantFailure_server() {
        
        let consentError: GetConsentListError = .connectivity
        let defaultBankError: GetDefaultBankError = .server(statusCode: 231, errorMessage: UUID().uuidString)
        let (sut, getConsentListSpy, getDefaultBankSpy) = makeSUT()
        
        expect(sut, toDeliver: .init(
            consentListResult: .failure(consentError),
            defaultBankResult: .failure(defaultBankError)
        )) {
            getConsentListSpy.complete(with: .failure(consentError))
            getDefaultBankSpy.complete(with: .failure(defaultBankError))
        }
    }
    
    func test_process_shouldDeliverConsentErrorOnGetConsentListFailure_server_defaultBantFailure_server() {
        
        let consentError: GetConsentListError = .server(statusCode: 122, errorMessage: UUID().uuidString)
        let defaultBankError: GetDefaultBankError = .server(statusCode: 231, errorMessage: UUID().uuidString)
        let (sut, getConsentListSpy, getDefaultBankSpy) = makeSUT()
        
        expect(sut, toDeliver: .init(
            consentListResult: .failure(consentError),
            defaultBankResult: .failure(defaultBankError)
        )) {
            getConsentListSpy.complete(with: .failure(consentError))
            getDefaultBankSpy.complete(with: .failure(defaultBankError))
        }
    }
    
    func test_process_shouldDeliverConsentErrorOnGetConsentListFailure_connectivity_defaultBantSuccess_false() {
        
        let consentError: GetConsentListError = .connectivity
        let (sut, getConsentListSpy, getDefaultBankSpy) = makeSUT()
        
        expect(sut, toDeliver: .init(
            consentListResult: .failure(consentError),
            defaultBankResult: .success(false)
        )) {
            getConsentListSpy.complete(with: .failure(consentError))
            getDefaultBankSpy.complete(with: .success(false))
        }
    }
    
    func test_process_shouldDeliverConsentErrorOnGetConsentListFailure_server_defaultBantSuccess_false() {
        
        let consentError: GetConsentListError = .server(statusCode: 123, errorMessage: UUID().uuidString)
        let (sut, getConsentListSpy, getDefaultBankSpy) = makeSUT()
        
        expect(sut, toDeliver: .init(
            consentListResult: .failure(consentError),
            defaultBankResult: .success(false)
        )) {
            getConsentListSpy.complete(with: .failure(consentError))
            getDefaultBankSpy.complete(with: .success(false))
        }
    }
    
    func test_process_shouldDeliverConsentErrorOnGetConsentListFailure_connectivity_defaultBantSuccess_true() {
        
        let consentError: GetConsentListError = .connectivity
        let (sut, getConsentListSpy, getDefaultBankSpy) = makeSUT()
        
        expect(sut, toDeliver: .init(
            consentListResult: .failure(consentError),
            defaultBankResult: .success(true)
        )) {
            getConsentListSpy.complete(with: .failure(consentError))
            getDefaultBankSpy.complete(with: .success(true))
        }
    }
    func test_process_shouldDeliverConsentErrorOnGetConsentListFailure_server_defaultBantSuccess_true() {
        
        let consentError: GetConsentListError = .server(statusCode: 123, errorMessage: UUID().uuidString)
        let (sut, getConsentListSpy, getDefaultBankSpy) = makeSUT()
        
        expect(sut, toDeliver: .init(
            consentListResult: .failure(consentError),
            defaultBankResult: .success(true)
        )) {
            getConsentListSpy.complete(with: .failure(consentError))
            getDefaultBankSpy.complete(with: .success(true))
        }
    }
    
    func test_process_shouldDeliverConsentListOnGetConsentListSuccess_empty_defaultBantFailure_connectivity() {
        
        let consentList = makeConsentList(count: 0)
        let defaultBankError: GetDefaultBankError = .connectivity
        let (sut, getConsentListSpy, getDefaultBankSpy) = makeSUT()
        
        expect(sut, toDeliver: .init(
            consentListResult: .success([]),
            defaultBankResult: .failure(defaultBankError)
        )) {
            getConsentListSpy.complete(with: .success(consentList))
            getDefaultBankSpy.complete(with: .failure(defaultBankError))
        }
    }
    
    func test_process_shouldDeliverConsentListOnGetConsentListSuccess_empty_defaultBantFailure_limit() {
        
        let consentList = makeConsentList(count: 0)
        let defaultBankError: GetDefaultBankError = .limit(message: UUID().uuidString)
        let (sut, getConsentListSpy, getDefaultBankSpy) = makeSUT()
        
        expect(sut, toDeliver: .init(
            consentListResult: .success([]),
            defaultBankResult: .failure(defaultBankError)
        )) {
            getConsentListSpy.complete(with: .success(consentList))
            getDefaultBankSpy.complete(with: .failure(defaultBankError))
        }
    }
    
    func test_process_shouldDeliverConsentListOnGetConsentListSuccess_empty_defaultBantFailure_server() {
        
        let consentList = makeConsentList(count: 0)
        let defaultBankError: GetDefaultBankError = .server(statusCode: 321, errorMessage: UUID().uuidString)
        let (sut, getConsentListSpy, getDefaultBankSpy) = makeSUT()
        
        expect(sut, toDeliver: .init(
            consentListResult: .success([]),
            defaultBankResult: .failure(defaultBankError)
        )) {
            getConsentListSpy.complete(with: .success(consentList))
            getDefaultBankSpy.complete(with: .failure(defaultBankError))
        }
    }
    
    func test_process_shouldDeliverConsentListOnGetConsentListSuccess_empty_defaultBantSuccess_false() {
        
        let consentList = makeConsentList(count: 0)
        let (sut, getConsentListSpy, getDefaultBankSpy) = makeSUT()
        
        expect(sut, toDeliver: .init(
            consentListResult: .success([]),
            defaultBankResult: .success(false)
        )) {
            getConsentListSpy.complete(with: .success(consentList))
            getDefaultBankSpy.complete(with: .success(false))
        }
    }
    
    func test_process_shouldDeliverConsentListOnGetConsentListSuccess_empty_defaultBantSuccess_true() {
        
        let consentList = makeConsentList(count: 0)
        let (sut, getConsentListSpy, getDefaultBankSpy) = makeSUT()
        
        expect(sut, toDeliver: .init(
            consentListResult: .success([]),
            defaultBankResult: .success(true)
        )) {
            getConsentListSpy.complete(with: .success(consentList))
            getDefaultBankSpy.complete(with: .success(true))
        }
    }
    
    func test_process_shouldDeliverConsentListOnGetConsentListSuccess_one_defaultBantFailure_connectivity() {
        
        let consentList = makeConsentList(count: 1)
        let defaultBankError: GetDefaultBankError = .connectivity
        let (sut, getConsentListSpy, getDefaultBankSpy) = makeSUT()
        
        expect(sut, toDeliver: .init(
            consentListResult: .success(consentList),
            defaultBankResult: .failure(defaultBankError)
        )) {
            getConsentListSpy.complete(with: .success(consentList))
            getDefaultBankSpy.complete(with: .failure(defaultBankError))
        }
    }
    
    func test_process_shouldDeliverConsentListOnGetConsentListSuccess_one_defaultBantFailure_limit() {
        
        let consentList = makeConsentList(count: 1)
        let defaultBankError: GetDefaultBankError = .limit(message: UUID().uuidString)
        let (sut, getConsentListSpy, getDefaultBankSpy) = makeSUT()
        
        expect(sut, toDeliver: .init(
            consentListResult: .success(consentList),
            defaultBankResult: .failure(defaultBankError)
        )) {
            getConsentListSpy.complete(with: .success(consentList))
            getDefaultBankSpy.complete(with: .failure(defaultBankError))
        }
    }
    
    func test_process_shouldDeliverConsentListOnGetConsentListSuccess_one_defaultBantFailure_server() {
        
        let consentList = makeConsentList(count: 1)
        let defaultBankError: GetDefaultBankError = .server(statusCode: 342, errorMessage: UUID().uuidString)
        let (sut, getConsentListSpy, getDefaultBankSpy) = makeSUT()
        
        expect(sut, toDeliver: .init(
            consentListResult: .success(consentList),
            defaultBankResult: .failure(defaultBankError)
        )) {
            getConsentListSpy.complete(with: .success(consentList))
            getDefaultBankSpy.complete(with: .failure(defaultBankError))
        }
    }
    
    func test_process_shouldDeliverConsentListOnGetConsentListSuccess_one_defaultBantSuccess_false() {
        
        let consentList = makeConsentList(count: 1)
        let (sut, getConsentListSpy, getDefaultBankSpy) = makeSUT()
        
        expect(sut, toDeliver: .init(
            consentListResult: .success(consentList),
            defaultBankResult: .success(false)
        )) {
            getConsentListSpy.complete(with: .success(consentList))
            getDefaultBankSpy.complete(with: .success(false))
        }
    }
    
    func test_process_shouldDeliverConsentListOnGetConsentListSuccess_one_defaultBantSuccess_true() {
        
        let consentList = makeConsentList(count: 1)
        let (sut, getConsentListSpy, getDefaultBankSpy) = makeSUT()
        
        expect(sut, toDeliver: .init(
            consentListResult: .success(consentList),
            defaultBankResult: .success(true)
        )) {
            getConsentListSpy.complete(with: .success(consentList))
            getDefaultBankSpy.complete(with: .success(true))
        }
    }
    
    func test_process_shouldDeliverConsentListOnGetConsentListSuccess_many_defaultBantFailure_connectivity() {
        
        let consentList = makeConsentList(count: 2)
        let defaultBankError: GetDefaultBankError = .connectivity
        let (sut, getConsentListSpy, getDefaultBankSpy) = makeSUT()
        
        expect(sut, toDeliver: .init(
            consentListResult: .success(consentList),
            defaultBankResult: .failure(defaultBankError)
        )) {
            getConsentListSpy.complete(with: .success(consentList))
            getDefaultBankSpy.complete(with: .failure(defaultBankError))
        }
    }
    
    func test_process_shouldDeliverConsentListOnGetConsentListSuccess_many_defaultBantFailure_limit() {
        
        let consentList = makeConsentList(count: 2)
        let defaultBankError: GetDefaultBankError = .limit(message: UUID().uuidString)
        let (sut, getConsentListSpy, getDefaultBankSpy) = makeSUT()
        
        expect(sut, toDeliver: .init(
            consentListResult: .success(consentList),
            defaultBankResult: .failure(defaultBankError)
        )) {
            getConsentListSpy.complete(with: .success(consentList))
            getDefaultBankSpy.complete(with: .failure(defaultBankError))
        }
    }
    
    func test_process_shouldDeliverConsentListOnGetConsentListSuccess_many_defaultBantFailure_server() {
        
        let consentList = makeConsentList(count: 2)
        let defaultBankError: GetDefaultBankError = .server(statusCode: 315, errorMessage: UUID().uuidString)
        let (sut, getConsentListSpy, getDefaultBankSpy) = makeSUT()
        
        expect(sut, toDeliver: .init(
            consentListResult: .success(consentList),
            defaultBankResult: .failure(defaultBankError)
        )) {
            getConsentListSpy.complete(with: .success(consentList))
            getDefaultBankSpy.complete(with: .failure(defaultBankError))
        }
    }
    
    func test_process_shouldDeliverConsentListOnGetConsentListSuccess_many_defaultBantSuccess_false() {
        
        let consentList = makeConsentList(count: 2)
        let (sut, getConsentListSpy, getDefaultBankSpy) = makeSUT()
        
        expect(sut, toDeliver: .init(
            consentListResult: .success(consentList),
            defaultBankResult: .success(false)
        )) {
            getConsentListSpy.complete(with: .success(consentList))
            getDefaultBankSpy.complete(with: .success(false))
        }
    }
    
    func test_process_shouldDeliverConsentListOnGetConsentListSuccess_many_defaultBantSuccess_true() {
        
        let consentList = makeConsentList(count: 2)
        let (sut, getConsentListSpy, getDefaultBankSpy) = makeSUT()
        
        expect(sut, toDeliver: .init(
            consentListResult: .success(consentList),
            defaultBankResult: .success(true)
        )) {
            getConsentListSpy.complete(with: .success(consentList))
            getDefaultBankSpy.complete(with: .success(true))
        }
    }
    
    func test_process_shouldNotDeliverGetConsentListResultOnInstanceDeallocation() {
        
        var sut: SUT?
        let getConsentListSpy: GetConsentListSpy
        (sut, getConsentListSpy, _) = makeSUT()
        var result: GetConsentListAndDefaultBank?
        
        sut?.process(anyPhoneNumber()) { result = $0 }
        sut = nil
        getConsentListSpy.complete(with: .success([]))
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.1)
        
        XCTAssertNil(result)
    }
    
    func test_process_shouldNotDeliverGetDefaultBankResultOnInstanceDeallocation() {
        
        var sut: SUT?
        let getConsentListSpy: GetConsentListSpy
        let getDefaultBankSpy: GetDefaultBankSpy
        (sut, getConsentListSpy, getDefaultBankSpy) = makeSUT()
        var result: GetConsentListAndDefaultBank?
        
        sut?.process(anyPhoneNumber()) { result = $0 }
        getConsentListSpy.complete(with: .success([]))
        sut = nil
        getDefaultBankSpy.complete(with: .success(false))
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.1)
        
        XCTAssertNil(result)
    }
    
    // MARK: - Helpers
    
    private typealias SUT = ComposedGetConsentListAndDefaultBankService
    private typealias GetConsentListSpy = Spy<Void, [BankID], GetConsentListError>
    private typealias GetDefaultBankSpy = Spy<PhoneNumber, DefaultBank, GetDefaultBankError>
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        getConsentListSpy: GetConsentListSpy,
        getDefaultBankSpy: GetDefaultBankSpy
    ) {
        let getConsentListSpy = GetConsentListSpy()
        let getDefaultBankSpy = GetDefaultBankSpy()
        let sut = SUT(
            getConsentList: getConsentListSpy.process,
            getDefaultBank: getDefaultBankSpy.process
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(getConsentListSpy, file: file, line: line)
        trackForMemoryLeaks(getDefaultBankSpy, file: file, line: line)
        
        return (sut, getConsentListSpy, getDefaultBankSpy)
    }
    
    private func makeConsentList(
        count: Int
    ) -> [BankID] {
        
        (0..<count).map { _ in .init(UUID().uuidString) }
    }
    
    private func expect(
        _ sut: SUT,
        with payload: PhoneNumber = anyPhoneNumber(),
        toDeliver expectedValue: GetConsentListAndDefaultBank,
        on action: @escaping () -> Void,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let exp = expectation(description: "wait for completion")
        
        sut.process(payload) { receivedValue in
            
            assert(receivedValue.consentListResult, expectedValue.consentListResult, file: file, line: line)
            assert(receivedValue.defaultBankResult, expectedValue.defaultBankResult, file: file, line: line)
            
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 1.0)
    }
}

private func assert<T: Equatable, E: Equatable>(
    _ receivedValue: Result<T, E>,
    _ expectedValue: Result<T, E>,
    file: StaticString = #file,
    line: UInt = #line
) {
    switch (receivedValue, expectedValue) {
        
    case let (
        .failure(receivedError),
        .failure(expectedError)
    ):
        XCTAssertNoDiff(receivedError, expectedError, file: file, line: line)
        
    case let (
        .success(receivedValue),
        .success(expectedValue)
    ):
        XCTAssertNoDiff(receivedValue, expectedValue, file: file, line: line)
        
    default:
        XCTFail("Expected \(expectedValue), but got \(receivedValue) instead.", file: file, line: line)
    }
}

private func assert<T: Equatable>(
    _ receivedValue: Result<T, Error>,
    _ expectedValue: Result<T, Error>,
    file: StaticString = #file,
    line: UInt = #line
) {
    switch (receivedValue, expectedValue) {
        
    case let (
        .failure(receivedError as NSError),
        .failure(expectedError as NSError)
    ):
        XCTAssertNoDiff(receivedError, expectedError, file: file, line: line)
        
    case let (
        .success(receivedValue),
        .success(expectedValue)
    ):
        XCTAssertNoDiff(receivedValue, expectedValue, file: file, line: line)
        
    default:
        XCTFail("Expected \(expectedValue), but got \(receivedValue) instead.", file: file, line: line)
    }
}

private func anyPhoneNumber(
    _ value: String = UUID().uuidString
) -> PhoneNumber {
    
    .init(value)
}
