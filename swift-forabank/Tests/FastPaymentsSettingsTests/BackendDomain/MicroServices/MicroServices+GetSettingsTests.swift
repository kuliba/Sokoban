//
//  MicroServices+GetSettingsTests.swift
//
//
//  Created by Igor Malyarov on 25.01.2024.
//

import Tagged

public extension MicroServices {
    
    final class GetSettings<Contract, Consent, Settings> {
        
        private let getContract: GetContract
        private let getConsent: GetConsent
#warning("getBankDefault should be decorated with caching!")
        private let getBankDefault: GetBankDefault
        private let mapToMissing: MapToMissing
        private let mapToResult: MapToResult
        
        init(
            getContract: @escaping GetContract,
            getConsent: @escaping GetConsent,
            getBankDefault: @escaping GetBankDefault,
            mapToMissing: @escaping MapToMissing,
            mapToResult: @escaping MapToResult
        ) {
            self.getContract = getContract
            self.getConsent = getConsent
            self.getBankDefault = getBankDefault
            self.mapToMissing = mapToMissing
            self.mapToResult = mapToResult
        }
    }
}

public extension MicroServices.GetSettings {
    
    func process(
        _ phoneNumber: PhoneNumber,
        completion: @escaping Completion
    ) {
        getContract { [weak self] result in
            
            guard let self else { return }
            
            switch result {
            case let .failure(failure):
                completion(.failure(failure))
                
                // missing contract
            case .success(.none):
                process(completion)
                
#warning("add tests")
            case let .success(.some(contract)):
                process(contract, phoneNumber, completion)
            }
        }
    }
}

public extension MicroServices.GetSettings {
    
    typealias SettingsResult = Result<Settings, ServiceFailure>
    typealias Completion = (SettingsResult) -> Void
}

public extension MicroServices.GetSettings {
    
    typealias FastPaymentContractFindListResult = Result<Contract?, ServiceFailure>
    typealias FastPaymentContractFindListCompletion = (FastPaymentContractFindListResult) -> Void
    typealias GetContract = (@escaping FastPaymentContractFindListCompletion) -> Void
}

public extension MicroServices.GetSettings {
    
    typealias GetConsentCompletion = (Consent) -> Void
    typealias GetConsent = (@escaping GetConsentCompletion) -> Void
}

public extension MicroServices.GetSettings {
    
    typealias PhoneNumber = Tagged<_PhoneNumber, String>
    enum _PhoneNumber {}
    typealias GetBankDefaultCompletion = (GetBankDefaultResponse) -> Void
    typealias GetBankDefault = (PhoneNumber, @escaping GetBankDefaultCompletion) -> Void
}

public typealias BankDefault = Tagged<_BankDefault, Bool>
public enum _BankDefault {}

public struct GetBankDefaultResponse: Equatable {
    
    let bankDefault: BankDefault
    let requestLimitMessage: String?
}

public extension MicroServices.GetSettings {
    
    typealias MapToMissing = (Consent) -> SettingsResult
    typealias MapToResult = (Contract, Consent, GetBankDefaultResponse) -> SettingsResult
}

private extension MicroServices.GetSettings {
    
    func process(
        _ completion: @escaping Completion
    ) {
        getConsent { [weak self] resultB in
            
            guard let self else { return }
            
            completion(self.mapToMissing(resultB))
        }
    }
    
    func process(
        _ contract: Contract,
        _ phoneNumber: PhoneNumber,
        _ completion: @escaping Completion
    ) {
        getConsent { [weak self] resultB in
            
            guard let self else { return }
            
            getBankDefault(phoneNumber) { [weak self] resultC in
                
                guard let self else { return }
                
                completion(mapToResult(contract, resultB, resultC))
            }
        }
    }
}

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
    
    func test_process_shouldDeliverConnectivityErrorOn_fastPaymentContractFindListConnectivityErrorFailure() {
        
        let (sut, getContractSpy, _,_) = makeSUT()
        
        expect(sut, toDeliver: .failure(.connectivityError), on: {
            
            getContractSpy.complete(with: .failure(.connectivityError))
        })
    }
    
    func test_process_shouldDeliverServerErrorOn_fastPaymentContractFindListServerErrorFailure() {
        
        let message = anyMessage()
        let (sut, getContractSpy, _,_) = makeSUT()
        
        expect(sut, toDeliver: .failure(.serverError(message)), on: {
            
            getContractSpy.complete(with: .failure(.serverError(message)))
        })
    }
    
    func test_process_shouldDeliverMissingWithConsentOn_getContractSpySuccessNil() {
        
        let consent = anyConsentResponse()
        let (sut, getContractSpy, getConsentSpy,_) = makeSUT()
        
        expect(sut, toDeliver: .success(.missing(consent)), on: {
            
            getContractSpy.complete(with: .success(nil))
            getConsentSpy.complete(with: consent)
        })
    }
    
    func test_process_shouldNotDeliver_fastPaymentContractFindListResultOnInstanceDeallocation() {
        
        var sut: SUT?
        let getContractSpy: GetContractSpy
        (sut, getContractSpy, _,_) = makeSUT()
        var receivedResult: SUT.SettingsResult?
        
        sut?.process(anyPhoneNumber()) { receivedResult = $0 }
        sut = nil
        getContractSpy.complete(with: .success(.init()))
        
        XCTAssertNil(receivedResult)
    }
    
    func test_process_shouldNotDeliver_getClientConsentMe2MePullResultOnInstanceDeallocation() {
        
        let consent = anyConsentResponse()
        var sut: SUT?
        let getContractSpy: GetContractSpy
        let getConsentSpy: GetConsentSpy
        (sut, getContractSpy, getConsentSpy,_) = makeSUT()
        var receivedResult: SUT.SettingsResult?
        
        sut?.process(anyPhoneNumber()) { receivedResult = $0 }
        getContractSpy.complete(with: .success(nil))
        sut = nil
        getConsentSpy.complete(with: consent)
        
        XCTAssertNil(receivedResult)
    }
    
#warning("add tests for instance deallocation")
    
    // MARK: - Helpers
    
    private typealias SUT = MicroServices.GetSettings<Contract, ConsentResponse, Settings>
    
    private typealias GetContractSpy = Spy<Void, SUT.FastPaymentContractFindListResult>
    private typealias GetConsentSpy = Spy<Void, ConsentResponse>
    private typealias GetBankDefaultSpy = Spy<SUT.PhoneNumber, GetBankDefaultResponse>
    
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
        
        let mapToResult: SUT.MapToResult = { _,_,_ in fatalError() }
        
        let sut = SUT(
            getContract: getContractSpy.process(completion:),
            getConsent: getConsentSpy.process(completion:),
            getBankDefault: getBankDefaultSpy.process(_:completion:),
            mapToMissing: mapToMissing,
            mapToResult: mapToResult
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(getContractSpy, file: file, line: line)
        trackForMemoryLeaks(getConsentSpy, file: file, line: line)
        trackForMemoryLeaks(getBankDefaultSpy, file: file, line: line)
        
        return (sut, getContractSpy, getConsentSpy, getBankDefaultSpy)
    }
    
    private struct Contract {
        
        let id = anyMessage()
    }
    
    private struct ConsentResponse: Equatable {
        
        let id = anyMessage()
    }
    
    private enum Settings: Equatable {
        
        case missing(ConsentResponse)
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
    
    private func anyConsentResponse() -> ConsentResponse {
        
        .init()
    }
}
