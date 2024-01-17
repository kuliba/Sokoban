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
        
        let empty = fastPaymentsSettingsState()
        
        assert(empty, .appear, reducedTo: .init(status: .inflight))
    }
    
    func test_appear_shouldDeliverGetUserPaymentSettingsEffect_emptyState() {
        
        let empty = fastPaymentsSettingsState()
        
        assert(empty, .appear, effect: .getSettings)
    }
    
    func test_appear_shouldSetStatusToInflight_nonEmptyState() {
        
        let nonEmpty = contractedSettings()
        
        assert(nonEmpty, .appear, reducedTo: .init(
            userPaymentSettings: nonEmpty,
            status: .inflight
        ))
    }
    
    func test_appear_shouldDeliverGetUserPaymentSettingsEffect_nonEmptyState() {
        
        let nonEmpty = contractedSettings()
        
        assert(nonEmpty, .appear, effect: .getSettings)
    }
    
    // MARK: - activateContract
    
    func test_activateContract_shouldNotChangeStateOnEmpty() {
        
        let empty = fastPaymentsSettingsState()
        
        assert(empty, .activateContract, reducedTo: empty)
    }
    
    func test_activateContract_shouldNotDeliverEffectOnEmpty() {
        
        let empty = fastPaymentsSettingsState()
        
        assert(empty, .activateContract, effect: nil)
    }
    
    func test_activateContract_shouldNotChangeStateOnActiveContract() {
        
        let active = contractedState(.active).state
        
        assert(active, .activateContract, reducedTo: active)
    }
    
    func test_activateContract_shouldNotDeliverEffectOnActiveContract() {
        
        let active = contractedState(.active).state
        
        assert(active, .activateContract, effect: nil)
    }
    
    func test_activateContract_shouldChangeStatusToInflightOnInactiveContract() {
        
        let inactive = inactiveContractSettings()
        
        assert(inactive, .activateContract, reducedTo: .init(
            userPaymentSettings: inactive,
            status: .inflight
        ))
    }
    
    func test_activateContract_shouldDeliverEffectOnInactiveContract() throws {
        
        let (details, inactive) = contractedState(.inactive)
#warning("add tests for branches")
        let target = try XCTUnwrap(target(details, .active))
        
        assert(inactive, .activateContract, effect: .activateContract(target))
    }
    
    func test_activateContract_shouldChangeStatusToMissingProductOnMissingProductAtMissingSettingsWithConsentFailure() {
        
        let missing = missingConsentFailureSettings()
        let sut = makeSUT(products: [])
        
        assert(sut: sut, missing, .activateContract, reducedTo: .init(
            userPaymentSettings: missing,
            status: .missingProduct
        ))
    }
    
    func test_activateContract_shouldNotDeliverEffectOnMissingProductAtMissingSettingsWithConsentFailure() {
        
        let missing = missingConsentFailureSettings()
        let sut = makeSUT(products: [])
        
        assert(sut: sut, missing, .activateContract, effect: nil)
    }
    
    func test_activateContract_shouldChangeStatusToInflightOnAvailableProductAtMissingSettingsWithConsentFailure() {
        
        let missing = missingConsentFailureSettings()
        let sut = makeSUT(products: [makeProduct()])
        
        assert(sut: sut, missing, .activateContract, reducedTo: .init(
            userPaymentSettings: missing,
            status: .inflight
        ))
    }
    
    func test_activateContract_shouldDeliverEffectOnAvailableProductAtMissingSettingsWithConsentFailure() {
        
        let missing = missingConsentFailureSettings()
        let product = makeProduct()
        let sut = makeSUT(products: [product])
        
        assert(sut: sut, missing, .activateContract, effect: .createContract(.init(product.id.rawValue)))
    }
    
    func test_activateContract_shouldChangeStatusToMissingProductOnMissingProductAtMissingSettingsWithConsentSuccess() {
        
        let missing = missingConsentSuccessSettings()
        let sut = makeSUT(products: [])
        
        assert(sut: sut, missing, .activateContract, reducedTo: .init(
            userPaymentSettings: missing,
            status: .missingProduct
        ))
    }
    
    func test_activateContract_shouldNotDeliverEffectOnMissingProductAtMissingSettingsWithConsentSuccess() {
        
        let missing = missingConsentSuccessSettings()
        let sut = makeSUT(products: [])
        
        assert(sut: sut, missing, .activateContract, effect: nil)
    }
    
    func test_activateContract_shouldChangeStatusToInflightOnAvailableProductAtMissingSettingsWithConsentSuccess() {
        
        let missing = missingConsentSuccessSettings()
        let sut = makeSUT(products: [makeProduct()])
        
        assert(sut: sut, missing, .activateContract, reducedTo: .init(
            userPaymentSettings: missing,
            status: .inflight
        ))
    }
    
    func test_activateContract_shouldDeliverEffectOnAvailableProductAtMissingSettingsWithConsentSuccess() {
        
        let missing = missingConsentSuccessSettings()
        let product = makeProduct()
        let sut = makeSUT(products: [product])
        
        assert(sut: sut, missing, .activateContract, effect: .createContract(.init(product.id.rawValue)))
    }
    
    func test_activateContract_shouldNotChangeStateOnConnectivityErrorFailure() {
        
        let connectivityError = connectivityErrorFPSState()
        
        assert(connectivityError, .activateContract, reducedTo: connectivityError)
    }
    
    func test_activateContract_shouldNotDeliverEffectOnConnectivityErrorFailure() {
        
        let connectivityError = connectivityErrorFPSState()
        
        assert(connectivityError, .activateContract, effect: nil)
    }
    
    func test_activateContract_shouldNotChangeStateOnServerErrorFailure() {
        
        let serverError = serverErrorFPSState()
        
        assert(serverError, .activateContract, reducedTo: serverError)
    }
    
    func test_activateContract_shouldNotDeliverEffectOnServerErrorFailure() {
        
        let serverError = serverErrorFPSState()
        
        assert(serverError, .activateContract, effect: nil)
    }
    
    // MARK: - collapseProducts
    
    func test_collapseProducts_shouldCollapseExpandedStateOnActive_expanded() {
        
        let (details, active) = contractedState(.active, selector: .expanded)
        
        assert(active, .collapseProducts, reducedTo: .init(
            userPaymentSettings: .contracted(details.updated(
                productSelector: details.productSelector.updated(
                    status: .collapsed
                )
            ))
        ))
    }
    
    func test_collapseProducts_shouldNotChangeStateOnActive_collapsed() {
        
        let active = contractedState(.active, selector: .collapsed).state
        
        assert(active, .collapseProducts, reducedTo: active)
    }
    
    func test_collapseProducts_shouldNotDeliverEffectOnActive() {
        
        let active = contractedState(.active).state
        
        assert(active, .collapseProducts, effect: nil)
    }
    
    func test_collapseProducts_shouldNotChangeStateOnInactive() {
        
        let inactive = contractedState(.inactive).state
        
        assert(inactive, .collapseProducts, reducedTo: inactive)
    }
    
    func test_collapseProducts_shouldNotDeliverEffectOnInactive() {
        
        let inactive = contractedState(.inactive).state
        
        assert(inactive, .collapseProducts, effect: nil)
    }
    
    func test_collapseProducts_shouldNotChangeStateOnMissing() {
        
        let missing = missingConsentSuccessFPSState()
        
        assert(missing, .collapseProducts, reducedTo: missing)
    }
    
    func test_collapseProducts_shouldNotDeliverEffectOnMissing() {
        
        let missing = missingConsentSuccessFPSState()
        
        assert(missing, .collapseProducts, effect: nil)
    }
    
    func test_collapseProducts_shouldNotChangeStateOnConnectivityErrorFailure() {
        
        let connectivityError = connectivityErrorFPSState()
        
        assert(connectivityError, .collapseProducts, reducedTo: connectivityError)
    }
    
    func test_collapseProducts_shouldNotDeliverEffectOnConnectivityErrorFailure() {
        
        let connectivityError = connectivityErrorFPSState()
        
        assert(connectivityError, .collapseProducts, effect: nil)
    }
    
    func test_collapseProducts_shouldNotChangeStateOnServerErrorFailure() {
        
        let serverError = serverErrorFPSState()
        
        assert(serverError, .collapseProducts, reducedTo: serverError)
    }
    
    func test_collapseProducts_shouldNotDeliverEffectOnServerErrorFailure() {
        
        let serverError = serverErrorFPSState()
        
        assert(serverError, .collapseProducts, effect: nil)
    }
    
    // MARK: - deactivateContract
    
    func test_deactivateContract_shouldChangeStatusToInflightOnActive() {
        
        let active = activeContractSettings()
        
        assert(
            active,
            .deactivateContract,
            reducedTo: .init(
                userPaymentSettings: active,
                status: .inflight
            )
        )
    }
    
    func test_deactivateContract_shouldDeliverEffectOnActive() throws{
        
        let (details, active) = contractedState(.active)
#warning("add tests for branches")
        let target = try XCTUnwrap(target(details, .inactive))
        
        assert(active, .deactivateContract, effect: .deactivateContract(target))
    }
    
    func test_deactivateContract_shouldNotChangeStateOnInactive() {
        
        let inactive = contractedState(.inactive).state
        
        assert(inactive, .deactivateContract, reducedTo: inactive)
    }
    
    func test_deactivateContract_shouldNotDeliverEffectOnInactive() {
        
        let inactive = contractedState(.inactive).state
        
        assert(inactive, .deactivateContract, effect: nil)
    }
    
    func test_deactivateContract_shouldNotChangeStateOnMissing() {
        
        let missing = missingConsentSuccessFPSState()
        
        assert(missing, .deactivateContract, reducedTo: missing)
    }
    
    func test_deactivateContract_shouldNotDeliverEffectOnMissing() {
        
        let missing = missingConsentSuccessFPSState()
        
        assert(missing, .deactivateContract, effect: nil)
    }
    
    func test_deactivateContract_shouldNotChangeStateOnConnectivityError() {
        
        let connectivityError = connectivityErrorFPSState()
        
        assert(connectivityError, .deactivateContract, reducedTo: connectivityError)
    }
    
    func test_deactivateContract_shouldNotDeliverEffectOnConnectivityError() {
        
        let connectivityError = connectivityErrorFPSState()
        
        assert(connectivityError, .deactivateContract, effect: nil)
    }
    
    func test_deactivateContract_shouldNotChangeStateOnServerError() {
        
        let serverError = serverErrorFPSState()
        
        assert(serverError, .deactivateContract, reducedTo: serverError)
    }
    
    func test_deactivateContract_shouldNotDeliverEffectOnServerError() {
        
        let serverError = serverErrorFPSState()
        
        assert(serverError, .deactivateContract, effect: nil)
    }
    
    // MARK: - expandProducts
    
    func test_expandProducts_shouldExpandCollapsedStateOnActive_collapsed() {
        
        let (details, active) = contractedState(.active, selector: .collapsed)
        
        assert(active, .expandProducts, reducedTo: .init(
            userPaymentSettings: .contracted(details.updated(
                productSelector: details.productSelector.updated(
                    status: .expanded
                )
            ))
        ))
    }
    
    func test_expandProducts_shouldNotChangeStateOnActive_expanded() {
        
        let active = contractedState(.active, selector: .expanded).state
        
        assert(active, .expandProducts, reducedTo: active)
    }
    
    func test_expandProducts_shouldNotDeliverEffectOnActive() {
        
        let active = contractedState(.active).state
        
        assert(active, .expandProducts, effect: nil)
    }
    
    func test_expandProducts_shouldNotChangeStateOnInactive() {
        
        let inactive = contractedState(.inactive).state
        
        assert(inactive, .expandProducts, reducedTo: inactive)
    }
    
    func test_expandProducts_shouldNotDeliverEffectOnInactive() {
        
        let inactive = contractedState(.inactive).state
        
        assert(inactive, .expandProducts, effect: nil)
    }
    
    func test_expandProducts_shouldNotChangeStateOnMissing() {
        
        let missing = missingConsentSuccessFPSState()
        
        assert(missing, .expandProducts, reducedTo: missing)
    }
    
    func test_expandProducts_shouldNotDeliverEffectOnMissing() {
        
        let missing = missingConsentSuccessFPSState()
        
        assert(missing, .expandProducts, effect: nil)
    }
    
    func test_expandProducts_shouldNotChangeStateOnConnectivityErrorFailure() {
        
        let connectivityError = connectivityErrorFPSState()
        
        assert(connectivityError, .expandProducts, reducedTo: connectivityError)
    }
    
    func test_expandProducts_shouldNotDeliverEffectOnConnectivityErrorFailure() {
        
        let connectivityError = connectivityErrorFPSState()
        
        assert(connectivityError, .expandProducts, effect: nil)
    }
    
    func test_expandProducts_shouldNotChangeStateOnServerErrorFailure() {
        
        let serverError = serverErrorFPSState()
        
        assert(serverError, .expandProducts, reducedTo: serverError)
    }
    
    func test_expandProducts_shouldNotDeliverEffectOnServerErrorFailure() {
        
        let serverError = serverErrorFPSState()
        
        assert(serverError, .expandProducts, effect: nil)
    }
    
    // MARK: - loadSettings
    
    func test_loadSettings_shouldSetStateToSettingsWithoutStatus_emptyState() {
        
        let state = fastPaymentsSettingsState(status: .inflight)
        let loaded = contractedSettings()
        
        assert(state, .loadSettings(loaded), reducedTo: .init(
            userPaymentSettings: loaded,
            status: nil
        ))
    }
    
    func test_loadSettings_shouldNotDeliverEffect_emptyState() {
        
        let state = fastPaymentsSettingsState(status: .inflight)
        let loaded = contractedSettings()
        
        assert(state, .loadSettings(loaded), effect: nil)
    }
    
    func test_loadSettings_shouldSetStateToLoadedSettingsWithoutStatus_nonEmptyState() {
        
        let contracted = contractedSettings()
        let loaded = contractedSettings()
        let state = fastPaymentsSettingsState(contracted, status: .inflight)
        
        assert(state, .loadSettings(loaded), reducedTo: .init(
            userPaymentSettings: loaded,
            status: nil
        ))
    }
    
    func test_loadSettings_shouldNotDeliverEffect_nonEmptyState() {
        
        let contracted = contractedSettings()
        let loaded = contractedSettings()
        let state = fastPaymentsSettingsState(contracted, status: .inflight)
        
        assert(state, .loadSettings(loaded), effect: nil)
    }
    
    // MARK: - prepareSetBankDefault
    
    func test_prepareSetBankDefault_shouldResetStatusOnActive_offEnabled_setBankDefaultStatus() {
        
        let (details, active) = contractedState(
            .active,
            bankDefault: .offEnabled,
            status: .setBankDefault
        )
        
        assert(active, .prepareSetBankDefault, reducedTo: .init(
            userPaymentSettings: .contracted(details),
            status: nil
        ))
    }
    
    func test_prepareSetBankDefault_shouldDeliverEffectOnActive_offEnabled_setBankDefaultStatus() {
        
        let (_, active) = contractedState(
            .active,
            bankDefault: .offEnabled,
            status: .setBankDefault
        )
        
        assert(active, .prepareSetBankDefault, effect: .prepareSetBankDefault)
    }
    
    func test_prepareSetBankDefault_shouldNotChangeStateOnActive_offDisabled_setBankDefaultStatus() {
        
        let (_, active) = contractedState(
            .active,
            bankDefault: .offDisabled,
            status: .setBankDefault
        )
        
        assert(active, .prepareSetBankDefault, reducedTo: active)
    }
    
    func test_prepareSetBankDefault_shouldNotDeliverEffectOnActive_offDisabled_setBankDefaultStatus() {
        
        let (_, active) = contractedState(
            .active,
            bankDefault: .offDisabled,
            status: .setBankDefault
        )
        
        assert(active, .prepareSetBankDefault, effect: nil)
    }
    
    func test_prepareSetBankDefault_shouldNotChangeStateOnActive_onDisabled_setBankDefaultStatus() {
        
        let (_, active) = contractedState(
            .active,
            bankDefault: .onDisabled,
            status: .setBankDefault
        )
        
        assert(active, .prepareSetBankDefault, reducedTo: active)
    }
    
    func test_prepareSetBankDefault_shouldNotDeliverEffectOnActive_onDisabled_setBankDefaultStatus() {
        
        let (_, active) = contractedState(
            .active,
            bankDefault: .onDisabled,
            status: .setBankDefault
        )
        
        assert(active, .prepareSetBankDefault, effect: nil)
    }
    
    func test_prepareSetBankDefault_shouldNotChangeStateOnActive_offEnabled_nonSetBankDefaultStatus() {
        
        let (_, active) = contractedState(
            .active,
            bankDefault: .offEnabled,
            status: .inflight
        )
        
        assert(active, .prepareSetBankDefault, reducedTo: active)
    }
    
    func test_prepareSetBankDefault_shouldNotDeliverEffectOnActive_offEnabled_nonSetBankDefaultStatus() {
        
        let (_, active) = contractedState(
            .active,
            bankDefault: .offEnabled,
            status: .inflight
        )
        
        assert(active, .prepareSetBankDefault, effect: nil)
    }
    
    func test_prepareSetBankDefault_shouldNotChangeStateOnActive_offEnabled_nilStatus() {
        
        let (_, active) = contractedState(
            .active,
            bankDefault: .offEnabled,
            status: nil
        )
        
        assert(active, .prepareSetBankDefault, reducedTo: active)
    }
    
    func test_prepareSetBankDefault_shouldNotDeliverEffectOnActive_offEnabled_nilStatus() {
        
        let (_, active) = contractedState(
            .active,
            bankDefault: .offEnabled,
            status: nil
        )
        
        assert(active, .prepareSetBankDefault, effect: nil)
    }
    
    func test_prepareSetBankDefault_shouldNotChangeStateOnActive_offDisabled() {
        
        let (_, active) = contractedState(.active, bankDefault: .offDisabled)
        
        assert(active, .prepareSetBankDefault, reducedTo: active)
    }
    
    func test_prepareSetBankDefault_shouldNotDeliverEffectOnActive_offDisabled() {
        
        let (_, active) = contractedState(.active, bankDefault: .offDisabled)
        
        assert(active, .prepareSetBankDefault, effect: nil)
    }
    
    func test_prepareSetBankDefault_shouldNotChangeStateOnActive_onDisabled() {
        
        let (_, active) = contractedState(.active, bankDefault: .onDisabled)
        
        assert(active, .prepareSetBankDefault, reducedTo: active)
    }
    
    func test_prepareSetBankDefault_shouldNotDeliverEffectOnActive_onDisabled() {
        
        let (_, active) = contractedState(.active, bankDefault: .onDisabled)
        
        assert(active, .prepareSetBankDefault, effect: nil)
    }
    
    func test_prepareSetBankDefault_shouldNotChangeStateOnInactive() {
        
        let (_, inactive) = contractedState(.inactive)
        
        assert(inactive, .prepareSetBankDefault, reducedTo: inactive)
    }
    
    func test_prepareSetBankDefault_shouldNotDeliverEffectOnInactive() {
        
        let (_, inactive) = contractedState(.inactive)
        
        assert(inactive, .prepareSetBankDefault, effect: nil)
    }
    
    func test_prepareSetBankDefault_shouldNotChangeStateOnMissing() {
        
        let missing = missingConsentSuccessFPSState()
        
        assert(missing, .prepareSetBankDefault, reducedTo: missing)
    }
    
    func test_prepareSetBankDefault_shouldNotDeliverEffectOnMissing() {
        
        let missing = missingConsentSuccessFPSState()
        
        assert(missing, .prepareSetBankDefault, effect: nil)
    }
    
    func test_prepareSetBankDefault_shouldNotChangeStateOnConnectivityError() {
        
        let serverError = serverErrorFPSState()
        
        assert(serverError, .prepareSetBankDefault, reducedTo: serverError)
    }
    
    func test_prepareSetBankDefault_shouldNotDeliverEffectOnConnectivityError() {
        
        let serverError = serverErrorFPSState()
        
        assert(serverError, .prepareSetBankDefault, effect: nil)
    }
    
    func test_prepareSetBankDefault_shouldNotChangeStateOnServerError() {
        
        let serverError = serverErrorFPSState()
        
        assert(serverError, .prepareSetBankDefault, reducedTo: serverError)
    }
    
    func test_prepareSetBankDefault_shouldNotDeliverEffectOnServerError() {
        
        let serverError = serverErrorFPSState()
        
        assert(serverError, .prepareSetBankDefault, effect: nil)
    }
    
    // MARK: - resetStatus
    
    func test_resetStatus_shouldNotChangeEmptyState() {
        
        let empty = fastPaymentsSettingsState()
        
        assert(empty, .resetStatus, reducedTo: empty)
    }
    
    func test_resetStatus_shouldNotDeliverEffectOnEmptyState() {
        
        let empty = fastPaymentsSettingsState()
        
        assert(empty, .resetStatus, effect: nil)
    }
    
    func test_resetStatus_shouldSetStateToEmptyOnNonNilStatusWithNilSettings() {
        
        let withStatus = fastPaymentsSettingsState(
            status: .confirmSetBankDefault
        )
        let empty = fastPaymentsSettingsState()
        
        assert(withStatus, .resetStatus, reducedTo: empty)
    }
    
    func test_resetStatus_shouldNotDeliverEffectOnOnNonNilStatusWithNilSettings() {
        
        let withStatus = fastPaymentsSettingsState(
            status: .confirmSetBankDefault
        )
        
        assert(withStatus, .resetStatus, effect: nil)
    }
    
    func test_resetStatus_shouldNotChangeStateOnActiveWithoutStatus() {
        
        let (_, activeWithoutStatus) = contractedState(
            .active,
            status: nil
        )
        
        assert(activeWithoutStatus, .resetStatus, reducedTo: activeWithoutStatus)
    }
    
    func test_resetStatus_shouldNotDeliverEffectOnActiveWithoutStatus() {
        
        let (_, activeWithoutStatus) = contractedState(
            .active,
            status: nil
        )
        
        assert(activeWithoutStatus, .resetStatus, effect: nil)
    }
    
    func test_resetStatus_shouldResetStatusOnActiveWithStatus() {
        
        let (details, activeWithStatus) = contractedState(
            .active,
            status: .confirmSetBankDefault
        )
        
        assert(activeWithStatus, .resetStatus, reducedTo: .init(
            userPaymentSettings: .contracted(details),
            status: nil
        ))
    }
    
    func test_resetStatus_shouldNotDeliverEffectOnActiveWithStatus() {
        
        let (_, activeWithStatus) = contractedState(
            .active,
            status: .confirmSetBankDefault
        )
        
        assert(activeWithStatus, .resetStatus, effect: nil)
    }
    
    func test_resetStatus_shouldNotChangeStateOnInactiveWithoutStatus() {
        
        let (_, inactiveWithoutStatus) = contractedState(
            .active,
            status: nil
        )
        
        assert(inactiveWithoutStatus, .resetStatus, reducedTo: inactiveWithoutStatus)
    }
    
    func test_resetStatus_shouldNotDeliverEffectOnInactiveWithoutStatus() {
        
        let (_, inactiveWithoutStatus) = contractedState(
            .active,
            status: nil
        )
        
        assert(inactiveWithoutStatus, .resetStatus, effect: nil)
    }
    
    func test_resetStatus_shouldResetStatusOnInactiveWithStatus() {
        
        let (details, inactiveWithStatus) = contractedState(
            .active,
            status: .confirmSetBankDefault
        )
        
        assert(inactiveWithStatus, .resetStatus, reducedTo: .init(
            userPaymentSettings: .contracted(details),
            status: nil
        ))
    }
    
    func test_resetStatus_shouldNotDeliverEffectOnInactiveWithStatus() {
        
        let (_, inactiveWithStatus) = contractedState(
            .active,
            status: .confirmSetBankDefault
        )
        
        assert(inactiveWithStatus, .resetStatus, effect: nil)
    }
    
    func test_resetStatus_shouldNotChangeStateOnMissingWithoutStatus() {
        
        let missingWithoutStatus = missingConsentSuccessFPSState(status: nil)
        
        assert(missingWithoutStatus, .resetStatus, reducedTo: missingWithoutStatus)
    }
    
    func test_resetStatus_shouldNotDeliverEffectOnMissingWithoutStatus() {
        
        let missingWithoutStatus = missingConsentSuccessFPSState(status: nil)
        
        assert(missingWithoutStatus, .resetStatus, effect: nil)
    }
    
    func test_resetStatus_shouldResetStatusOnMissingWithStatus() {
        
        let settings = missingConsentSuccessSettings()
        let missingWithStatus = fastPaymentsSettingsState(
            settings,
            status: .confirmSetBankDefault
        )
        
        assert(missingWithStatus, .resetStatus, reducedTo: .init(
            userPaymentSettings: settings,
            status: nil
        ))
    }
    
    func test_resetStatus_shouldNotDeliverEffectOnMissingWithStatus() {
        
        let missingWithStatus = missingConsentSuccessFPSState(status: .confirmSetBankDefault)
        
        assert(missingWithStatus, .resetStatus, effect: nil)
    }
    
    func test_resetStatus_shouldNotChangeStateOnConnectivityErrorWithoutStatus() {
        
        let (_, withoutStatus) = connectivityError(status: nil)
        
        assert(withoutStatus, .resetStatus, reducedTo: withoutStatus)
    }
    
    func test_resetStatus_shouldNotDeliverEffectOnConnectivityErrorWithoutStatus() {
        
        let (_, withoutStatus) = connectivityError(status: nil)
        
        assert(withoutStatus, .resetStatus, effect: nil)
    }
    
    func test_resetStatus_shouldResetStatusOnConnectivityErrorWithStatus() {
        
        let (settings, withStatus) = connectivityError(status: .confirmSetBankDefault)
        
        assert(withStatus, .resetStatus, reducedTo: .init(
            userPaymentSettings: settings,
            status: nil
        ))
    }
    
    func test_resetStatus_shouldNotDeliverEffectOnConnectivityErrorWithStatus() {
        
        let (_, withStatus) = connectivityError(status: .confirmSetBankDefault)
        
        assert(withStatus, .resetStatus, effect: nil)
    }
    
    func test_resetStatus_shouldNotChangeStateOnServerErrorWithoutStatus() {
        
        let (_, withoutStatus) = serverError(status: nil)
        
        assert(withoutStatus, .resetStatus, reducedTo: withoutStatus)
    }
    
    func test_resetStatus_shouldNotDeliverEffectOnServerErrorWithoutStatus() {
        
        let (_, withoutStatus) = serverError(status: nil)
        
        assert(withoutStatus, .resetStatus, effect: nil)
    }
    
    func test_resetStatus_shouldResetStatusOnServerErrorWithStatus() {
        
        let (settings, withStatus) = serverError(status: .confirmSetBankDefault)
        
        assert(withStatus, .resetStatus, reducedTo: .init(
            userPaymentSettings: settings,
            status: nil
        ))
    }
    
    func test_resetStatus_shouldNotDeliverEffectOnServerErrorWithStatus() {
        
        let (_, withStatus) = serverError(status: .confirmSetBankDefault)
        
        assert(withStatus, .resetStatus, effect: nil)
    }
    
    // MARK: - selectProduct
    
    func test_selectProduct_shouldSetStatusOnDifferentProductSelectionInActive_expanded() {
        
        let (selected, different) = (makeProduct(), makeProduct())
        let (details, active) = contractedState(.active, selector: .expanded)
        let sut = makeSUT(products: [selected, different])
        
        assert(sut: sut, active, .selectProduct(different), reducedTo: .init(
            userPaymentSettings: .contracted(details),
            status: .inflight
        ))
    }
    
    func test_selectProduct_shouldDeliverEffectOnDifferentProductSelectionInActive_expanded() {
        
        let (selected, different) = (makeProduct(), makeProduct())
        let (details, active) = contractedState(.active, selector: .expanded)
        let core = makeCore(details, different)
        let sut = makeSUT(products: [selected, different])
        
        assert(sut: sut, active, .selectProduct(different), effect: .updateProduct(core))
    }
    
    func test_selectProduct_shouldCollapseOnSameProductSelectionActive_expanded() {
        
        let (selected, product2) = (makeProduct(), makeProduct())
        let productSelector = makeProductSelector(
            selected: selected,
            products: [selected, product2]
        )
        let (details, active) = contractedState(
            .active,
            productSelector: productSelector
        )
        let sut = makeSUT(products: [selected, product2])
        
        assert(sut: sut, active, .selectProduct(selected), reducedTo: .init(
            userPaymentSettings: .contracted(details.updated(
                productSelector: details.productSelector.updated(
                    status: .collapsed
                )
            ))))
    }
    
    func test_selectProduct_shouldNotDeliverEffectOnSameProductSelectionActive_expanded() {
        
        let (selected, product2) = (makeProduct(), makeProduct())
        let productSelector = makeProductSelector(
            selected: selected,
            products: [selected, product2]
        )
        let (_, active) = contractedState(
            .active,
            productSelector: productSelector
        )
        let sut = makeSUT(products: [selected, product2])
        
        assert(sut: sut, active, .selectProduct(selected), effect: nil)
    }
    
    func test_selectProduct_shouldCollapseOnActive_expanded_emptyProducts() {
        
        let (details, active) = contractedState(.active, selector: .expanded)
        let sut = makeSUT(products: [])
        
        assert(sut: sut, active, .selectProduct(makeProduct()), reducedTo: .init(
            userPaymentSettings: .contracted(details.updated(
                productSelector: details.productSelector.updated(
                    status: .collapsed
                )
            )))
        )
    }
    
    func test_selectProduct_shouldNotDeliverEffectOnActive_expanded_emptyProducts() {
        
        let active = contractedState(.active, selector: .expanded).state
        let sut = makeSUT(products: [])
        
        assert(sut: sut, active, .selectProduct(makeProduct()), effect: nil)
    }
    
    func test_selectProduct_shouldNotChangeStateOnActive_collapsed() {
        
        let active = contractedState(.active, selector: .collapsed).state
        
        assert(active, .selectProduct(makeProduct()), reducedTo: active)
    }
    
    func test_selectProduct_shouldNotDeliverEffectOnActive_collapsed() {
        
        let active = contractedState(.active, selector: .collapsed).state
        
        assert(active, .selectProduct(makeProduct()), effect: nil)
    }
    
    func test_selectProduct_shouldNotChangeStateOnInactive() {
        
        let inactive = contractedState(.inactive).state
        
        assert(inactive, .selectProduct(makeProduct()), reducedTo: inactive)
    }
    
    func test_selectProduct_shouldNotDeliverEffectOnInactive() {
        
        let inactive = contractedState(.inactive).state
        
        assert(inactive, .selectProduct(makeProduct()), effect: nil)
    }
    
    func test_selectProduct_shouldNotChangeStateOnMissing() {
        
        let missing = missingConsentSuccessFPSState()
        
        assert(missing, .selectProduct(makeProduct()), reducedTo: missing)
    }
    
    func test_selectProduct_shouldNotDeliverEffectOnMissing() {
        
        let missing = missingConsentSuccessFPSState()
        
        assert(missing, .selectProduct(makeProduct()), effect: nil)
    }
    
    func test_selectProduct_shouldNotChangeStateOnConnectivityErrorFailure() {
        
        let connectivityError = connectivityErrorFPSState()
        
        assert(connectivityError, .selectProduct(makeProduct()), reducedTo: connectivityError)
    }
    
    func test_selectProduct_shouldNotDeliverEffectOnConnectivityErrorFailure() {
        
        let connectivityError = connectivityErrorFPSState()
        
        assert(connectivityError, .selectProduct(makeProduct()), effect: nil)
    }
    
    func test_selectProduct_shouldNotChangeStateOnServerErrorFailure() {
        
        let serverError = serverErrorFPSState()
        
        assert(serverError, .selectProduct(makeProduct()), reducedTo: serverError)
    }
    
    func test_selectProduct_shouldNotDeliverEffectOnServerErrorFailure() {
        
        let serverError = serverErrorFPSState()
        
        assert(serverError, .selectProduct(makeProduct()), effect: nil)
    }
    
    // MARK: - setBankDefault
    
    func test_setBankDefault_shouldSetStatusOnActive_offEnabled() {
        
        let (details, active) = contractedState(.active, bankDefault: .offEnabled)
        
        assert(active, .setBankDefault, reducedTo: .init(
            userPaymentSettings: .contracted(details),
            status: .setBankDefault
        ))
    }
    
    func test_setBankDefault_shouldNotDeliverEffectOnActive_offEnabled() {
        
        let (_, active) = contractedState(.active, bankDefault: .offEnabled)
        
        assert(active, .setBankDefault, effect: nil)
    }
    
    func test_setBankDefault_shouldNotChangeStateOnActive_offDisabled() {
        
        let (_, active) = contractedState(.active, bankDefault: .offDisabled)
        
        assert(active, .setBankDefault, reducedTo: active)
    }
    
    func test_setBankDefault_shouldNotDeliverEffectOnActive_offDisabled() {
        
        let (_, active) = contractedState(.active, bankDefault: .offDisabled)
        
        assert(active, .setBankDefault, effect: nil)
    }
    
    func test_setBankDefault_shouldNotChangeStateOnActive_onDisabled() {
        
        let (_, active) = contractedState(.active, bankDefault: .onDisabled)
        
        assert(active, .setBankDefault, reducedTo: active)
    }
    
    func test_setBankDefault_shouldNotDeliverEffectOnActive_onDisabled() {
        
        let (_, active) = contractedState(.active, bankDefault: .onDisabled)
        
        assert(active, .setBankDefault, effect: nil)
    }
    
    func test_setBankDefault_shouldNotChangeStateOnInactive() {
        
        let (_, inactive) = contractedState(.inactive)
        
        assert(inactive, .setBankDefault, reducedTo: inactive)
    }
    
    func test_setBankDefault_shouldNotDeliverEffectOnInactive() {
        
        let (_, inactive) = contractedState(.inactive)
        
        assert(inactive, .setBankDefault, effect: nil)
    }
    
    func test_setBankDefault_shouldNotChangeStateOnMissing() {
        
        let missing = missingConsentSuccessFPSState()
        
        assert(missing, .setBankDefault, reducedTo: missing)
    }
    
    func test_setBankDefault_shouldNotDeliverEffectOnMissing() {
        
        let missing = missingConsentSuccessFPSState()
        
        assert(missing, .setBankDefault, effect: nil)
    }
    
    func test_setBankDefault_shouldNotChangeStateOnConnectivityError() {
        
        let serverError = serverErrorFPSState()
        
        assert(serverError, .setBankDefault, reducedTo: serverError)
    }
    
    func test_setBankDefault_shouldNotDeliverEffectOnConnectivityError() {
        
        let serverError = serverErrorFPSState()
        
        assert(serverError, .setBankDefault, effect: nil)
    }
    
    func test_setBankDefault_shouldNotChangeStateOnServerError() {
        
        let serverError = serverErrorFPSState()
        
        assert(serverError, .setBankDefault, reducedTo: serverError)
    }
    
    func test_setBankDefault_shouldNotDeliverEffectOnServerError() {
        
        let serverError = serverErrorFPSState()
        
        assert(serverError, .setBankDefault, effect: nil)
    }
    
    // MARK: - setBankDefaultPrepared
    
    func test_setBankDefaultPrepared_shouldSetBankDefaultAndInformerOnSuccess_active() {
        
        let (details, active) = contractedState(.active)
        
        assert(
            active,
            .setBankDefaultPrepared(nil),
            reducedTo: .init(
                userPaymentSettings: .contracted(details.updated(
                    bankDefault: .onDisabled
                )),
                status: .setBankDefaultSuccess
            )
        )
    }
    
    func test_setBankDefaultPrepared_shouldNotDeliverEffectOnSuccess_active() {
        
        let active = contractedState(.active).state
        
        assert(active, .setBankDefaultPrepared(nil), effect: nil)
    }
    
    func test_setBankDefaultPrepared_shouldSetStatusOnConnectivityErrorFailure_active() {
        
        let active = activeContractSettings()
        
        assert(
            active,
            .setBankDefaultPrepared(.connectivityError),
            reducedTo: .init(
                userPaymentSettings: active,
                status: .connectivityError
            )
        )
    }
    
    func test_setBankDefaultPrepared_shouldNotDeliverEffectOnConnectivityErrorFailure_active() {
        
        let active = activeContractSettings()
        
        assert(active, .setBankDefaultPrepared(.connectivityError), effect: nil)
    }
    
    func test_setBankDefaultPrepared_shouldSetStatusOnServerErrorFailure_active() {
        
        let message = anyMessage()
        let active = activeContractSettings()
        
        assert(
            active,
            .setBankDefaultPrepared(.serverError(message)),
            reducedTo: .init(
                userPaymentSettings: active,
                status: .serverError(message)
            )
        )
    }
    
    func test_setBankDefaultPrepared_shouldNotDeliverEffectOnServerErrorFailure_active() {
        
        let active = activeContractSettings()
        
        assert(active, setBankDefaultPreparedServerError(), effect: nil)
    }
    
    func test_setBankDefaultPrepared_shouldNotChangeStateOnSuccess_inactive() {
        
        let inactive = contractedState(.inactive).state
        
        assert(inactive, .setBankDefaultPrepared(nil), reducedTo: inactive)
    }
    
    func test_setBankDefaultPrepared_shouldNotDeliverEffectOnSuccess_inactive() {
        
        let inactive = contractedState(.inactive).state
        
        assert(inactive, .setBankDefaultPrepared(nil), effect: nil)
    }
    
    func test_setBankDefaultPrepared_shouldNotChangeStateOnConnectivityErrorFailure_inactive() {
        
        let inactive = contractedState(.inactive).state
        
        assert(inactive, .setBankDefaultPrepared(.connectivityError), reducedTo: inactive)
    }
    
    func test_setBankDefaultPrepared_shouldNotDeliverEffectOnConnectivityErrorFailure_inactive() {
        
        let inactive = contractedState(.inactive).state
        
        assert(inactive, .setBankDefaultPrepared(.connectivityError), effect: nil)
    }
    
    func test_setBankDefaultPrepared_shouldNotChangeStateOnServerErrorFailure_inactive() {
        
        let inactive = contractedState(.inactive).state
        
        assert(inactive, setBankDefaultPreparedServerError(), reducedTo: inactive)
    }
    
    func test_setBankDefaultPrepared_shouldNotDeliverEffectOnServerErrorFailure_inactive() {
        
        let inactive = contractedState(.inactive).state
        
        assert(inactive, setBankDefaultPreparedServerError(), effect: nil)
    }
    
    func test_setBankDefaultPrepared_shouldNotChangeStateOnSuccess_missing() {
        
        let missing = missingConsentSuccessFPSState()
        
        assert(missing, .setBankDefaultPrepared(nil), reducedTo: missing)
    }
    
    func test_setBankDefaultPrepared_shouldNotDeliverEffectOnSuccess_missing() {
        
        let missing = missingConsentSuccessFPSState()
        
        assert(missing, .setBankDefaultPrepared(nil), effect: nil)
    }
    
    func test_setBankDefaultPrepared_shouldNotChangeStateOnConnectivityErrorFailure_missing() {
        
        let missing = missingConsentSuccessFPSState()
        
        assert(missing, .setBankDefaultPrepared(.connectivityError), reducedTo: missing)
    }
    
    func test_setBankDefaultPrepared_shouldNotDeliverEffectOnConnectivityErrorFailure_missing() {
        
        let missing = missingConsentSuccessFPSState()
        
        assert(missing, .setBankDefaultPrepared(.connectivityError), effect: nil)
    }
    
    func test_setBankDefaultPrepared_shouldNotChangeStateOnServerErrorFailure_missing() {
        
        let missing = missingConsentSuccessFPSState()
        
        assert(missing, setBankDefaultPreparedServerError(), reducedTo: missing)
    }
    
    func test_setBankDefaultPrepared_shouldNotDeliverEffectOnServerErrorFailure_missing() {
        
        let missing = missingConsentSuccessFPSState()
        
        assert(missing, setBankDefaultPreparedServerError(), effect: nil)
    }
    
    func test_setBankDefaultPrepared_shouldNotChangeStateOnSuccess_connectivityError() {
        
        let connectivityError = connectivityErrorFPSState()
        
        assert(connectivityError, .setBankDefaultPrepared(nil), reducedTo: connectivityError)
    }
    
    func test_setBankDefaultPrepared_shouldNotDeliverEffectOnSuccess_connectivityError() {
        
        let connectivityError = connectivityErrorFPSState()
        
        assert(connectivityError, .setBankDefaultPrepared(nil), effect: nil)
    }
    
    func test_setBankDefaultPrepared_shouldNotChangeStateOnConnectivityErrorFailure_connectivityError() {
        
        let connectivityError = connectivityErrorFPSState()
        
        assert(connectivityError, .setBankDefaultPrepared(.connectivityError), reducedTo: connectivityError)
    }
    
    func test_setBankDefaultPrepared_shouldNotDeliverEffectOnConnectivityErrorFailure_connectivityError() {
        
        let connectivityError = connectivityErrorFPSState()
        
        assert(connectivityError, .setBankDefaultPrepared(.connectivityError), effect: nil)
    }
    
    func test_setBankDefaultPrepared_shouldNotChangeStateOnServerErrorFailure_connectivityError() {
        
        let connectivityError = connectivityErrorFPSState()
        
        assert(connectivityError, setBankDefaultPreparedServerError(), reducedTo: connectivityError)
    }
    
    func test_setBankDefaultPrepared_shouldNotDeliverEffectOnServerErrorFailure_connectivityError() {
        
        let connectivityError = connectivityErrorFPSState()
        
        assert(connectivityError, setBankDefaultPreparedServerError(), effect: nil)
    }
    
    func test_setBankDefaultPrepared_shouldNotChangeStateOnSuccess_serverError() {
        
        let serverError = serverErrorFPSState()
        
        assert(serverError, .setBankDefaultPrepared(nil), reducedTo: serverError)
    }
    
    func test_setBankDefaultPrepared_shouldNotDeliverEffectOnSuccess_serverError() {
        
        let serverError = serverErrorFPSState()
        
        assert(serverError, .setBankDefaultPrepared(nil), effect: nil)
    }
    
    func test_setBankDefaultPrepared_shouldNotChangeStateOnConnectivityErrorFailure_serverError() {
        
        let serverError = serverErrorFPSState()
        
        assert(serverError, .setBankDefaultPrepared(.connectivityError), reducedTo: serverError)
    }
    
    func test_setBankDefaultPrepared_shouldNotDeliverEffectOnConnectivityErrorFailure_serverError() {
        
        let serverError = serverErrorFPSState()
        
        assert(serverError, .setBankDefaultPrepared(.connectivityError), effect: nil)
    }
    
    func test_setBankDefaultPrepared_shouldNotChangeStateOnServerErrorFailure_serverError() {
        
        let serverError = serverErrorFPSState()
        
        assert(serverError, setBankDefaultPreparedServerError(), reducedTo: serverError)
    }
    
    func test_setBankDefaultPrepared_shouldNotDeliverEffectOnServerErrorFailure_serverError() {
        
        let serverError = serverErrorFPSState()
        
        assert(serverError, setBankDefaultPreparedServerError(), effect: nil)
    }
    
    // MARK: - updateContract
    
    func test_updateContract_shouldSetContractOnSuccess_active() {
        
        let (details, activeContract) = contractedState(.active)
        let newContract = paymentContract()
        
        assert(
            activeContract,
            updateContractSuccess(newContract),
            reducedTo: .init(
                userPaymentSettings: .contracted(details.updated(
                    paymentContract: newContract
                ))
            )
        )
    }
    
    func test_updateContract_shouldNotDeliverEffectOnSuccess_active() {
        
        let active = contractedState(.active).state
        
        assert(active, updateContractSuccess(), effect: nil)
    }
    
    func test_updateContract_shouldSetStatusToConnectivityErrorOnConnectivityFailure_active() {
        
        let (details, active) = contractedState(.active)
        let event = updateContractConnectivityError()
        
        assert(
            active,
            event,
            reducedTo: .init(
                userPaymentSettings: .contracted(details),
                status: .connectivityError
            )
        )
    }
    
    func test_updateContract_shouldNotDeliverEffectOnConnectivityFailure_active() {
        
        let active = contractedState(.active).state
        
        assert(active, updateContractConnectivityError(), effect: nil)
    }
    
    func test_updateContract_shouldSetStatusToServerErrorOnServerErrorFailure_active() {
        
        let message = anyMessage()
        let (details, active) = contractedState(.active)
        
        assert(
            active,
            updateContractServerError(message),
            reducedTo: .init(
                userPaymentSettings: .contracted(details),
                status: .serverError(message)
            )
        )
    }
    
    func test_updateContract_shouldNotDeliverEffectOnServerErrorFailure_active() {
        
        let active = contractedState(.active).state
        
        assert(active, updateContractServerError(), effect: nil)
    }
    
    func test_updateContract_shouldSetContractOnSuccess_inactive() {
        
        let (details, inactive) = contractedState(.inactive)
        let newContract = paymentContract()
        
        assert(
            inactive,
            updateContractSuccess(newContract),
            reducedTo: .init(
                userPaymentSettings: .contracted(details.updated(
                    paymentContract: newContract
                ))
            )
        )
    }
    
    func test_updateContract_shouldNotDeliverEffectOnSuccess_inactive() {
        
        let inactive = contractedState(.inactive).state
        
        assert(inactive, updateContractSuccess(), effect: nil)
    }
    
    func test_updateContract_shouldSetStatusToConnectivityErrorOnConnectivityFailure_inactive() {
        
        let (details, inactive) = contractedState(.inactive)
        
        assert(
            inactive,
            updateContractConnectivityError(),
            reducedTo: .init(
                userPaymentSettings: .contracted(details),
                status: .connectivityError
            )
        )
    }
    
    func test_updateContract_shouldNotDeliverEffectOnConnectivityFailure_inactive() {
        
        let inactive = contractedState(.inactive).state
        
        assert(inactive, updateContractConnectivityError(), effect: nil)
    }
    
    func test_updateContract_shouldSetStatusToServerErrorOnServerErrorFailure_inactive() {
        
        let message = anyMessage()
        let (details, inactive) = contractedState(.inactive)
        
        assert(
            inactive,
            updateContractServerError(message),
            reducedTo: .init(
                userPaymentSettings: .contracted(details),
                status: .serverError(message)
            )
        )
    }
    
    func test_updateContract_shouldNotDeliverEffectOnServerErrorFailure_inactive() {
        
        let inactive = contractedState(.inactive).state
        
        assert(inactive, updateContractServerError(), effect: nil)
    }
    
    func test_updateContract_shouldSetContractOnSuccess_missing() {
        
        let consentResult = consentResultFailure()
        let missing = missingContract(consentResult)
        let (product1, selected) = (makeProduct(), makeProduct())
        let newContract = paymentContract(productID: selected.id)
        let sut = makeSUT(products: [product1, selected])
        
        assert(
            sut: sut,
            missing,
            updateContractSuccess(newContract),
            reducedTo: .init(
                userPaymentSettings: .contracted(.init(
                    paymentContract: newContract,
                    consentResult: consentResult,
                    bankDefault: .offEnabled,
                    productSelector: .init(
                        selectedProduct: selected,
                        products: [product1, selected]
                    )
                ))
            )
        )
    }
    
    func test_updateContract_shouldSetContractAndSelectorWithoutSelectedProductOnSuccessAndMissingProduct_missing() {
        
        let consentResult = consentResultFailure()
        let missing = missingContract(consentResult)
        let (product1, missingProduct) = (makeProduct(), makeProduct())
        let newContract = paymentContract(productID: missingProduct.id)
        let sut = makeSUT(products: [product1])
        
        assert(
            sut: sut,
            missing,
            updateContractSuccess(newContract),
            reducedTo: .init(
                userPaymentSettings: .contracted(.init(
                    paymentContract: newContract,
                    consentResult: consentResult,
                    bankDefault: .offEnabled,
                    productSelector: .init(
                        selectedProduct: nil,
                        products: [product1]
                    )
                ))
            )
        )
    }
    
    func test_updateContract_shouldNotDeliverEffectOnSuccess_missing() {
        
        let missing = missingConsentSuccessSettings()
        
        assert(missing, updateContractSuccess(), effect: nil)
    }
    
    func test_updateContract_shouldSetStatusToConnectivityErrorOnConnectivityFailure_missing() {
        
        let missing = missingConsentFailureSettings()
        let product = makeProduct()
        let sut = makeSUT(products: [product])
        let event = updateContractConnectivityError()
        
        assert(
            sut: sut, missing, event,
            reducedTo: .init(
                userPaymentSettings: missing,
                status: .connectivityError
            )
        )
    }
    
    func test_updateContract_shouldNotDeliverEffectOnConnectivityFailure_missing() {
        
        let missing = missingConsentSuccessSettings()
        
        assert(missing, updateContractConnectivityError(), effect: nil)
    }
    
    func test_updateContract_shouldSetStatusToServerErrorOnServerErrorFailure_missing() {
        
        let message = anyMessage()
        let missing = missingConsentFailureSettings()
        let product = makeProduct()
        let sut = makeSUT(products: [product])
        let event = updateContractServerError(message)
        
        assert(
            sut: sut, missing, event,
            reducedTo: .init(
                userPaymentSettings: missing,
                status: .serverError(message)
            )
        )
    }
    
    func test_updateContract_shouldNotDeliverEffectOnServerErrorFailure_missing() {
        
        let missing = missingConsentSuccessSettings()
        
        assert(missing, updateContractServerError(), effect: nil)
    }
    
    func test_updateContract_shouldNotChangeStateOnSuccess_connectivityError() {
        
        let connectivityError = connectivityErrorFPSState()
        
        assert(connectivityError, updateContractSuccess(), reducedTo: connectivityError)
    }
    
    func test_updateContract_shouldNotDeliverEffectOnSuccess_connectivityError() {
        
        let connectivityError = connectivityErrorFPSState()
        
        assert(connectivityError, updateContractSuccess(), effect: nil)
    }
    
    func test_updateContract_shouldNotChangeStateOnConnectivityFailure_connectivityError() {
        
        let connectivityError = connectivityErrorFPSState()
        
        assert(connectivityError, updateContractConnectivityError(), reducedTo: connectivityError)
    }
    
    func test_updateContract_shouldNotDeliverEffectOnConnectivityFailure_connectivityError() {
        
        let connectivityError = connectivityErrorFPSState()
        
        assert(connectivityError, updateContractConnectivityError(), effect: nil)
    }
    
    func test_updateContract_shouldNotChangeStateOnServerErrorFailure_connectivityError() {
        
        let connectivityError = connectivityErrorFPSState()
        
        assert(connectivityError, updateContractServerError(), reducedTo: connectivityError)
    }
    
    func test_updateContract_shouldNotDeliverEffectOnServerErrorFailure_connectivityError() {
        
        let connectivityError = connectivityErrorFPSState()
        
        assert(connectivityError, updateContractServerError(), effect: nil)
    }
    
    func test_updateContract_shouldNotChangeStateOnSuccess_serverError() {
        
        let serverError = serverErrorFPSState()
        
        assert(serverError, updateContractSuccess(), reducedTo: serverError)
    }
    
    func test_updateContract_shouldNotDeliverEffectOnSuccess_serverError() {
        
        let serverError = serverErrorFPSState()
        
        assert(serverError, updateContractSuccess(), effect: nil)
    }
    
    func test_updateContract_shouldNotChangeStateOnConnectivityFailure_serverError() {
        
        let serverError = serverErrorFPSState()
        
        assert(serverError, updateContractConnectivityError(), reducedTo: serverError)
    }
    
    func test_updateContract_shouldNotDeliverEffectOnConnectivityFailure_serverError() {
        
        let serverError = serverErrorFPSState()
        
        assert(serverError, updateContractConnectivityError(), effect: nil)
    }
    
    func test_updateContract_shouldNotChangeStateOnServerErrorFailure_serverError() {
        
        let serverError = serverErrorFPSState()
        
        assert(serverError, updateContractServerError(), reducedTo: serverError)
    }
    
    func test_updateContract_shouldNotDeliverEffectOnServerErrorFailure_serverError() {
        
        let serverError = serverErrorFPSState()
        
        assert(serverError, updateContractServerError(), effect: nil)
    }
    
    // MARK: - updateProduct
    
    func test_updateProduct_shouldSetProductOnSuccess_active() {
        
        let newProduct = makeProduct()
        let (details, active) = contractedState(.active)
        
        assert(
            active,
            .updateProduct(.success(newProduct)),
            reducedTo: .init(
                userPaymentSettings: .contracted(details.updated(
                    productSelector: details.productSelector.selected(product: newProduct)
                ))
            )
        )
    }
    
    func test_updateProduct_shouldNotDeliverEffectOnSuccess_active() {
        
        let active = contractedState(.active).state
        
        assert(active, updateProductSuccess(), effect: nil)
    }
    
    func test_updateProduct_shouldSetStatusOnConnectivityErrorFailure_active() {
        
        let active = activeContractSettings()
        
        assert(
            active,
            updateProductConnectivityError(),
            reducedTo: .init(
                userPaymentSettings: active,
                status: .connectivityError
            )
        )
    }
    
    func test_updateProduct_shouldNotDeliverEffectOnConnectivityErrorFailure_active() {
        
        let active = contractedState(.active).state
        
        assert(active, updateProductConnectivityError(), effect: nil)
    }
    
    func test_updateProduct_shouldSetStatusOnServerErrorFailure_active() {
        
        let message = anyMessage()
        let active = activeContractSettings()
        
        assert(
            active,
            .updateProduct(.failure(.serverError(message))),
            reducedTo: .init(
                userPaymentSettings: active,
                status: .serverError(message)
            )
        )
    }
    
    func test_updateProduct_shouldNotDeliverEffectOnServerErrorFailure_active() {
        
        let active = contractedState(.active).state
        
        assert(active, updateProductServerError(), effect: nil)
    }
    
    func test_updateProduct_shouldNotChangeStateOnSuccess_inactive() {
        
        let inactive = contractedState(.inactive).state
        
        assert(inactive, updateProductSuccess(), reducedTo: inactive)
    }
    
    func test_updateProduct_shouldNotDeliverEffectOnSuccess_inactive() {
        
        let inactive = contractedState(.inactive).state
        
        assert(inactive, updateProductSuccess(), effect: nil)
    }
    
    func test_updateProduct_shouldNotChangeStateOnConnectivityErrorFailure_inactive() {
        
        let inactive = contractedState(.inactive).state
        
        assert(inactive, updateProductConnectivityError(), reducedTo: inactive)
    }
    
    func test_updateProduct_shouldNotDeliverEffectOnConnectivityErrorFailure_inactive() {
        
        let inactive = contractedState(.inactive).state
        
        assert(inactive, updateProductConnectivityError(), effect: nil)
    }
    
    func test_updateProduct_shouldNotChangeStateOnServerErrorFailure_inactive() {
        
        let inactive = contractedState(.inactive).state
        
        assert(inactive, updateProductServerError(), reducedTo: inactive)
    }
    
    func test_updateProduct_shouldNotDeliverEffectOnServerErrorFailure_inactive() {
        
        let inactive = contractedState(.inactive).state
        
        assert(inactive, updateProductServerError(), effect: nil)
    }
    
    func test_productUpdate_shouldNotChangeStateOnSuccess_missing() {
        
        let missing = missingConsentSuccessFPSState()
        
        assert(missing, updateProductSuccess(), reducedTo: missing)
    }
    
    func test_productUpdate_shouldNotDeliverEffectOnSuccess_missing() {
        
        let missing = missingConsentSuccessFPSState()
        
        assert(missing, updateProductSuccess(), effect: nil)
    }
    
    func test_productUpdate_shouldNotChangeStateOnConnectivityErrorFailure_missing() {
        
        let missing = missingConsentSuccessFPSState()
        
        assert(missing, updateProductConnectivityError(), reducedTo: missing)
    }
    
    func test_productUpdate_shouldNotDeliverEffectOnConnectivityErrorFailure_missing() {
        
        let missing = missingConsentSuccessFPSState()
        
        assert(missing, updateProductConnectivityError(), effect: nil)
    }
    
    func test_updateProduct_shouldNotChangeStateOnServerErrorFailure_missing() {
        
        let missing = missingConsentSuccessFPSState()
        
        assert(missing, updateProductServerError(), reducedTo: missing)
    }
    
    func test_updateProduct_shouldNotDeliverEffectOnServerErrorFailure_missing() {
        
        let missing = missingConsentSuccessFPSState()
        
        assert(missing, updateProductServerError(), effect: nil)
    }
    
    func test_updateProduct_shouldNotChangeStateOnSuccess_connectivityError() {
        
        let connectivityError = connectivityErrorFPSState()
        
        assert(connectivityError, updateProductSuccess(), reducedTo: connectivityError)
    }
    
    func test_updateProduct_shouldNotDeliverEffectOnSuccess_connectivityError() {
        
        let connectivityError = connectivityErrorFPSState()
        
        assert(connectivityError, updateProductSuccess(), effect: nil)
    }
    
    func test_updateProduct_shouldNotChangeStateOnConnectivityErrorFailure_connectivityError() {
        
        let connectivityError = connectivityErrorFPSState()
        
        assert(connectivityError, updateProductConnectivityError(), reducedTo: connectivityError)
    }
    
    func test_updateProduct_shouldNotDeliverEffectOnConnectivityErrorFailure_connectivityError() {
        
        let connectivityError = connectivityErrorFPSState()
        
        assert(connectivityError, updateProductConnectivityError(), effect: nil)
    }
    
    func test_updateProduct_shouldNotChangeStateOnServerErrorFailure_connectivityError() {
        
        let connectivityError = connectivityErrorFPSState()
        
        assert(connectivityError, updateProductServerError(), reducedTo: connectivityError)
    }
    
    func test_updateProduct_shouldNotDeliverEffectOnServerErrorFailure_connectivityError() {
        
        let connectivityError = connectivityErrorFPSState()
        
        assert(connectivityError, updateProductServerError(), effect: nil)
    }
    
    func test_updateProduct_shouldNotChangeStateOnSuccess_serverError() {
        
        let serverError = serverErrorFPSState()
        
        assert(serverError, updateProductSuccess(), reducedTo: serverError)
    }
    
    func test_updateProduct_shouldNotDeliverEffectOnSuccess_serverError() {
        
        let serverError = serverErrorFPSState()
        
        assert(serverError, updateProductSuccess(), effect: nil)
    }
    
    func test_updateProduct_shouldNotChangeStateOnConnectivityErrorFailure_serverError() {
        
        let serverError = serverErrorFPSState()
        
        assert(serverError, updateProductConnectivityError(), reducedTo: serverError)
    }
    
    func test_updateProduct_shouldNotDeliverEffectOnConnectivityErrorFailure_serverError() {
        
        let serverError = serverErrorFPSState()
        
        assert(serverError, updateProductConnectivityError(), effect: nil)
    }
    
    func test_updateProduct_shouldNotChangeStateOnServerErrorFailure_serverError() {
        
        let serverError = serverErrorFPSState()
        
        assert(serverError, updateProductServerError(), reducedTo: serverError)
    }
    
    func test_updateProduct_shouldNotDeliverEffectOnServerErrorFailure_serverError() {
        
        let serverError = serverErrorFPSState()
        
        assert(serverError, updateProductServerError(), effect: nil)
    }
    
    // MARK: - Helpers
    
    private typealias SUT = FastPaymentsSettingsRxReducer
    private typealias State = SUT.State
    private typealias Event = SUT.Event
    private typealias Effect = SUT.Effect
    
    private func makeSUT(
        products: [Product] = [makeProduct()],
        file: StaticString = #file,
        line: UInt = #line
    ) -> SUT {
        
        let sut = SUT(getProducts: { products })
        
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
    ) -> FastPaymentsSettingsEffect.TargetContract? {
        
        guard let core = core(contractDetails)
        else { return nil }
        
        return .init(
            core: core,
            targetStatus: targetStatus
        )
    }
    
    private func core(
        _ contractDetails: UserPaymentSettings.ContractDetails
    ) -> FastPaymentsSettingsEffect.ContractCore? {
        
        guard let product = contractDetails.productSelector.selectedProduct
        else { return nil }
        
        return .init(
            contractID: .init(contractDetails.paymentContract.id.rawValue),
            product: product
        )
    }
}

// MARK: - Helpers

extension UserPaymentSettings.ProductSelector {
    
    func selected(product: Product) -> Self {
        
        .init(selectedProduct: product, products: self.products)
    }
    
    func updated(
        selectedProduct: Product?? = nil,
        products: [Product]? = nil,
        status: Status? = nil
    ) -> Self {
        
        .init(
            selectedProduct: selectedProduct ?? self.selectedProduct,
            products: products ?? self.products,
            status: status ?? self.status
        )
    }
}
