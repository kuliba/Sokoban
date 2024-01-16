//
//  FastPaymentsSettingsEffectHandlerTests.swift
//
//
//  Created by Igor Malyarov on 15.01.2024.
//

import FastPaymentsSettings
import XCTest

final class FastPaymentsSettingsEffectHandlerTests: XCTestCase {
    
    func test_init_shouldNotCallCollaborators() {
        
        let (_, getUserPaymentSettingsSpy, updateContractSpy, prepareSetBankDefaultSpy, createContractSpy) = makeSUT()
        
        XCTAssertNoDiff(getUserPaymentSettingsSpy.callCount, 0)
        XCTAssertNoDiff(updateContractSpy.callCount, 0)
        XCTAssertNoDiff(prepareSetBankDefaultSpy.callCount, 0)
        XCTAssertNoDiff(createContractSpy.callCount, 0)
    }
    
    // MARK: - getUserPaymentSettings
    
    func test_getUserPaymentSettings_shouldDeliverLoadedContractedOnContracted() {
        
        let contracted = anyContractedSettings()
        let (sut, getUserPaymentSettingsSpy, _,_,_) = makeSUT()
        
        expect(sut, with: .getUserPaymentSettings, toDeliver: .loadedUserPaymentSettings(contracted), on: {
            
            getUserPaymentSettingsSpy.complete(with: contracted)
        })
    }
    
    func test_getUserPaymentSettings_shouldDeliverLoadedMissingSuccessOnMissingSuccess() {
        
        let missingSuccess = anyMissingSuccessSettings()
        let (sut, getUserPaymentSettingsSpy, _,_,_) = makeSUT()
        
        expect(sut, with: .getUserPaymentSettings, toDeliver: .loadedUserPaymentSettings(missingSuccess), on: {
            
            getUserPaymentSettingsSpy.complete(with: missingSuccess)
        })
    }
    
    func test_getUserPaymentSettings_shouldDeliverLoadedMissingFailureOnMissingFailure() {
        
        let missingFailure = anyMissingFailureSettings()
        let (sut, getUserPaymentSettingsSpy, _,_,_) = makeSUT()
        
        expect(sut, with: .getUserPaymentSettings, toDeliver: .loadedUserPaymentSettings(missingFailure), on: {
            
            getUserPaymentSettingsSpy.complete(with: missingFailure)
        })
    }
    
    func test_getUserPaymentSettings_shouldDeliverLoadedConnectivityErrorOnConnectivityErrorFailure() {
        
        let failure: UserPaymentSettings = .failure(.connectivityError)
        let (sut, getUserPaymentSettingsSpy, _,_,_) = makeSUT()
        
        expect(sut, with: .getUserPaymentSettings, toDeliver: .loadedUserPaymentSettings(failure), on: {
            
            getUserPaymentSettingsSpy.complete(with: failure)
        })
    }
    
    func test_getUserPaymentSettings_shouldDeliverLoadedServerErrorOnServerErrorFailure() {
        
        let failure = anyServerErrorSettings()
        let (sut, getUserPaymentSettingsSpy, _,_,_) = makeSUT()
        
        expect(sut, with: .getUserPaymentSettings, toDeliver: .loadedUserPaymentSettings(failure), on: {
            
            getUserPaymentSettingsSpy.complete(with: failure)
        })
    }
    
    // MARK: - activateContract
    
    func test_activateContract_shouldPassPayload() {
        
        let currentContract = anyPaymentContract()
        let (sut, _, updateContractSpy, _,_) = makeSUT()
        
        sut.handleEffect(.activateContract(currentContract)) { _ in }
        
        XCTAssertNoDiff(updateContractSpy.payloads.map(\.0), [currentContract])
        XCTAssertNoDiff(updateContractSpy.payloads.map(\.1), [.activate])
    }
    
    func test_activateContract_shouldDeliverContractUpdateSuccessOnSuccess() {
        
        let currentContract = anyPaymentContract()
        let activatedContract = anyActivePaymentContract()
        let (sut, _, updateContractSpy, _,_) = makeSUT()
        
        expect(sut, with: .activateContract(currentContract), toDeliver: .contractUpdate(.success(activatedContract)), on: {
            
            updateContractSpy.complete(with: .success(activatedContract))
        })
    }
    
    func test_activateContract_shouldDeliverContractUpdateConnectivityFailureOnConnectivityError() {
        
        let currentContract = anyPaymentContract()
        let (sut, _, updateContractSpy, _,_) = makeSUT()
        
        expect(sut, with: .activateContract(currentContract), toDeliver: .contractUpdate(.failure(.connectivityError)), on: {
            
            updateContractSpy.complete(with: .failure(.connectivityError))
        })
    }
    
    func test_activateContract_shouldDeliverContractUpdateServerErrorFailureOnServerError() {
        
        let currentContract = anyPaymentContract()
        let message = UUID().uuidString
        let (sut, _, updateContractSpy, _,_) = makeSUT()
        
        expect(sut, with: .activateContract(currentContract), toDeliver: .contractUpdate(.failure(.serverError(message))), on: {
            
            updateContractSpy.complete(with: .failure(.serverError(message)))
        })
    }
    
    // MARK: - prepareSetBankDefault
    
    func test_prepareSetBankDefault_shouldDeliverSetBankDefaultPrepareNilFailureOnSuccess() {
        
        let (sut, _,_, prepareSetBankDefaultSpy, _) = makeSUT()
        
        expect(sut, with: .prepareSetBankDefault, toDeliver: .setBankDefaultPrepare(nil), on: {
            
            prepareSetBankDefaultSpy.complete(with: .success(()))
        })
    }
    
    func test_prepareSetBankDefault_shouldDeliverSetBankDefaultPrepareConnectivityFailureOnConnectivityError() {
        
        let (sut, _,_, prepareSetBankDefaultSpy, _) = makeSUT()
        
        expect(sut, with: .prepareSetBankDefault, toDeliver: .setBankDefaultPrepare(.connectivityError), on: {
            
            prepareSetBankDefaultSpy.complete(with: .failure(.connectivityError))
        })
    }
    
    func test_prepareSetBankDefault_shouldDeliverSetBankDefaultPrepareServerErrorFailureOnServerError() {
        
        let message = UUID().uuidString
        let (sut, _,_, prepareSetBankDefaultSpy, _) = makeSUT()
        
        expect(sut, with: .prepareSetBankDefault, toDeliver: .setBankDefaultPrepare(.serverError(message)), on: {
            
            prepareSetBankDefaultSpy.complete(with: .failure(.serverError(message)))
        })
    }
    
    // MARK: - Helpers
    
    private typealias SUT = FastPaymentsSettingsEffectHandler
    private typealias State = SUT.State
    private typealias Event = SUT.Event
    private typealias Effect = SUT.Effect
    
    private typealias GetUserPaymentSettingsSpy = Spy<Void, UserPaymentSettings>
    private typealias UpdateContractSpy = Spy<SUT.UpdateContractPayload, SUT.UpdateContractResponse>
    private typealias PrepareSetBankDefaultSpy = Spy<Void, SUT.PrepareSetBankDefaultResponse>
    private typealias CreateContractSpy = Spy<SUT.CreateContractPayload, SUT.CreateContractResponse>
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        getUserPaymentSettingsSpy: GetUserPaymentSettingsSpy,
        updateContractSpy: UpdateContractSpy,
        prepareSetBankDefaultSpy: PrepareSetBankDefaultSpy,
        createContractSpy: CreateContractSpy
    ) {
        let getUserPaymentSettingsSpy = GetUserPaymentSettingsSpy()
        let updateContractSpy = UpdateContractSpy()
        let prepareSetBankDefaultSpy = PrepareSetBankDefaultSpy()
        let createContractSpy = CreateContractSpy()
        let sut = SUT(
            getUserPaymentSettings: getUserPaymentSettingsSpy.process(completion:),
            updateContract: updateContractSpy.process(_:completion:),
            prepareSetBankDefault: prepareSetBankDefaultSpy.process(completion:),
            createContract: createContractSpy.process(_:completion:)
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(getUserPaymentSettingsSpy, file: file, line: line)
        trackForMemoryLeaks(updateContractSpy, file: file, line: line)
        trackForMemoryLeaks(prepareSetBankDefaultSpy, file: file, line: line)
        trackForMemoryLeaks(createContractSpy, file: file, line: line)
        
        return (sut, getUserPaymentSettingsSpy, updateContractSpy, prepareSetBankDefaultSpy, createContractSpy)
    }
    
    private func expect(
        _ sut: SUT,
        with effect: Effect,
        toDeliver expectedEvent: Event,
        on action: @escaping () -> Void,
        timeout: TimeInterval = 0.05,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let exp = expectation(description: "wait for completion")
        
        sut.handleEffect(effect) {
            
            XCTAssertNoDiff($0, expectedEvent, file: file, line: line)
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: timeout)
    }
}
