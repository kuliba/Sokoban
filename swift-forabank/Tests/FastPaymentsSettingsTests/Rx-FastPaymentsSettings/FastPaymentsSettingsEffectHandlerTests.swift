//
//  FastPaymentsSettingsEffectHandlerTests.swift
//
//
//  Created by Igor Malyarov on 15.01.2024.
//

final class FastPaymentsSettingsEffectHandler {
    
    private let getUserPaymentSettings: GetUserPaymentSettings

    init(
        getUserPaymentSettings: @escaping GetUserPaymentSettings
    ) {
        self.getUserPaymentSettings = getUserPaymentSettings
    }
}

extension FastPaymentsSettingsEffectHandler {
    
    func handleEffect(
        _ effect: Effect,
        _ dispatch: @escaping Dispatch
    ) {
        switch effect {
        case .getUserPaymentSettings:
            getUserPaymentSettings(dispatch)
        }
    }
}

// micro-service `abc`
extension FastPaymentsSettingsEffectHandler {
    
    typealias GetUserPaymentSettings = (@escaping (UserPaymentSettings) -> Void) -> Void
}

extension FastPaymentsSettingsEffectHandler {
    
    typealias Dispatch = (Event) -> Void
    
    typealias State = FastPaymentsSettingsState
    typealias Event = FastPaymentsSettingsEvent
    typealias Effect = FastPaymentsSettingsEffect
}

private extension FastPaymentsSettingsEffectHandler {
    
    func getUserPaymentSettings(
        _ dispatch: @escaping Dispatch
    ) {
        getUserPaymentSettings {
            
            dispatch(.loadedUserPaymentSettings($0))
        }
    }
}

import FastPaymentsSettings
import XCTest

final class FastPaymentsSettingsEffectHandlerTests: XCTestCase {
    
    func test_init_shouldNotCallCollaborators() {
        
        let (_, getUserPaymentSettings) = makeSUT()
        
        XCTAssertNoDiff(getUserPaymentSettings.callCount, 0)
    }
    
    // MARK: - getUserPaymentSettings
    
    func test_getUserPaymentSettings_shouldDeliverLoadedContractedOnContracted() {
        
        let contracted = anyContractedSettings()
        let (sut, getUserPaymentSettings) = makeSUT()
        
        expect(sut, with: .getUserPaymentSettings, toDeliver: .loadedUserPaymentSettings(contracted), on: {
            
            getUserPaymentSettings.complete(with: contracted)
        })
    }
    
    func test_getUserPaymentSettings_shouldDeliverLoadedMissingSuccessOnMissingSuccess() {
        
        let missingSuccess = anyMissingSuccessSettings()
        let (sut, getUserPaymentSettings) = makeSUT()
        
        expect(sut, with: .getUserPaymentSettings, toDeliver: .loadedUserPaymentSettings(missingSuccess), on: {
            
            getUserPaymentSettings.complete(with: missingSuccess)
        })
    }
    
    func test_getUserPaymentSettings_shouldDeliverLoadedMissingFailureOnMissingFailure() {
        
        let missingFailure = anyMissingFailureSettings()
        let (sut, getUserPaymentSettings) = makeSUT()
        
        expect(sut, with: .getUserPaymentSettings, toDeliver: .loadedUserPaymentSettings(missingFailure), on: {
            
            getUserPaymentSettings.complete(with: missingFailure)
        })
    }
    
    func test_getUserPaymentSettings_shouldDeliverLoadedConnectivityErrorOnConnectivityErrorFailure() {
        
        let failure: UserPaymentSettings = .failure(.connectivityError)
        let (sut, getUserPaymentSettings) = makeSUT()
        
        expect(sut, with: .getUserPaymentSettings, toDeliver: .loadedUserPaymentSettings(failure), on: {
            
            getUserPaymentSettings.complete(with: failure)
        })
    }
    
    func test_getUserPaymentSettings_shouldDeliverLoadedServerErrorOnServerErrorFailure() {
        
        let failure = anyServerErrorSettings()
        let (sut, getUserPaymentSettings) = makeSUT()
        
        expect(sut, with: .getUserPaymentSettings, toDeliver: .loadedUserPaymentSettings(failure), on: {
            
            getUserPaymentSettings.complete(with: failure)
        })
    }
    
    // MARK: - Helpers
    
    private typealias SUT = FastPaymentsSettingsEffectHandler
    private typealias State = SUT.State
    private typealias Event = SUT.Event
    private typealias Effect = SUT.Effect
    
    private typealias GetUserPaymentSettingsSpy = Spy<Void, UserPaymentSettings>
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        getUserPaymentSettings: GetUserPaymentSettingsSpy
    ) {
        let getUserPaymentSettings = GetUserPaymentSettingsSpy()
        let sut = SUT(
            getUserPaymentSettings: getUserPaymentSettings.process(completion:)
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(getUserPaymentSettings, file: file, line: line)
        
        return (sut, getUserPaymentSettings)
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
