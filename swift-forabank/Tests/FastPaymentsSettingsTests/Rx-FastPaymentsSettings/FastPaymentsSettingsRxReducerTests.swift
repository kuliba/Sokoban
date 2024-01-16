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
        
        let emptyState = makeFPSState()
        
        assert(emptyState, .appear, reducedTo: .init(status: .inflight))
    }
    
    func test_appear_shouldDeliverGetUserPaymentSettingsEffect_emptyState() {
        
        let emptyState = makeFPSState()
        
        assert(emptyState, .appear, effect: .getSettings)
    }
    
    func test_appear_shouldSetStatusToInflight_nonEmptyState() {
        
        let nonEmptySetting = anyContractedSettings()
        
        assert(nonEmptySetting, .appear, reducedTo: .init(
            userPaymentSettings: nonEmptySetting,
            status: .inflight
        ))
    }
    
    func test_appear_shouldDeliverGetUserPaymentSettingsEffect_nonEmptyState() {
        
        let nonEmptySetting = anyContractedSettings()
        
        assert(nonEmptySetting, .appear, effect: .getSettings)
    }
    
    // MARK: - loadedSettings
    
    func test_loadedSettings_shouldSetStateToSettingsWithoutStatus_emptyState() {
        
        let state = makeFPSState(status: .inflight)
        let loaded = anyContractedSettings()
        
        assert(state, .loadedSettings(loaded), reducedTo: .init(
            userPaymentSettings: loaded,
            status: nil
        ))
    }
    
    func test_loadedSettings_shouldNotDeliverEffect_emptyState() {
        
        let state = makeFPSState(status: .inflight)
        let loaded = anyContractedSettings()
        
        assert(state, .loadedSettings(loaded), effect: nil)
    }
    
    func test_loadedSettings_shouldSetStateToLoadedSettingsWithoutStatus_nonEmptyState() {
        
        let contracted = anyContractedSettings()
        let loaded = anyContractedSettings()
        let state = makeFPSState(contracted, status: .inflight)
        
        assert(state, .loadedSettings(loaded), reducedTo: .init(
            userPaymentSettings: loaded,
            status: nil
        ))
    }
    
    func test_loadedSettings_shouldNotDeliverEffect_nonEmptyState() {
        
        let contracted = anyContractedSettings()
        let loaded = anyContractedSettings()
        let state = makeFPSState(contracted, status: .inflight)
        
        assert(state, .loadedSettings(loaded), effect: nil)
    }
    
    // MARK: - activateContract
    
    func test_activateContract_shouldNotChangeStateOnEmpty() {
        
        let empty = makeFPSState()
        
        assert(empty, .activateContract, reducedTo: empty)
    }
    
    func test_activateContract_shouldNotDeliverEffectOnEmpty() {
        
        let empty = makeFPSState()
        
        assert(empty, .activateContract, effect: nil)
    }
    
    func test_activateContract_shouldNotChangeStateOnActiveContract() {
        
        let activeContract = makeFPSState(anyActiveContractSettings())
        
        assert(activeContract, .activateContract, reducedTo: activeContract)
    }
    
    func test_activateContract_shouldNotDeliverEffectOnActiveContract() {
        
        let activeContract = makeFPSState(anyActiveContractSettings())
        
        assert(activeContract, .activateContract, effect: nil)
    }
    
    func test_activateContract_shouldChangeStatusToInflightOnInactiveContract() {
        
        let inactive = anyInactiveContractSettings()
        
        assert(inactive, .activateContract, reducedTo: .init(
            userPaymentSettings: inactive,
            status: .inflight
        ))
    }
    
    func test_activateContract_shouldDeliverEffectOnInactiveContract() {
        
        let inactiveDetails = anyInactiveContractDetails()
        let inactive = anyContractedSettings(inactiveDetails)
        let target = target(inactiveDetails, .active)
        
        assert(inactive, .activateContract, effect: .activateContract(target))
    }
    
    func test_activateContract_shouldChangeStatusToMissingProductOnMissingProductAtMissingSettingsWithConsentFailure() {
        
        let missing = anyMissingConsentFailureSettings()
        let sut = makeSUT(product: nil)
        
        assert(sut: sut, missing, .activateContract, reducedTo: .init(
            userPaymentSettings: missing,
            status: .missingProduct
        ))
    }
    
    func test_activateContract_shouldNotDeliverEffectOnMissingProductAtMissingSettingsWithConsentFailure() {
        
        let missing = anyMissingConsentFailureSettings()
        let sut = makeSUT(product: nil)
        
        assert(sut: sut, missing, .activateContract, effect: nil)
    }
    
    func test_activateContract_shouldChangeStatusToInflightOnAvailableProductAtMissingSettingsWithConsentFailure() {
        
        let missing = anyMissingConsentFailureSettings()
        let sut = makeSUT(product: anyProduct())
        
        assert(sut: sut, missing, .activateContract, reducedTo: .init(
            userPaymentSettings: missing,
            status: .inflight
        ))
    }
    
    func test_activateContract_shouldDeliverEffectOnAvailableProductAtMissingSettingsWithConsentFailure() {
        
        let missing = anyMissingConsentFailureSettings()
        let product = anyProduct()
        let sut = makeSUT(product: product)
        
        assert(sut: sut, missing, .activateContract, effect: .createContract(.init(product.id.rawValue)))
    }
    
    func test_activateContract_shouldChangeStatusToMissingProductOnMissingProductAtMissingSettingsWithConsentSuccess() {
        
        let missing = anyMissingConsentSuccessSettings()
        let sut = makeSUT(product: nil)
        
        assert(sut: sut, missing, .activateContract, reducedTo: .init(
            userPaymentSettings: missing,
            status: .missingProduct
        ))
    }
    
    func test_activateContract_shouldNotDeliverEffectOnMissingProductAtMissingSettingsWithConsentSuccess() {
        
        let missing = anyMissingConsentSuccessSettings()
        let sut = makeSUT(product: nil)
        
        assert(sut: sut, missing, .activateContract, effect: nil)
    }
    
    func test_activateContract_shouldChangeStatusToInflightOnAvailableProductAtMissingSettingsWithConsentSuccess() {
        
        let missing = anyMissingConsentSuccessSettings()
        let sut = makeSUT(product: anyProduct())
        
        assert(sut: sut, missing, .activateContract, reducedTo: .init(
            userPaymentSettings: missing,
            status: .inflight
        ))
    }
    
    func test_activateContract_shouldDeliverEffectOnAvailableProductAtMissingSettingsWithConsentSuccess() {
        
        let missing = anyMissingConsentSuccessSettings()
        let product = anyProduct()
        let sut = makeSUT(product: product)
        
        assert(sut: sut, missing, .activateContract, effect: .createContract(.init(product.id.rawValue)))
    }
    
    func test_activateContract_shouldNotChangeStateOnConnectivityErrorFailure() {
        
        let connectivityFailure = makeFPSState(.failure(.connectivityError))
        
        assert(connectivityFailure, .activateContract, reducedTo: connectivityFailure)
    }
    
    func test_activateContract_shouldNotDeliverEffectOnConnectivityErrorFailure() {
        
        let connectivityFailure = makeFPSState(.failure(.connectivityError))
        
        assert(connectivityFailure, .activateContract, effect: nil)
    }
    
    func test_activateContract_shouldNotChangeStateOnServerErrorFailure() {
        
        let serverErrorFailure = makeFPSState(.failure(.connectivityError))
        
        assert(serverErrorFailure, .activateContract, reducedTo: serverErrorFailure)
    }
    
    func test_activateContract_shouldNotDeliverEffectOnServerErrorFailure() {
        
        let serverErrorFailure = makeFPSState(anyActiveContractSettings())
        
        assert(serverErrorFailure, .activateContract, effect: nil)
    }
    
    // MARK: - contractUpdate
    
    func test_contractUpdate_shouldSetContractOnSuccess_active() {
        
        let active = anyPaymentContract(contractStatus: .active)
        let details = anyContractDetails(paymentContract: active)
        let activeContract = makeFPSState(.contracted(details))
        let newContract = anyPaymentContract()
        
        assert(
            activeContract,
            .contractUpdate(.success(newContract)),
            reducedTo: .init(
                userPaymentSettings: .contracted(.init(
                    paymentContract: newContract,
                    consentResult: details.consentResult,
                    bankDefault: details.bankDefault,
                    product: details.product
                ))
            )
        )
    }
    
    func test_contractUpdate_shouldNotDeliverEffectOnSuccess_active() {
        
        let activeContract = makeFPSState(anyActiveContractSettings())
        let newContract = anyPaymentContract()
        
        assert(activeContract, .contractUpdate(.success(newContract)), effect: nil)
    }
    
    func test_contractUpdate_shouldSetStatusToConnectivityErrorOnConnectivityFailure_active() {
        
        let active = anyPaymentContract(contractStatus: .active)
        let details = anyContractDetails(paymentContract: active)
        let activeContract = makeFPSState(.contracted(details))
        
        assert(
            activeContract,
            .contractUpdate(.failure(.connectivityError)),
            reducedTo: .init(
                userPaymentSettings: .contracted(details),
                status: .connectivityError
            )
        )
    }
    
    func test_contractUpdate_shouldNotDeliverEffectOnConnectivityFailure_active() {
        
        let activeContract = makeFPSState(anyActiveContractSettings())
        
        assert(activeContract, .contractUpdate(.failure(.connectivityError)), effect: nil)
    }
    
    func test_contractUpdate_shouldSetStatusToServerErrorOnServerErrorFailure_active() {
        
        let message = UUID().uuidString
        let active = anyPaymentContract(contractStatus: .active)
        let details = anyContractDetails(paymentContract: active)
        let activeContract = makeFPSState(.contracted(details))
        
        assert(
            activeContract,
            .contractUpdate(.failure(.serverError(message))),
            reducedTo: .init(
                userPaymentSettings: .contracted(details),
                status: .serverError(message)
            )
        )
    }
    
    func test_contractUpdate_shouldNotDeliverEffectOnServerErrorFailure_active() {
        
        let activeContract = makeFPSState(anyActiveContractSettings())
        
        assert(activeContract, .contractUpdate(.failure(.serverError(UUID().uuidString))), effect: nil)
    }
    
    func test_contractUpdate_shouldSetContractOnSuccess_inactive() {
        
        let inactive = anyPaymentContract(contractStatus: .inactive)
        let details = anyContractDetails(paymentContract: inactive)
        let inactiveContract = makeFPSState(.contracted(details))
        let newContract = anyPaymentContract()
        
        assert(
            inactiveContract,
            .contractUpdate(.success(newContract)),
            reducedTo: .init(
                userPaymentSettings: .contracted(.init(
                    paymentContract: newContract,
                    consentResult: details.consentResult,
                    bankDefault: details.bankDefault,
                    product: details.product
                ))
            )
        )
    }
    
    func test_contractUpdate_shouldNotDeliverEffectOnSuccess_inactive() {
        
        let inactiveContract = makeFPSState(anyInactiveContractSettings())
        let newContract = anyPaymentContract()
        
        assert(inactiveContract, .contractUpdate(.success(newContract)), effect: nil)
    }
    
    func test_contractUpdate_shouldSetStatusToConnectivityErrorOnConnectivityFailure_inactive() {
        
        let inactive = anyPaymentContract(contractStatus: .inactive)
        let details = anyContractDetails(paymentContract: inactive)
        let inactiveContract = makeFPSState(.contracted(details))
        
        assert(
            inactiveContract,
            .contractUpdate(.failure(.connectivityError)),
            reducedTo: .init(
                userPaymentSettings: .contracted(details),
                status: .connectivityError
            )
        )
    }
    
    func test_contractUpdate_shouldNotDeliverEffectOnConnectivityFailure_inactive() {
        
        let inactiveContract = makeFPSState(anyInactiveContractSettings())
        
        assert(inactiveContract, .contractUpdate(.failure(.connectivityError)), effect: nil)
    }
    
    func test_contractUpdate_shouldSetStatusToServerErrorOnServerErrorFailure_inactive() {
        
        let message = UUID().uuidString
        let inactive = anyPaymentContract(contractStatus: .inactive)
        let details = anyContractDetails(paymentContract: inactive)
        let inactiveContract = makeFPSState(.contracted(details))
        
        assert(
            inactiveContract,
            .contractUpdate(.failure(.serverError(message))),
            reducedTo: .init(
                userPaymentSettings: .contracted(details),
                status: .serverError(message)
            )
        )
    }
    
    func test_contractUpdate_shouldNotDeliverEffectOnServerErrorFailure_inactive() {
        
        let inactiveContract = makeFPSState(anyInactiveContractSettings())
        
        assert(inactiveContract, .contractUpdate(.failure(.serverError(UUID().uuidString))), effect: nil)
    }
    
    func test_contractUpdate_shouldSetContractOnSuccess_missing() {
        
        let newContract = anyPaymentContract()
        let consentResult: UserPaymentSettings.ConsentResult = .failure(.init())
        let missing: UserPaymentSettings = .missingContract(consentResult)
        let product = anyProduct()
        let sut = makeSUT(product: product)
        
        assert(
            sut: sut,
            missing,
            .contractUpdate(.success(newContract)),
            reducedTo: .init(
                userPaymentSettings: .contracted(.init(
                    paymentContract: newContract,
                    consentResult: consentResult,
                    bankDefault: .offEnabled,
                    product: product.settingsProduct
                ))
            )
        )
    }
    
    func test_contractUpdate_shouldNotDeliverEffectOnSuccess_missing() {
        
        let newContract = anyPaymentContract()
        let missing = anyMissingConsentSuccessSettings()
        let sut = makeSUT(product: anyProduct())
        
        assert(missing, .contractUpdate(.success(newContract)), effect: nil)
    }
    
    func test_contractUpdate_shouldSetStatusToConnectivityErrorOnConnectivityFailure_missing() {
        
        let missing = anyMissingConsentFailureSettings()
        let product = anyProduct()
        let sut = makeSUT(product: product)
        
        assert(
            sut: sut,
            missing,
            .contractUpdate(.failure(.connectivityError)),
            reducedTo: .init(
                userPaymentSettings: missing,
                status: .connectivityError
            )
        )
    }
    
    func test_contractUpdate_shouldNotDeliverEffectOnConnectivityFailure_missing() {
        
        let missing = anyMissingConsentSuccessSettings()
        let sut = makeSUT(product: anyProduct())
        
        assert(missing, .contractUpdate(.failure(.connectivityError)), effect: nil)
    }
    
    func test_contractUpdate_shouldSetStatusToServerErrorOnServerErrorFailure_missing() {
        
        let message = UUID().uuidString
        let missing = anyMissingConsentFailureSettings()
        let product = anyProduct()
        let sut = makeSUT(product: product)
        
        assert(
            sut: sut,
            missing,
            .contractUpdate(.failure(.serverError(message))),
            reducedTo: .init(
                userPaymentSettings: missing,
                status: .serverError(message)
            )
        )
    }
    
    func test_contractUpdate_shouldNotDeliverEffectOnServerErrorFailure_missing() {
        
        let missing = anyMissingConsentSuccessSettings()
        let sut = makeSUT(product: anyProduct())
        
        assert(missing, .contractUpdate(.failure(.serverError(UUID().uuidString))), effect: nil)
        
    }
    
    func test_contractUpdate_shouldNotChangeStateOnSuccess_connectivityError() {
        
        let newContract = anyPaymentContract()
        let connectivityError = makeFPSState(.failure(.connectivityError))
        
        assert(connectivityError, .contractUpdate(.success(newContract)), reducedTo: connectivityError)
    }
    
    func test_contractUpdate_shouldNotDeliverEffectOnSuccess_connectivityError() {
        
        let newContract = anyPaymentContract()
        let connectivityError = makeFPSState(.failure(.connectivityError))
        
        assert(connectivityError, .contractUpdate(.success(newContract)), effect: nil)
    }
    
    func test_contractUpdate_shouldNotChangeStateOnConnectivityFailure_connectivityError() {
        
        let connectivityError = makeFPSState(.failure(.connectivityError))
        
        assert(connectivityError, .contractUpdate(.failure(.connectivityError)), reducedTo: connectivityError)
    }
    
    func test_contractUpdate_shouldNotDeliverEffectOnConnectivityFailure_connectivityError() {
        
        let connectivityError = makeFPSState(.failure(.connectivityError))
        
        assert(connectivityError, .contractUpdate(.failure(.connectivityError)), effect: nil)
    }
    
    func test_contractUpdate_shouldNotChangeStateOnServerErrorFailure_connectivityError() {
        
        let connectivityError = makeFPSState(.failure(.connectivityError))
        
        assert(connectivityError, .contractUpdate(.failure(.serverError(UUID().uuidString))), reducedTo: connectivityError)
    }
    
    func test_contractUpdate_shouldNotDeliverEffectOnServerErrorFailure_connectivityError() {
        
        let connectivityError = makeFPSState(.failure(.connectivityError))
        
        assert(connectivityError, .contractUpdate(.failure(.serverError(UUID().uuidString))), effect: nil)
    }
    
    func test_contractUpdate_shouldNotChangeStateOnSuccess_serverError() {
        
        let newContract = anyPaymentContract()
        let serverError = makeFPSState(.failure(.serverError(UUID().uuidString)))
        
        assert(serverError, .contractUpdate(.success(newContract)), reducedTo: serverError)
    }
    
    func test_contractUpdate_shouldNotDeliverEffectOnSuccess_serverError() {
        
        let newContract = anyPaymentContract()
        let serverError = makeFPSState(.failure(.serverError(UUID().uuidString)))
        
        assert(serverError, .contractUpdate(.success(newContract)), effect: nil)
    }
    
    func test_contractUpdate_shouldNotChangeStateOnConnectivityFailure_serverError() {
        
        let serverError = makeFPSState(.failure(.serverError(UUID().uuidString)))
        
        assert(serverError, .contractUpdate(.failure(.connectivityError)), reducedTo: serverError)
    }
    
    func test_contractUpdate_shouldNotDeliverEffectOnConnectivityFailure_serverError() {
        
        let serverError = makeFPSState(.failure(.serverError(UUID().uuidString)))
        
        assert(serverError, .contractUpdate(.failure(.connectivityError)), effect: nil)
    }
    
    func test_contractUpdate_shouldNotChangeStateOnServerErrorFailure_serverError() {
        
        let serverError = makeFPSState(.failure(.serverError(UUID().uuidString)))
        
        assert(serverError, .contractUpdate(.failure(.serverError(UUID().uuidString))), reducedTo: serverError)
    }
    
    func test_contractUpdate_shouldNotDeliverEffectOnServerErrorFailure_serverError() {
        
        let serverError = makeFPSState(.failure(.serverError(UUID().uuidString)))
        
        assert(serverError, .contractUpdate(.failure(.serverError(UUID().uuidString))), effect: nil)
    }
    
    // MARK: - Helpers
    
    private typealias SUT = FastPaymentsSettingsRxReducer
    private typealias State = SUT.State
    private typealias Event = SUT.Event
    private typealias Effect = SUT.Effect
    
#warning("replace with `product: Product  = anyProduct()`")
    private func makeSUT(
        product: Product? = nil,
        file: StaticString = #file,
        line: UInt = #line
    ) -> SUT {
        
        let sut = SUT(getProduct: { product })
        
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return sut
    }
    
    private func assert(
        sut: SUT? = nil,
        _ settings: UserPaymentSettings,
        _ event: Event,
        reducedTo expectedState: State,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        assert(sut: sut, .init(userPaymentSettings: settings), event, reducedTo: expectedState, file: file, line: line)
    }
    
    private func assert(
        sut: SUT? = nil,
        _ state: State,
        _ event: Event,
        reducedTo expectedState: State,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let receivedState = reduce(sut ?? makeSUT(), state, event).state
        
        XCTAssertNoDiff(
            receivedState,
            expectedState,
            "\nExpected \(expectedState) state, but got \(receivedState) instead.",
            file: file, line: line
        )
    }
    
    private func assert(
        sut: SUT? = nil,
        _ settings: UserPaymentSettings,
        _ event: Event,
        effect expectedEffect: Effect?,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        assert(sut: sut, .init(userPaymentSettings: settings), event, effect: expectedEffect, file: file, line: line)
    }
    
    private func assert(
        sut: SUT? = nil,
        _ state: State,
        _ event: Event,
        effect expectedEffect: Effect?,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let receivedEffect = reduce(sut ?? makeSUT(), state, event).effect
        
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
    
    private func target(
        _ contractDetails: UserPaymentSettings.ContractDetails,
        _ targetStatus: FastPaymentsSettingsEffect.TargetContract.TargetStatus
    ) -> FastPaymentsSettingsEffect.TargetContract {
        
        .init(
            core: core(contractDetails),
            targetStatus: targetStatus
        )
    }
    
    private func core(
        _ contractDetails: UserPaymentSettings.ContractDetails
    ) -> FastPaymentsSettingsEffect.ContractCore {
        
        .init(
            contractID: .init(contractDetails.paymentContract.id.rawValue),
            productID: .init(contractDetails.product.id.rawValue),
            productType: productType(of: contractDetails.product)
        )
    }
    
    private func productType(
        of product: UserPaymentSettings.Product
    ) -> FastPaymentsSettingsEffect.ContractCore.ProductType {
        
        switch product.type {
        case .account: return .account
        case .card:    return .card
        }
    }
}

private extension Product {
    
    var settingsProduct: UserPaymentSettings.Product {
        
        .init(id: .init(id.rawValue), type: settingsProductType)
    }
    
    var settingsProductType: UserPaymentSettings.Product.ProductType {
        
        switch productType {
        case .account: return .account
        case .card:    return .card
        }
    }
}
