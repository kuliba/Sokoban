//
//  FastPaymentsSettingsRxReducerTests.swift
//
//
//  Created by Igor Malyarov on 15.01.2024.
//

import FastPaymentsSettings
import XCTest

final class FastPaymentsSettingsRxReducerTests: XCTestCase {
    
    // MARK: - appear
    
    func test_appear_shouldSetStatusToInflight_emptyState() {
        
        let emptyState: State = .init()
        
        assert(emptyState, .appear, reducedTo: .init(status: .inflight))
    }
    
    func test_appear_shouldDeliverGetUserPaymentSettingsEffect_emptyState() {
        
        let emptyState: State = .init()
        
        assert(emptyState, .appear, effect: .getUserPaymentSettings)
    }
    
    func test_appear_shouldSetStatusToInflight_nonEmptyState() {
        
        let userPaymentSettings = anyContractedSettings()
        let state: State = .init(userPaymentSettings: userPaymentSettings)
        
        assert(state, .appear, reducedTo: .init(
            userPaymentSettings: userPaymentSettings,
            status: .inflight
        ))
    }
    
    func test_appear_shouldDeliverGetUserPaymentSettingsEffect_nonEmptyState() {
        
        let userPaymentSettings = anyContractedSettings()
        let state: State = .init(userPaymentSettings: userPaymentSettings)
        
        assert(state, .appear, effect: .getUserPaymentSettings)
    }
    
    // MARK: - loadedUserPaymentSettings
    
    func test_loadedUserPaymentSettings_shouldSetStateToSettingsWithoutStatus_emptyState() {
        
        let state: State = .init(status: .inflight)
        let loaded = anyContractedSettings()
        
        assert(state, .loadedUserPaymentSettings(loaded), reducedTo: .init(
            userPaymentSettings: loaded,
            status: nil
        ))
    }
    
    func test_loadedUserPaymentSettings_shouldNotDeliverEffect_emptyState() {
        
        let state: State = .init(status: .inflight)
        let loaded = anyContractedSettings()
        
        assert(state, .loadedUserPaymentSettings(loaded), effect: nil)
    }
    
    func test_loadedUserPaymentSettings_shouldSetStateToLoadedSettingsWithoutStatus_nonEmptyState() {
        
        let contracted = anyContractedSettings()
        let loaded = anyContractedSettings()
        let state: State = .init(
            userPaymentSettings: contracted,
            status: .inflight
        )
        
        assert(state, .loadedUserPaymentSettings(loaded), reducedTo: .init(
            userPaymentSettings: loaded,
            status: nil
        ))
    }
    
    func test_loadedUserPaymentSettings_shouldNotDeliverEffect_nonEmptyState() {
        
        let contracted = anyContractedSettings()
        let loaded = anyContractedSettings()
        let state: State = .init(
            userPaymentSettings: contracted,
            status: .inflight
        )
        
        assert(state, .loadedUserPaymentSettings(loaded), effect: nil)
    }
    
    // MARK: - activateContract
    
    func test_activateContract_shouldNotChangeStateOnEmpty() {
        
        let activeContract = FastPaymentsSettingsState()
        
        assert(activeContract, .activateContract, reducedTo: activeContract)
    }
    
    func test_activateContract_shouldNotDeliverEffectOnEmpty() {
        
        let activeContract = FastPaymentsSettingsState()
        
        assert(activeContract, .activateContract, effect: nil)
    }
    
    func test_activateContract_shouldNotChangeStateOnActiveContract() {
        
        let activeContract = FastPaymentsSettingsState(
            userPaymentSettings: anyActiveContractSettings()
        )
        
        assert(activeContract, .activateContract, reducedTo: activeContract)
    }
    
    func test_activateContract_shouldNotDeliverEffectOnActiveContract() {
        
        let activeContract = FastPaymentsSettingsState(
            userPaymentSettings: anyActiveContractSettings()
        )
        
        assert(activeContract, .activateContract, effect: nil)
    }
    
    func test_activateContract_shouldChangeStatusToInflightOnInactiveContract() {
        
        let inactive = anyInactiveContractSettings()
        let inactiveContract = FastPaymentsSettingsState(
            userPaymentSettings: inactive
        )
        
        assert(inactiveContract, .activateContract, reducedTo: .init(
            userPaymentSettings: inactive,
            status: .inflight
        ))
    }
    
    func test_activateContract_shouldDeliverEffectOnInactiveContract() {
        
        let inactiveDetails = anyInactiveContractDetails()
        let inactiveSettings = anyContractedSettings(inactiveDetails)
        let inactiveContract = FastPaymentsSettingsState(
            userPaymentSettings: inactiveSettings
        )
        
        assert(inactiveContract, .activateContract, effect: .activateContract(inactiveDetails.paymentContract))
    }
    
    //    func test_activateContract_shouldChangeStatusToInflightOnMissingFailureContract() {
    //
    //        let missing = anyMissingFailureSettings()
    //        let missingContract = FastPaymentsSettingsState(
    //            userPaymentSettings: missing
    //        )
    //
    //        XCTAssertNoDiff(
    //            reduce(makeSUT(), missingContract, .activateContract).state,
    //            .init(
    //                userPaymentSettings: missing,
    //                status: .inflight
    //            )
    //        )
    //    }
    
    //    func test_activateContract_shouldDeliverEffectOnMissingFailureContract() {
    //
    //        let missing = anyMissingFailureSettings()
    //        let missingContract = FastPaymentsSettingsState(
    //            userPaymentSettings: missing
    //        )
    //
    //        XCTAssertNoDiff(
    //            reduce(makeSUT(), missingContract, .activateContract).effect,
    //            .activateContract
    //        )
    //    }
    
    //    func test_activateContract_shouldChangeStatusToInflightOnMissingSuccessContract() {
    //
    //        let missing = anyMissingSuccessSettings()
    //        let missingContract = FastPaymentsSettingsState(
    //            userPaymentSettings: missing
    //        )
    //
    //        XCTAssertNoDiff(
    //            reduce(makeSUT(), missingContract, .activateContract).state,
    //            .init(
    //                userPaymentSettings: missing,
    //                status: .inflight
    //            )
    //        )
    //    }
    
    //    func test_activateContract_shouldDeliverEffectOnMissingSuccessContract() {
    //
    //        let missing = anyMissingSuccessSettings()
    //        let missingContract = FastPaymentsSettingsState(
    //            userPaymentSettings: missing
    //        )
    //
    //        XCTAssertNoDiff(
    //            reduce(makeSUT(), missingContract, .activateContract).effect,
    //            .activateContract
    //        )
    //    }
    
    func test_activateContract_shouldNotChangeStateOnConnectivityErrorFailure() {
        
        let connectivityFailure = FastPaymentsSettingsState(
            userPaymentSettings: .failure(.connectivityError)
        )
        
        assert(connectivityFailure, .activateContract, reducedTo: connectivityFailure)
    }
    
    func test_activateContract_shouldNotDeliverEffectOnConnectivityErrorFailure() {
        
        let connectivityFailure = FastPaymentsSettingsState(
            userPaymentSettings: .failure(.connectivityError)
        )
        
        assert(connectivityFailure, .activateContract, effect: nil)
    }
    
    func test_activateContract_shouldNotChangeStateOnServerErrorFailure() {
        
        let serverErrorFailure = FastPaymentsSettingsState(
            userPaymentSettings: .failure(.connectivityError)
        )
        
        assert(serverErrorFailure, .activateContract, reducedTo: serverErrorFailure)
    }
    
    func test_activateContract_shouldNotDeliverEffectOnServerErrorFailure() {
        
        let serverErrorFailure = FastPaymentsSettingsState(
            userPaymentSettings: anyActiveContractSettings()
        )
        
        assert(serverErrorFailure, .activateContract, effect: nil)
    }
    
    // MARK: - Helpers
    
    private typealias SUT = FastPaymentsSettingsRxReducer
    private typealias State = SUT.State
    private typealias Event = SUT.Event
    private typealias Effect = SUT.Effect
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> SUT {
        
        let sut = SUT()
        
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return sut
    }
    
    private func assert(
        _ state: State,
        _ event: Event,
        reducedTo expectedState: State,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let receivedState = reduce(makeSUT(), state, event).state
        
        XCTAssertNoDiff(
            receivedState,
            expectedState,
            "\nExpected \(expectedState) state, but got \(receivedState) instead.",
            file: file, line: line
        )
    }
    
    private func assert(
        _ state: State,
        _ event: Event,
        effect expectedEffect: Effect?,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let receivedEffect = reduce(makeSUT(), state, event).effect
        
        XCTAssertNoDiff(
            receivedEffect,
            expectedEffect,
            "\nExpected \(String(describing: expectedEffect)) state, but got \(String(describing: receivedEffect)) instead.",
            file: file, line: line
        )
    }
    
    private func reduce(
        _ sut: SUT,
        _ state: State,
        _ event: Event
    ) -> (state: State, effect: Effect?) {
        
        sut.reduce(state, event)
    }
}
