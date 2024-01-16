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
        
        let (_, getUserPaymentSettingsSpy, _) = makeSUT()
        
        XCTAssertNoDiff(getUserPaymentSettingsSpy.callCount, 0)
    }
    
    // MARK: - getUserPaymentSettings
    
    func test_getUserPaymentSettings_shouldDeliverLoadedContractedOnContracted() {
        
        let contracted = anyContractedSettings()
        let (sut, getUserPaymentSettingsSpy, _) = makeSUT()
        
        expect(sut, with: .getUserPaymentSettings, toDeliver: .loadedUserPaymentSettings(contracted), on: {
            
            getUserPaymentSettingsSpy.complete(with: contracted)
        })
    }
    
    func test_getUserPaymentSettings_shouldDeliverLoadedMissingSuccessOnMissingSuccess() {
        
        let missingSuccess = anyMissingSuccessSettings()
        let (sut, getUserPaymentSettingsSpy, _) = makeSUT()
        
        expect(sut, with: .getUserPaymentSettings, toDeliver: .loadedUserPaymentSettings(missingSuccess), on: {
            
            getUserPaymentSettingsSpy.complete(with: missingSuccess)
        })
    }
    
    func test_getUserPaymentSettings_shouldDeliverLoadedMissingFailureOnMissingFailure() {
        
        let missingFailure = anyMissingFailureSettings()
        let (sut, getUserPaymentSettingsSpy, _) = makeSUT()
        
        expect(sut, with: .getUserPaymentSettings, toDeliver: .loadedUserPaymentSettings(missingFailure), on: {
            
            getUserPaymentSettingsSpy.complete(with: missingFailure)
        })
    }
    
    func test_getUserPaymentSettings_shouldDeliverLoadedConnectivityErrorOnConnectivityErrorFailure() {
        
        let failure: UserPaymentSettings = .failure(.connectivityError)
        let (sut, getUserPaymentSettingsSpy, _) = makeSUT()
        
        expect(sut, with: .getUserPaymentSettings, toDeliver: .loadedUserPaymentSettings(failure), on: {
            
            getUserPaymentSettingsSpy.complete(with: failure)
        })
    }
    
    func test_getUserPaymentSettings_shouldDeliverLoadedServerErrorOnServerErrorFailure() {
        
        let failure = anyServerErrorSettings()
        let (sut, getUserPaymentSettingsSpy, _) = makeSUT()
        
        expect(sut, with: .getUserPaymentSettings, toDeliver: .loadedUserPaymentSettings(failure), on: {
            
            getUserPaymentSettingsSpy.complete(with: failure)
        })
    }
    
    // MARK: - activateContract
    
    func test_activateContract_shouldPassPayload() {
        
        let currentContract = anyPaymentContract()
        let (sut, _, updateContractSpy) = makeSUT()
        
        sut.handleEffect(.activateContract(currentContract)) { _ in }
        
        XCTAssertNoDiff(updateContractSpy.payloads.map(\.0), [currentContract])
        XCTAssertNoDiff(updateContractSpy.payloads.map(\.1), [.activate])
    }
    
    func test_activateContract_shouldDeliverContractUpdateSuccessOnSuccessActivation() {
        
        let currentContract = anyPaymentContract()
        let activatedContract = anyActivePaymentContract()
        let (sut, _, updateContractSpy) = makeSUT()
        
        expect(sut, with: .activateContract(currentContract), toDeliver: .contractUpdate(.success(activatedContract)), on: {
            
            updateContractSpy.complete(with: .success(activatedContract))
        })
    }
    
    func test_activateContract_shouldDeliverContractUpdateConnectivityFailureOnConnectivityError() {
        
        let currentContract = anyPaymentContract()
        let activatedContract = anyActivePaymentContract()
        let (sut, _, updateContractSpy) = makeSUT()
        
        expect(sut, with: .activateContract(currentContract), toDeliver: .contractUpdate(.failure(.connectivityError)), on: {
            
            updateContractSpy.complete(with: .failure(.connectivityError))
        })
    }
    
    func test_activateContract_shouldDeliverContractUpdateServerErrorFailureOnServerError() {
        
        let currentContract = anyPaymentContract()
        let activatedContract = anyActivePaymentContract()
        let message = UUID().uuidString
        let (sut, _, updateContractSpy) = makeSUT()
        
        expect(sut, with: .activateContract(currentContract), toDeliver: .contractUpdate(.failure(.serverError(message))), on: {
            
            updateContractSpy.complete(with: .failure(.serverError(message)))
        })
    }
    
    // MARK: - Helpers
    
    private typealias SUT = FastPaymentsSettingsEffectHandler
    private typealias State = SUT.State
    private typealias Event = SUT.Event
    private typealias Effect = SUT.Effect
    
    private typealias GetUserPaymentSettingsSpy = Spy<Void, UserPaymentSettings>
    private typealias UpdateContractSpy = Spy<SUT.UpdateContractPayload, SUT.UpdateContractResponse>
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        getUserPaymentSettingsSpy: GetUserPaymentSettingsSpy,
        updateContractSpy: UpdateContractSpy
    ) {
        let getUserPaymentSettingsSpy = GetUserPaymentSettingsSpy()
        let updateContractSpy = UpdateContractSpy()
        let sut = SUT(
            getUserPaymentSettings: getUserPaymentSettingsSpy.process(completion:),
            updateContract: updateContractSpy.process(_:completion:)
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(getUserPaymentSettingsSpy, file: file, line: line)
        trackForMemoryLeaks(updateContractSpy, file: file, line: line)
        
        return (sut, getUserPaymentSettingsSpy, updateContractSpy)
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
