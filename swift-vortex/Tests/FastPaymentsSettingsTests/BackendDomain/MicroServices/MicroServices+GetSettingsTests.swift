//
//  MicroServices+GetSettingsTests.swift
//
//
//  Created by Igor Malyarov on 25.01.2024.
//

import FastPaymentsSettings
import Tagged
import XCTest

final class MicroServices_GetSettingsTests: XCTestCase {
    
    func test_init_shouldNotCallCollaborators() {
        
        let (_, getContractSpy, getConsentSpy, getBankDefaultSpy) = makeSUT()
        
        XCTAssertEqual(getContractSpy.callCount, 0)
        XCTAssertEqual(getConsentSpy.callCount, 0)
        XCTAssertEqual(getBankDefaultSpy.callCount, 0)
    }
    
    func test_process_shouldDeliverConnectivityErrorOn_getContractConnectivityErrorFailure() {
        
        let (sut, getContractSpy, _,_) = makeSUT()
        
        expect(sut, toDeliver: .failure(.connectivityError), on: {
            
            getContractSpy.complete(with: .failure(.connectivityError))
        })
    }
    
    func test_process_shouldDeliverServerErrorOn_getContractServerErrorFailure() {
        
        let message = anyMessage()
        let (sut, getContractSpy, _,_) = makeSUT()
        
        expect(sut, toDeliver: .failure(.serverError(message)), on: {
            
            getContractSpy.complete(with: .failure(.serverError(message)))
        })
    }
    
    func test_process_shouldNotCallGetConsentOn_getContractConnectivityFailure() {
        
        let (sut, getContractSpy, getConsentSpy,_) = makeSUT()
        
        expect(sut, toDeliver: .failure(.connectivityError), on: {
            
            getContractSpy.complete(with: .failure(.connectivityError))
        })
        
        XCTAssertEqual(getConsentSpy.callCount, 0)
    }
    
    func test_process_shouldNotCallGetConsentOn_getContractServerFailure() {
        
        let message = anyMessage()
        let (sut, getContractSpy, getConsentSpy,_) = makeSUT()
        
        expect(sut, toDeliver: .failure(.serverError(message)), on: {
            
            getContractSpy.complete(with: .failure(.serverError(message)))
        })
        
        XCTAssertEqual(getConsentSpy.callCount, 0)
    }
    
    func test_process_shouldNotCallGetBankDefaultOn_getContractConnectivityFailure() {
        
        let (sut, getContractSpy, _, getGetBankDefaultSpy) = makeSUT()
        
        expect(sut, toDeliver: .failure(.connectivityError), on: {
            
            getContractSpy.complete(with: .failure(.connectivityError))
        })
        
        XCTAssertEqual(getGetBankDefaultSpy.callCount, 0)
    }
    
    func test_process_shouldNotCallGetBankDefaultOn_getContractServerFailure() {
        
        let message = anyMessage()
        let (sut, getContractSpy, _, getGetBankDefaultSpy) = makeSUT()
        
        expect(sut, toDeliver: .failure(.serverError(message)), on: {
            
            getContractSpy.complete(with: .failure(.serverError(message)))
        })
        
        XCTAssertEqual(getGetBankDefaultSpy.callCount, 0)
    }
    
    func test_process_shouldDeliverMissingWithConsentOn_getContractSuccessNil() {
        
        let consent = anyConsentResponse()
        let (sut, getContractSpy, getConsentSpy,_) = makeSUT()
        
        expect(sut, toDeliver: .success(.missing(consent)), on: {
            
            getContractSpy.complete(with: .success(nil))
            getConsentSpy.complete(with: consent)
        })
    }
    
    func test_process_shouldCallGetConsentOn_getContractSuccessNil() {
        
        let (sut, getContractSpy, getConsentSpy,_) = makeSUT()
        
        sut.process { _ in }
        getContractSpy.complete(with: .success(nil))
        
        XCTAssertEqual(getConsentSpy.callCount, 1)
    }
    
    func test_process_shouldNotCallGetBankDefaultOn_getContractSuccessNil() {
        
        let (sut, getContractSpy, getConsentSpy, getGetBankDefaultSpy) = makeSUT()
        
        sut.process { _ in }
        getContractSpy.complete(with: .success(nil))
        getConsentSpy.complete(with: .init())
        
        XCTAssertEqual(getGetBankDefaultSpy.callCount, 0)
    }
    
    func test_process_shouldNotDeliver_getContractResultOnInstanceDeallocation() {
        
        var sut: SUT?
        let getContractSpy: GetContractSpy
        (sut, getContractSpy, _,_) = makeSUT()
        var receivedResult: SUT.ProcessResult?
        
        sut?.process { receivedResult = $0 }
        sut = nil
        getContractSpy.complete(with: .success(anyContract()))
        
        XCTAssertNil(receivedResult)
    }
    
    func test_process_shouldNotDeliver_getClientConsentMe2MePullResultOnInstanceDeallocation() {
        
        let consent = anyConsentResponse()
        var sut: SUT?
        let getContractSpy: GetContractSpy
        let getConsentSpy: GetConsentSpy
        (sut, getContractSpy, getConsentSpy,_) = makeSUT()
        var receivedResult: SUT.ProcessResult?
        
        sut?.process { receivedResult = $0 }
        getContractSpy.complete(with: .success(nil))
        sut = nil
        getConsentSpy.complete(with: consent)
        
        XCTAssertNil(receivedResult)
    }
    
#warning("add tests for instance deallocation")
    
    func test_process_shouldCallGetBankDefaultWithPhoneNumberFromGetSettings() {
        
        let contract = anyContract()
        let (sut, getContractSpy, getConsentSpy, getBankDefaultSpy) = makeSUT()
        
        sut.process { _ in }
        getContractSpy.complete(with: .success(contract))
        getConsentSpy.complete(with: .init())
        
        XCTAssertEqual(getBankDefaultSpy.payloads, [contract.phoneNumber])
    }
    
    // MARK: - Helpers
    
    private typealias SUT = MicroServices.SettingsGetter<Contract, ConsentResponse, Settings>
    
    private typealias GetContractSpy = Spy<Void, SUT.GetContractResult>
    private typealias GetConsentSpy = Spy<Void, ConsentResponse>
    private typealias GetBankDefaultSpy = Spy<PhoneNumber, UserPaymentSettings.GetBankDefaultResponse>
    
    private func makeSUT(
        mapToMissing: @escaping SUT.MapToMissing = { .success(.missing($0)) },
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        getContractSpy: GetContractSpy,
        getConsentSpy: GetConsentSpy,
        getBankDefaultSpy: GetBankDefaultSpy
    ) {
        let getContractSpy = GetContractSpy()
        let getConsentSpy = GetConsentSpy()
        let getBankDefaultSpy = GetBankDefaultSpy()
        
        let mapToSettings: SUT.MapToSettings = { _,_,_ in fatalError() }
        
        let sut = SUT(
            getContract: getContractSpy.process(completion:),
            getConsent: getConsentSpy.process(completion:),
            getBankDefault: getBankDefaultSpy.process(_:completion:),
            mapToMissing: mapToMissing,
            mapToSettings: mapToSettings
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(getContractSpy, file: file, line: line)
        trackForMemoryLeaks(getConsentSpy, file: file, line: line)
        trackForMemoryLeaks(getBankDefaultSpy, file: file, line: line)
        
        return (sut, getContractSpy, getConsentSpy, getBankDefaultSpy)
    }
    
    private struct Contract: PhoneNumbered {
        
        let id: String
        let phoneNumber: PhoneNumber
    }
    
    private struct ConsentResponse: Equatable {
        
        let id = anyMessage()
    }
    
    private enum Settings: Equatable {
        
        case missing(ConsentResponse)
    }
    
    private func expect(
        _ sut: SUT,
        toDeliver expected: SUT.ProcessResult,
        on action: @escaping () -> Void,
        timeout: TimeInterval = 0.05,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let exp = expectation(description: "wait for completion")
        
        sut.process {
            
            XCTAssertNoDiff($0, expected, "\nExpected \(expected), but got \($0) instead.", file: file, line: line)
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: timeout)
    }
    
    private func anyContract(
        id: String = anyMessage(),
        phoneNumber: PhoneNumber = anyPhoneNumber()
    ) -> Contract {
        
        .init(id: id, phoneNumber: phoneNumber)
    }
    
    private func anyConsentResponse() -> ConsentResponse {
        
        .init()
    }
}
