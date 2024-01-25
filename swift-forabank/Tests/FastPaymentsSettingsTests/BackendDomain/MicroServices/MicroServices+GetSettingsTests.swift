//
//  MicroServices+GetSettingsTests.swift
//
//
//  Created by Igor Malyarov on 25.01.2024.
//

import Tagged
import XCTest

final class MicroServices_GetSettingsTests: XCTestCase {
    
    func test_init_shouldNotCallCollaborators() {
        
        let (_, fastPaymentContractFindListSpy, getClientConsentMe2MePullSpy, getBankDefaultSpy) = makeSUT()
        
        XCTAssertEqual(fastPaymentContractFindListSpy.callCount, 0)
        XCTAssertEqual(getClientConsentMe2MePullSpy.callCount, 0)
        XCTAssertEqual(getBankDefaultSpy.callCount, 0)
    }
    
    func test_process_shouldDeliverConnectivityErrorOn_fastPaymentContractFindListConnectivityErrorFailure() {
        
        let (sut, fastPaymentContractFindListSpy, _,_) = makeSUT()
        
        expect(sut, toDeliver: .failure(.connectivityError), on: {
            
            fastPaymentContractFindListSpy.complete(with: .failure(.connectivityError))
        })
    }
    
    func test_process_shouldDeliverServerErrorOn_fastPaymentContractFindListServerErrorFailure() {
        
        let message = anyMessage()
        let (sut, fastPaymentContractFindListSpy, _,_) = makeSUT()
        
        expect(sut, toDeliver: .failure(.serviceError(message)), on: {
            
            fastPaymentContractFindListSpy.complete(with: .failure(.serviceError(message)))
        })
    }
    
    func test_process_shouldDeliverConnectiviyErrortOn_getClientConsentMe2MePullConnectivityErrorFailure() {
        
        let (sut, fastPaymentContractFindListSpy, getClientConsentMe2MePullSpy,_) = makeSUT()
        
        expect(sut, toDeliver: .failure(.connectivityError), on: {
            
            fastPaymentContractFindListSpy.complete(with: .success(nil))
            getClientConsentMe2MePullSpy.complete(with: .failure(.connectivityError))
        })
    }
    
    func test_process_shouldDeliverServerErrorOn_getClientConsentMe2MePullServerErrorFailure() {
        
        let message = anyMessage()
        let (sut, fastPaymentContractFindListSpy, getClientConsentMe2MePullSpy,_) = makeSUT()
        
        expect(sut, toDeliver: .failure(.serviceError(message)), on: {
            
            fastPaymentContractFindListSpy.complete(with: .success(nil))
            getClientConsentMe2MePullSpy.complete(with: .failure(.serviceError(message)))
        })
    }
    
    func test_process_shouldDeliverMissingContractWithConsentOn_getClientConsentMe2MePullSuccess() {
        
        let consent = GetClientConsentMe2MePullResponse()
        let (sut, fastPaymentContractFindListSpy, getClientConsentMe2MePullSpy,_) = makeSUT()
        
        expect(sut, toDeliver: .success(.missing(consent)), on: {
            
            fastPaymentContractFindListSpy.complete(with: .success(nil))
            getClientConsentMe2MePullSpy.complete(with: .success(consent))
        })
    }
    
    func test_process_shouldNotDeliver_fastPaymentContractFindListResultOnInstanceDeallocation() {
        var sut: SUT?
        let fastPaymentContractFindListSpy: FastPaymentContractFindListSpy
        (sut, fastPaymentContractFindListSpy, _,_) = makeSUT()
        var receivedResult: SUT.SettingsResult?
        
        sut?.process(anyPhoneNumber()) { receivedResult = $0 }
        sut = nil
        fastPaymentContractFindListSpy.complete(with: .success(.init()))
        
        XCTAssertNil(receivedResult)
    }
    
    func test_process_shouldNotDeliver_getClientConsentMe2MePullResultOnInstanceDeallocation() {
        var sut: SUT?
        let fastPaymentContractFindListSpy: FastPaymentContractFindListSpy
        let getClientConsentMe2MePullSpy: GetClientConsentMe2MePullSpy
        (sut, fastPaymentContractFindListSpy, getClientConsentMe2MePullSpy,_) = makeSUT()
        var receivedResult: SUT.SettingsResult?
        
        sut?.process(anyPhoneNumber()) { receivedResult = $0 }
        fastPaymentContractFindListSpy.complete(with: .success(nil))
        sut = nil
        getClientConsentMe2MePullSpy.complete(with: .success(.init()))
        
        XCTAssertNil(receivedResult)
    }
    
#warning("add tests for instance deallocation")
    
    // MARK: - Helpers
    
    private typealias SUT = MicroServices.GetSettings<Contract, GetClientConsentMe2MePullResponse, Settings>
    
    private typealias FastPaymentContractFindListSpy = Spy<Void, SUT.FastPaymentContractFindListResult>
    private typealias GetClientConsentMe2MePullSpy = Spy<Void, SUT.GetClientConsentMe2MePullResult>
    private typealias GetBankDefaultSpy = Spy<SUT.PhoneNumber, SUT.GetBankDefaultResult>
    
    private func makeSUT(
        mapToMissing: @escaping SUT.MapToMissing = { $0.map(Settings.missing) },
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        fastPaymentContractFindListSpy: FastPaymentContractFindListSpy,
        getClientConsentMe2MePullSpy: GetClientConsentMe2MePullSpy,
        getBankDefaultSpy: GetBankDefaultSpy
    ) {
        let fastPaymentContractFindListSpy = FastPaymentContractFindListSpy()
        let getClientConsentMe2MePullSpy = GetClientConsentMe2MePullSpy()
        let getBankDefaultSpy = GetBankDefaultSpy()
        
//        let mapToMissing: SUT.MapToMissing = { _ in fatalError() }
        let mapToContracted: SUT.MapToContracted = { _,_,_ in fatalError() }
        
        let sut = SUT(
            fastPaymentContractFindList: fastPaymentContractFindListSpy.process(completion:),
            getClientConsentMe2MePull: getClientConsentMe2MePullSpy.process(completion:),
            getBankDefault: getBankDefaultSpy.process(_:completion:),
            mapToMissing: mapToMissing,
            mapToContracted: mapToContracted
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(fastPaymentContractFindListSpy, file: file, line: line)
        trackForMemoryLeaks(getClientConsentMe2MePullSpy, file: file, line: line)
        trackForMemoryLeaks(getBankDefaultSpy, file: file, line: line)
        
        return (sut, fastPaymentContractFindListSpy, getClientConsentMe2MePullSpy, getBankDefaultSpy)
    }
    
    private struct Contract {
        
        let id = anyMessage()
    }
    
    private struct GetClientConsentMe2MePullResponse: Equatable {
        
        let id = anyMessage()
    }
    
    private enum Settings: Equatable {
        
        case missing(GetClientConsentMe2MePullResponse)
    }
    
    private func expect(
        _ sut: SUT,
        with phoneNumber: SUT.PhoneNumber = .init(anyMessage()),
        toDeliver expected: SUT.SettingsResult,
        on action: @escaping () -> Void,
        timeout: TimeInterval = 0.05,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let exp = expectation(description: "wait for completion")
        
        sut.process(phoneNumber) {
            
            XCTAssertNoDiff($0, expected, "\nExpected \(expected), but got \($0) instead.", file: file, line: line)
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: timeout)
    }
    
    private func anyPhoneNumber(
        _ value: String = anyMessage()
    ) -> SUT.PhoneNumber {
        
        .init(value)
    }
}
