//
//  FastPaymentsSettingsRxReducerTests.swift
//
//
//  Created by Igor Malyarov on 15.01.2024.
//

import FastPaymentsSettings
import RxViewModel
import XCTest

extension FastPaymentsSettingsReducer: Reducer {}

final class FastPaymentsSettingsRxReducerTests: XCTestCase {
    
    // MARK: - appear
    
    func test_appear_shouldSetStatusToInflight_emptyState() {
        
        let empty = fastPaymentsSettingsState()
        
        assert(.appear, on: empty) { $0.status = .inflight }
    }
    
    func test_appear_shouldDeliverGetUserPaymentSettingsEffect_emptyState() {
        
        let empty = fastPaymentsSettingsState()
        
        assert(.appear, on: empty, effect: .getSettings)
    }
    
    func test_appear_shouldSetStatusToInflight_nonEmptyState() {
        
        let nonEmpty = contractedSettings()
        
        assert(.appear, on: nonEmpty) {
            $0.userPaymentSettings = nonEmpty
            $0.status = .inflight
        }
    }
    
    func test_appear_shouldDeliverGetUserPaymentSettingsEffect_nonEmptyState() {
        
        let nonEmpty = contractedSettings()
        
        assert(nonEmpty, .appear, effect: .getSettings)
    }
    
    // MARK: - activateContract
    
    func test_activateContract_shouldNotChangeStateOnEmpty() {
        
        let empty = fastPaymentsSettingsState()
        
        assert(.activateContract, on: empty)
    }
    
    func test_activateContract_shouldNotDeliverEffectOnEmpty() {
        
        let empty = fastPaymentsSettingsState()
        
        assert(.activateContract, on: empty, effect: nil)
    }
    
    func test_activateContract_shouldNotChangeStateOnActiveContract() {
        
        let active = contractedState(.active).state
        
        assert(.activateContract, on: active)
    }
    
    func test_activateContract_shouldNotDeliverEffectOnActiveContract() {
        
        let active = contractedState(.active).state
        
        assert(.activateContract, on: active, effect: nil)
    }
    
    func test_activateContract_shouldChangeStatusToInflightOnInactiveContract() {
        
        let inactive = inactiveContractSettings()
        
        assert(.activateContract, on: inactive) {
            $0.userPaymentSettings = inactive
            $0.status = .inflight
        }
    }
    
    func test_activateContract_shouldDeliverEffectOnInactiveContract() throws {
        
        let (details, inactive) = contractedState(.inactive)
#warning("add tests for branches")
        let target = try XCTUnwrap(target(details, .active))
        
        assert(.activateContract, on: inactive, effect: .activateContract(target))
    }
    
    func test_activateContract_shouldChangeStatusToMissingProductOnMissingProductAtMissingSettingsWithConsentFailure() {
        
        let missing = missingConsentFailureSettings()
        let sut = makeSUT(products: [])
        
        assert(sut: sut, .activateContract, on: missing) {
            $0.userPaymentSettings = missing
            $0.status = .missingProduct
        }
    }
    
    func test_activateContract_shouldNotDeliverEffectOnMissingProductAtMissingSettingsWithConsentFailure() {
        
        let missing = missingConsentFailureSettings()
        let sut = makeSUT(products: [])
        
        assert(sut: sut, missing, .activateContract, effect: nil)
    }
    
    func test_activateContract_shouldChangeStatusToInflightOnAvailableProductAtMissingSettingsWithConsentFailure() {
        
        let missing = missingConsentFailureSettings()
        let sut = makeSUT(products: [makeProduct()])
        
        assert(sut: sut, .activateContract, on: missing) {
            $0.userPaymentSettings = missing
            $0.status = .inflight
        }
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
        
        assert(sut: sut, .activateContract, on: missing) {
            $0.userPaymentSettings = missing
            $0.status = .missingProduct
        }
    }
    
    func test_activateContract_shouldNotDeliverEffectOnMissingProductAtMissingSettingsWithConsentSuccess() {
        
        let missing = missingConsentSuccessSettings()
        let sut = makeSUT(products: [])
        
        assert(sut: sut, missing, .activateContract, effect: nil)
    }
    
    func test_activateContract_shouldChangeStatusToInflightOnAvailableProductAtMissingSettingsWithConsentSuccess() {
        
        let missing = missingConsentSuccessSettings()
        let sut = makeSUT(products: [makeProduct()])
        
        assert(sut: sut, .activateContract, on: missing) {
            $0.userPaymentSettings = missing
            $0.status = .inflight
        }
    }
    
    func test_activateContract_shouldDeliverEffectOnAvailableProductAtMissingSettingsWithConsentSuccess() {
        
        let missing = missingConsentSuccessSettings()
        let product = makeProduct()
        let sut = makeSUT(products: [product])
        
        assert(sut: sut, missing, .activateContract, effect: .createContract(.init(product.id.rawValue)))
    }
    
    func test_activateContract_shouldNotChangeStateOnConnectivityErrorFailure() {
        
        let connectivityError = connectivityErrorFPSState()
        
        assert(.activateContract, on: connectivityError)
    }
    
    func test_activateContract_shouldNotDeliverEffectOnConnectivityErrorFailure() {
        
        let connectivityError = connectivityErrorFPSState()
        
        assert(.activateContract, on: connectivityError, effect: nil)
    }
    
    func test_activateContract_shouldNotChangeStateOnServerErrorFailure() {
        
        let serverError = serverErrorFPSState()
        
        assert(.activateContract, on: serverError)
    }
    
    func test_activateContract_shouldNotDeliverEffectOnServerErrorFailure() {
        
        let serverError = serverErrorFPSState()
        
        assert(.activateContract, on: serverError, effect: nil)
    }
    
    // MARK: - collapseProducts
    
    func test_collapseProducts_shouldCollapseExpandedStateOnActive_expanded() {
        
        let (details, active) = contractedState(.active, selector: .expanded)
        
        assert(collapseProducts(), on: active) {
            $0.userPaymentSettings = .contracted(details.updated(
                productSelector: details.productSelector.updated(
                    status: .collapsed
                )
            ))
        }
    }
    
    func test_collapseProducts_shouldNotChangeStateOnActive_collapsed() {
        
        let active = contractedState(.active, selector: .collapsed).state
        
        assert(collapseProducts(), on: active)
    }
    
    func test_collapseProducts_shouldNotDeliverEffectOnActive() {
        
        let active = contractedState(.active).state
        
        assert(collapseProducts(), on: active, effect: nil)
    }
    
    func test_collapseProducts_shouldNotChangeStateOnInactive() {
        
        let inactive = contractedState(.inactive).state
        
        assert(collapseProducts(), on: inactive)
    }
    
    func test_collapseProducts_shouldNotDeliverEffectOnInactive() {
        
        let inactive = contractedState(.inactive).state
        
        assert(collapseProducts(), on: inactive, effect: nil)
    }
    
    func test_collapseProducts_shouldNotChangeStateOnMissing() {
        
        let missing = missingConsentSuccessFPSState()
        
        assert(collapseProducts(), on: missing)
    }
    
    func test_collapseProducts_shouldNotDeliverEffectOnMissing() {
        
        let missing = missingConsentSuccessFPSState()
        
        assert(collapseProducts(), on: missing, effect: nil)
    }
    
    func test_collapseProducts_shouldNotChangeStateOnConnectivityErrorFailure() {
        
        let connectivityError = connectivityErrorFPSState()
        
        assert(collapseProducts(), on: connectivityError)
    }
    
    func test_collapseProducts_shouldNotDeliverEffectOnConnectivityErrorFailure() {
        
        let connectivityError = connectivityErrorFPSState()
        
        assert(collapseProducts(), on: connectivityError, effect: nil)
    }
    
    func test_collapseProducts_shouldNotChangeStateOnServerErrorFailure() {
        
        let serverError = serverErrorFPSState()
        
        assert(collapseProducts(), on: serverError)
    }
    
    func test_collapseProducts_shouldNotDeliverEffectOnServerErrorFailure() {
        
        let serverError = serverErrorFPSState()
        
        assert(collapseProducts(), on: serverError, effect: nil)
    }
    
    // MARK: - deactivateContract
    
    func test_deactivateContract_shouldChangeStatusToInflightOnActive() {
        
        let active = activeContractSettings()
        
        assert(.deactivateContract, on: active) {
            $0.userPaymentSettings = active
            $0.status = .inflight
        }
    }
    
    func test_deactivateContract_shouldDeliverEffectOnActive() throws{
        
        let (details, active) = contractedState(.active)
#warning("add tests for branches")
        let target = try XCTUnwrap(target(details, .inactive))
        
        assert(.deactivateContract, on: active, effect: .deactivateContract(target))
    }
    
    func test_deactivateContract_shouldNotChangeStateOnInactive() {
        
        let inactive = contractedState(.inactive).state
        
        assert(.deactivateContract, on: inactive)
    }
    
    func test_deactivateContract_shouldNotDeliverEffectOnInactive() {
        
        let inactive = contractedState(.inactive).state
        
        assert(.deactivateContract, on: inactive, effect: nil)
    }
    
    func test_deactivateContract_shouldNotChangeStateOnMissing() {
        
        let missing = missingConsentSuccessFPSState()
        
        assert(.deactivateContract, on: missing)
    }
    
    func test_deactivateContract_shouldNotDeliverEffectOnMissing() {
        
        let missing = missingConsentSuccessFPSState()
        
        assert(.deactivateContract, on: missing, effect: nil)
    }
    
    func test_deactivateContract_shouldNotChangeStateOnConnectivityError() {
        
        let connectivityError = connectivityErrorFPSState()
        
        assert(.deactivateContract, on: connectivityError)
    }
    
    func test_deactivateContract_shouldNotDeliverEffectOnConnectivityError() {
        
        let connectivityError = connectivityErrorFPSState()
        
        assert(.deactivateContract, on: connectivityError, effect: nil)
    }
    
    func test_deactivateContract_shouldNotChangeStateOnServerError() {
        
        let serverError = serverErrorFPSState()
        
        assert(.deactivateContract, on: serverError)
    }
    
    func test_deactivateContract_shouldNotDeliverEffectOnServerError() {
        
        let serverError = serverErrorFPSState()
        
        assert(.deactivateContract, on: serverError, effect: nil)
    }
    
    // MARK: - expandProducts
    
    func test_expandProducts_shouldExpandCollapsedStateOnActive_collapsed() {
        
        let (details, active) = contractedState(.active, selector: .collapsed)
        
        assert(expandProducts(), on: active) {
            $0.userPaymentSettings = .contracted(details.updated(
                productSelector: details.productSelector.updated(
                    status: .expanded
                )
            ))
        }
    }
    
    func test_expandProducts_shouldNotChangeStateOnActive_expanded() {
        
        let active = contractedState(.active, selector: .expanded).state
        
        assert(expandProducts(), on: active)
    }
    
    func test_expandProducts_shouldNotDeliverEffectOnActive() {
        
        let active = contractedState(.active).state
        
        assert(expandProducts(), on: active, effect: nil)
    }
    
    func test_expandProducts_shouldNotChangeStateOnInactive() {
        
        let inactive = contractedState(.inactive).state
        
        assert(expandProducts(), on: inactive)
    }
    
    func test_expandProducts_shouldNotDeliverEffectOnInactive() {
        
        let inactive = contractedState(.inactive).state
        
        assert(expandProducts(), on: inactive, effect: nil)
    }
    
    func test_expandProducts_shouldNotChangeStateOnMissing() {
        
        let missing = missingConsentSuccessFPSState()
        
        assert(expandProducts(), on: missing)
    }
    
    func test_expandProducts_shouldNotDeliverEffectOnMissing() {
        
        let missing = missingConsentSuccessFPSState()
        
        assert(expandProducts(), on: missing, effect: nil)
    }
    
    func test_expandProducts_shouldNotChangeStateOnConnectivityErrorFailure() {
        
        let connectivityError = connectivityErrorFPSState()
        
        assert(expandProducts(), on: connectivityError)
    }
    
    func test_expandProducts_shouldNotDeliverEffectOnConnectivityErrorFailure() {
        
        let connectivityError = connectivityErrorFPSState()
        
        assert(expandProducts(), on: connectivityError, effect: nil)
    }
    
    func test_expandProducts_shouldNotChangeStateOnServerErrorFailure() {
        
        let serverError = serverErrorFPSState()
        
        assert(expandProducts(), on: serverError)
    }
    
    func test_expandProducts_shouldNotDeliverEffectOnServerErrorFailure() {
        
        let serverError = serverErrorFPSState()
        
        assert(expandProducts(), on: serverError, effect: nil)
    }
    
    // MARK: - loadSettings
    
    func test_loadSettings_shouldSetStateToSettingsWithoutStatus_emptyState() {
        
        let state = fastPaymentsSettingsState(status: .inflight)
        let loaded = contractedSettings()
        
        assert(.loadSettings(loaded), on: state) {
            $0.userPaymentSettings = loaded
            $0.status = nil
        }
    }
    
    func test_loadSettings_shouldNotDeliverEffect_emptyState() {
        
        let state = fastPaymentsSettingsState(status: .inflight)
        let loaded = contractedSettings()
        
        assert(.loadSettings(loaded), on: state, effect: nil)
    }
    
    func test_loadSettings_shouldSetStateToLoadedSettingsWithoutStatus_nonEmptyState() {
        
        let contracted = contractedSettings()
        let loaded = contractedSettings()
        let state = fastPaymentsSettingsState(contracted, status: .inflight)
        
        assert(.loadSettings(loaded), on: state) {
            $0.userPaymentSettings = loaded
            $0.status = nil
        }
    }
    
    func test_loadSettings_shouldNotDeliverEffect_nonEmptyState() {
        
        let contracted = contractedSettings()
        let loaded = contractedSettings()
        let state = fastPaymentsSettingsState(contracted, status: .inflight)
        
        assert(.loadSettings(loaded), on: state, effect: nil)
    }
    
    // MARK: - prepareSetBankDefault
    
    func test_prepareSetBankDefault_shouldResetStatusOnActive_offEnabled_setBankDefaultStatus() {
        
        let (details, active) = contractedState(
            .active,
            bankDefault: .offEnabled,
            status: .setBankDefault
        )
        
        assert(prepareSetBankDefault(), on: active) {
            $0.userPaymentSettings = .contracted(details)
            $0.status = nil
        }
    }
    
    func test_prepareSetBankDefault_shouldDeliverEffectOnActive_offEnabled_setBankDefaultStatus() {
        
        let (_, active) = contractedState(
            .active,
            bankDefault: .offEnabled,
            status: .setBankDefault
        )
        
        assert(prepareSetBankDefault(), on: active, effect: .prepareSetBankDefault)
    }
    
    func test_prepareSetBankDefault_shouldNotChangeStateOnActive_offDisabled_setBankDefaultStatus() {
        
        let (_, active) = contractedState(
            .active,
            bankDefault: .offDisabled,
            status: .setBankDefault
        )
        
        assert(prepareSetBankDefault(), on: active)
    }
    
    func test_prepareSetBankDefault_shouldNotDeliverEffectOnActive_offDisabled_setBankDefaultStatus() {
        
        let (_, active) = contractedState(
            .active,
            bankDefault: .offDisabled,
            status: .setBankDefault
        )
        
        assert(prepareSetBankDefault(), on: active, effect: nil)
    }
    
    func test_prepareSetBankDefault_shouldNotChangeStateOnActive_onDisabled_setBankDefaultStatus() {
        
        let (_, active) = contractedState(
            .active,
            bankDefault: .onDisabled,
            status: .setBankDefault
        )
        
        assert(prepareSetBankDefault(), on: active)
    }
    
    func test_prepareSetBankDefault_shouldNotDeliverEffectOnActive_onDisabled_setBankDefaultStatus() {
        
        let (_, active) = contractedState(
            .active,
            bankDefault: .onDisabled,
            status: .setBankDefault
        )
        
        assert(prepareSetBankDefault(), on: active, effect: nil)
    }
    
    func test_prepareSetBankDefault_shouldNotChangeStateOnActive_offEnabled_nonSetBankDefaultStatus() {
        
        let (_, active) = contractedState(
            .active,
            bankDefault: .offEnabled,
            status: .inflight
        )
        
        assert(prepareSetBankDefault(), on: active)
    }
    
    func test_prepareSetBankDefault_shouldNotDeliverEffectOnActive_offEnabled_nonSetBankDefaultStatus() {
        
        let (_, active) = contractedState(
            .active,
            bankDefault: .offEnabled,
            status: .inflight
        )
        
        assert(prepareSetBankDefault(), on: active, effect: nil)
    }
    
    func test_prepareSetBankDefault_shouldNotChangeStateOnActive_offEnabled_nilStatus() {
        
        let (_, active) = contractedState(
            .active,
            bankDefault: .offEnabled,
            status: nil
        )
        
        assert(prepareSetBankDefault(), on: active)
    }
    
    func test_prepareSetBankDefault_shouldNotDeliverEffectOnActive_offEnabled_nilStatus() {
        
        let (_, active) = contractedState(
            .active,
            bankDefault: .offEnabled,
            status: nil
        )
        
        assert(prepareSetBankDefault(), on: active, effect: nil)
    }
    
    func test_prepareSetBankDefault_shouldNotChangeStateOnActive_offDisabled() {
        
        let (_, active) = contractedState(.active, bankDefault: .offDisabled)
        
        assert(prepareSetBankDefault(), on: active)
    }
    
    func test_prepareSetBankDefault_shouldNotDeliverEffectOnActive_offDisabled() {
        
        let (_, active) = contractedState(.active, bankDefault: .offDisabled)
        
        assert(prepareSetBankDefault(), on: active, effect: nil)
    }
    
    func test_prepareSetBankDefault_shouldNotChangeStateOnActive_onDisabled() {
        
        let (_, active) = contractedState(.active, bankDefault: .onDisabled)
        
        assert(prepareSetBankDefault(), on: active)
    }
    
    func test_prepareSetBankDefault_shouldNotDeliverEffectOnActive_onDisabled() {
        
        let (_, active) = contractedState(.active, bankDefault: .onDisabled)
        
        assert(prepareSetBankDefault(), on: active, effect: nil)
    }
    
    func test_prepareSetBankDefault_shouldNotChangeStateOnInactive() {
        
        let (_, inactive) = contractedState(.inactive)
        
        assert(prepareSetBankDefault(), on: inactive)
    }
    
    func test_prepareSetBankDefault_shouldNotDeliverEffectOnInactive() {
        
        let (_, inactive) = contractedState(.inactive)
        
        assert(prepareSetBankDefault(), on: inactive, effect: nil)
    }
    
    func test_prepareSetBankDefault_shouldNotChangeStateOnMissing() {
        
        let missing = missingConsentSuccessFPSState()
        
        assert(prepareSetBankDefault(), on: missing)
    }
    
    func test_prepareSetBankDefault_shouldNotDeliverEffectOnMissing() {
        
        let missing = missingConsentSuccessFPSState()
        
        assert(prepareSetBankDefault(), on: missing, effect: nil)
    }
    
    func test_prepareSetBankDefault_shouldNotChangeStateOnConnectivityError() {
        
        let serverError = serverErrorFPSState()
        
        assert(prepareSetBankDefault(), on: serverError)
    }
    
    func test_prepareSetBankDefault_shouldNotDeliverEffectOnConnectivityError() {
        
        let serverError = serverErrorFPSState()
        
        assert(prepareSetBankDefault(), on: serverError, effect: nil)
    }
    
    func test_prepareSetBankDefault_shouldNotChangeStateOnServerError() {
        
        let serverError = serverErrorFPSState()
        
        assert(prepareSetBankDefault(), on: serverError)
    }
    
    func test_prepareSetBankDefault_shouldNotDeliverEffectOnServerError() {
        
        let serverError = serverErrorFPSState()
        
        assert(prepareSetBankDefault(), on: serverError, effect: nil)
    }
    
    // MARK: - resetStatus
    
    func test_resetStatus_shouldNotChangeEmptyState() {
        
        let empty = fastPaymentsSettingsState()
        
        assert(.resetStatus, on: empty)
    }
    
    func test_resetStatus_shouldNotDeliverEffectOnEmptyState() {
        
        let empty = fastPaymentsSettingsState()
        
        assert(.resetStatus, on: empty, effect: nil)
    }
    
    func test_resetStatus_shouldSetStateToEmptyOnNonNilStatusWithNilSettings() {
        
        let withStatus = fastPaymentsSettingsState(
            status: .confirmSetBankDefault
        )
        let empty = fastPaymentsSettingsState()
        
        assert(.resetStatus, on: withStatus) {
            $0 = empty
        }
    }
    
    func test_resetStatus_shouldNotDeliverEffectOnNonNilStatusWithNilSettings() {
        
        let withStatus = fastPaymentsSettingsState(
            status: .confirmSetBankDefault
        )
        
        assert(.resetStatus, on: withStatus, effect: nil)
    }
    
    func test_resetStatus_shouldNotChangeStateOnActiveWithoutStatus() {
        
        let (_, activeWithoutStatus) = contractedState(
            .active,
            status: nil
        )
        
        assert(.resetStatus, on: activeWithoutStatus)
    }
    
    func test_resetStatus_shouldNotDeliverEffectOnActiveWithoutStatus() {
        
        let (_, activeWithoutStatus) = contractedState(
            .active,
            status: nil
        )
        
        assert(.resetStatus, on: activeWithoutStatus, effect: nil)
    }
    
    func test_resetStatus_shouldResetStatusOnActiveWithStatus() {
        
        let (details, activeWithStatus) = contractedState(
            .active,
            status: .confirmSetBankDefault
        )
        
        assert(.resetStatus, on: activeWithStatus) {
            $0.userPaymentSettings = .contracted(details)
            $0.status = nil
        }
    }
    
    func test_resetStatus_shouldNotDeliverEffectOnActiveWithStatus() {
        
        let (_, activeWithStatus) = contractedState(
            .active,
            status: .confirmSetBankDefault
        )
        
        assert(.resetStatus, on: activeWithStatus, effect: nil)
    }
    
    func test_resetStatus_shouldNotChangeStateOnInactiveWithoutStatus() {
        
        let (_, inactiveWithoutStatus) = contractedState(
            .active,
            status: nil
        )
        
        assert(.resetStatus, on: inactiveWithoutStatus)
    }
    
    func test_resetStatus_shouldNotDeliverEffectOnInactiveWithoutStatus() {
        
        let (_, inactiveWithoutStatus) = contractedState(
            .active,
            status: nil
        )
        
        assert(.resetStatus, on: inactiveWithoutStatus, effect: nil)
    }
    
    func test_resetStatus_shouldResetStatusOnInactiveWithStatus() {
        
        let (details, inactiveWithStatus) = contractedState(
            .active,
            status: .confirmSetBankDefault
        )
        
        assert(.resetStatus, on: inactiveWithStatus) {
            $0.userPaymentSettings = .contracted(details)
            $0.status = nil
        }
    }
    
    func test_resetStatus_shouldNotDeliverEffectOnInactiveWithStatus() {
        
        let (_, inactiveWithStatus) = contractedState(
            .active,
            status: .confirmSetBankDefault
        )
        
        assert(.resetStatus, on: inactiveWithStatus, effect: nil)
    }
    
    func test_resetStatus_shouldNotChangeStateOnMissingWithoutStatus() {
        
        let missingWithoutStatus = missingConsentSuccessFPSState(status: nil)
        
        assert(.resetStatus, on: missingWithoutStatus)
    }
    
    func test_resetStatus_shouldNotDeliverEffectOnMissingWithoutStatus() {
        
        let missingWithoutStatus = missingConsentSuccessFPSState(status: nil)
        
        assert(.resetStatus, on: missingWithoutStatus, effect: nil)
    }
    
    func test_resetStatus_shouldResetStatusOnMissingWithStatus() {
        
        let settings = missingConsentSuccessSettings()
        let missingWithStatus = fastPaymentsSettingsState(
            settings,
            status: .confirmSetBankDefault
        )
        
        assert(.resetStatus, on: missingWithStatus) {
            $0.userPaymentSettings = settings
            $0.status = nil
        }
    }
    
    func test_resetStatus_shouldNotDeliverEffectOnMissingWithStatus() {
        
        let missingWithStatus = missingConsentSuccessFPSState(status: .confirmSetBankDefault)
        
        assert(.resetStatus, on: missingWithStatus, effect: nil)
    }
    
    func test_resetStatus_shouldNotChangeStateOnConnectivityErrorWithoutStatus() {
        
        let (_, withoutStatus) = connectivityError(status: nil)
        
        assert(.resetStatus, on: withoutStatus)
    }
    
    func test_resetStatus_shouldNotDeliverEffectOnConnectivityErrorWithoutStatus() {
        
        let (_, withoutStatus) = connectivityError(status: nil)
        
        assert(.resetStatus, on: withoutStatus, effect: nil)
    }
    
    func test_resetStatus_shouldResetStatusOnConnectivityErrorWithStatus() {
        
        let (settings, withStatus) = connectivityError(status: .confirmSetBankDefault)
        
        assert(.resetStatus, on: withStatus) {
            $0.userPaymentSettings = settings
            $0.status = nil
        }
    }
    
    func test_resetStatus_shouldNotDeliverEffectOnConnectivityErrorWithStatus() {
        
        let (_, withStatus) = connectivityError(status: .confirmSetBankDefault)
        
        assert(.resetStatus, on: withStatus, effect: nil)
    }
    
    func test_resetStatus_shouldNotChangeStateOnServerErrorWithoutStatus() {
        
        let (_, withoutStatus) = serverError(status: nil)
        
        assert(.resetStatus, on: withoutStatus)
    }
    
    func test_resetStatus_shouldNotDeliverEffectOnServerErrorWithoutStatus() {
        
        let (_, withoutStatus) = serverError(status: nil)
        
        assert(.resetStatus, on: withoutStatus, effect: nil)
    }
    
    func test_resetStatus_shouldResetStatusOnServerErrorWithStatus() {
        
        let (settings, withStatus) = serverError(status: .confirmSetBankDefault)
        
        assert(.resetStatus, on: withStatus) {
            $0.userPaymentSettings = settings
            $0.status = nil
        }
    }
    
    func test_resetStatus_shouldNotDeliverEffectOnServerErrorWithStatus() {
        
        let (_, withStatus) = serverError(status: .confirmSetBankDefault)
        
        assert(.resetStatus, on: withStatus, effect: nil)
    }
    
    // MARK: - selectProduct
    
    func test_selectProduct_shouldSetStatusOnDifferentProductSelectionInActive_expanded() {
        
        let (selected, different) = (makeProduct(), makeProduct())
        let (details, active) = contractedState(.active, selector: .expanded)
        let sut = makeSUT(products: [selected, different])
        
        assert(sut: sut, selectProduct(different), on: active) {
            $0.userPaymentSettings = .contracted(details)
            $0.status = .inflight
        }
    }
    
    func test_selectProduct_shouldDeliverEffectOnDifferentProductSelectionInActive_expanded() {
        
        let (selected, different) = (makeProduct(), makeProduct())
        let (details, active) = contractedState(.active, selector: .expanded)
        let core = makeCore(details, different)
        let sut = makeSUT(products: [selected, different])
        
        assert(sut: sut, selectProduct(different), on: active, effect: .updateProduct(core))
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
        
        assert(sut: sut, selectProduct(selected), on: active) {
            $0.userPaymentSettings = .contracted(details.updated(
                productSelector: details.productSelector.updated(
                    status: .collapsed
                )
            ))
        }
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
        
        assert(sut: sut, selectProduct(selected), on: active, effect: nil)
    }
    
    func test_selectProduct_shouldCollapseOnActive_expanded_emptyProducts() {
        
        let (details, active) = contractedState(.active, selector: .expanded)
        let sut = makeSUT(products: [])
        
        assert(sut: sut, selectProduct(), on: active) {
            $0.userPaymentSettings = .contracted(details.updated(
                productSelector: details.productSelector.updated(
                    status: .collapsed
                )
            ))
        }
    }
    
    func test_selectProduct_shouldNotDeliverEffectOnActive_expanded_emptyProducts() {
        
        let active = contractedState(.active, selector: .expanded).state
        let sut = makeSUT(products: [])
        
        assert(sut: sut, selectProduct(), on: active, effect: nil)
    }
    
    func test_selectProduct_shouldNotChangeStateOnActive_collapsed() {
        
        let active = contractedState(.active, selector: .collapsed).state
        
        assert(selectProduct(), on: active)
    }
    
    func test_selectProduct_shouldNotDeliverEffectOnActive_collapsed() {
        
        let active = contractedState(.active, selector: .collapsed).state
        
        assert(selectProduct(), on: active, effect: nil)
    }
    
    func test_selectProduct_shouldNotChangeStateOnInactive() {
        
        let inactive = contractedState(.inactive).state
        
        assert(selectProduct(), on: inactive)
    }
    
    func test_selectProduct_shouldNotDeliverEffectOnInactive() {
        
        let inactive = contractedState(.inactive).state
        
        assert(selectProduct(), on: inactive, effect: nil)
    }
    
    func test_selectProduct_shouldNotChangeStateOnMissing() {
        
        let missing = missingConsentSuccessFPSState()
        
        assert(selectProduct(), on: missing)
    }
    
    func test_selectProduct_shouldNotDeliverEffectOnMissing() {
        
        let missing = missingConsentSuccessFPSState()
        
        assert(selectProduct(), on: missing, effect: nil)
    }
    
    func test_selectProduct_shouldNotChangeStateOnConnectivityErrorFailure() {
        
        let connectivityError = connectivityErrorFPSState()
        
        assert(selectProduct(), on: connectivityError)
    }
    
    func test_selectProduct_shouldNotDeliverEffectOnConnectivityErrorFailure() {
        
        let connectivityError = connectivityErrorFPSState()
        
        assert(selectProduct(), on: connectivityError, effect: nil)
    }
    
    func test_selectProduct_shouldNotChangeStateOnServerErrorFailure() {
        
        let serverError = serverErrorFPSState()
        
        assert(selectProduct(), on: serverError)
    }
    
    func test_selectProduct_shouldNotDeliverEffectOnServerErrorFailure() {
        
        let serverError = serverErrorFPSState()
        
        assert(selectProduct(), on: serverError, effect: nil)
    }
    
    // MARK: - setBankDefault
    
    func test_setBankDefault_shouldSetStatusOnActive_offEnabled() {
        
        let (details, active) = contractedState(.active, bankDefault: .offEnabled)
        
        assert(setBankDefault(), on: active) {
            $0.userPaymentSettings = .contracted(details)
            $0.status = .setBankDefault
        }
    }
    
    func test_setBankDefault_shouldNotDeliverEffectOnActive_offEnabled() {
        
        let (_, active) = contractedState(.active, bankDefault: .offEnabled)
        
        assert(setBankDefault(), on: active, effect: nil)
    }
    
    func test_setBankDefault_shouldNotChangeStateOnActive_offDisabled() {
        
        let (_, active) = contractedState(.active, bankDefault: .offDisabled)
        
        assert(setBankDefault(), on: active)
    }
    
    func test_setBankDefault_shouldNotDeliverEffectOnActive_offDisabled() {
        
        let (_, active) = contractedState(.active, bankDefault: .offDisabled)
        
        assert(setBankDefault(), on: active, effect: nil)
    }
    
    func test_setBankDefault_shouldNotChangeStateOnActive_onDisabled() {
        
        let (_, active) = contractedState(.active, bankDefault: .onDisabled)
        
        assert(setBankDefault(), on: active)
    }
    
    func test_setBankDefault_shouldNotDeliverEffectOnActive_onDisabled() {
        
        let (_, active) = contractedState(.active, bankDefault: .onDisabled)
        
        assert(setBankDefault(), on: active, effect: nil)
    }
    
    func test_setBankDefault_shouldNotChangeStateOnInactive() {
        
        let (_, inactive) = contractedState(.inactive)
        
        assert(setBankDefault(), on: inactive)
    }
    
    func test_setBankDefault_shouldNotDeliverEffectOnInactive() {
        
        let (_, inactive) = contractedState(.inactive)
        
        assert(setBankDefault(), on: inactive, effect: nil)
    }
    
    func test_setBankDefault_shouldNotChangeStateOnMissing() {
        
        let missing = missingConsentSuccessFPSState()
        
        assert(setBankDefault(), on: missing)
    }
    
    func test_setBankDefault_shouldNotDeliverEffectOnMissing() {
        
        let missing = missingConsentSuccessFPSState()
        
        assert(setBankDefault(), on: missing, effect: nil)
    }
    
    func test_setBankDefault_shouldNotChangeStateOnConnectivityError() {
        
        let serverError = serverErrorFPSState()
        
        assert(setBankDefault(), on: serverError)
    }
    
    func test_setBankDefault_shouldNotDeliverEffectOnConnectivityError() {
        
        let serverError = serverErrorFPSState()
        
        assert(setBankDefault(), on: serverError, effect: nil)
    }
    
    func test_setBankDefault_shouldNotChangeStateOnServerError() {
        
        let serverError = serverErrorFPSState()
        
        assert(setBankDefault(), on: serverError)
    }
    
    func test_setBankDefault_shouldNotDeliverEffectOnServerError() {
        
        let serverError = serverErrorFPSState()
        
        assert(setBankDefault(), on: serverError, effect: nil)
    }
    
    // MARK: - setBankDefaultPrepared
    
    func test_setBankDefaultPrepared_shouldSetBankDefaultAndInformerOnSuccess_active() {
        
        let (details, active) = contractedState(.active)
        
        assert(setBankDefaultPreparedSuccess(), on: active) {
            $0.userPaymentSettings = .contracted(details.updated(
                bankDefault: .onDisabled
            ))
            $0.status = .setBankDefaultSuccess
        }
    }
    
    func test_setBankDefaultPrepared_shouldNotDeliverEffectOnSuccess_active() {
        
        let active = contractedState(.active).state
        
        assert(setBankDefaultPreparedSuccess(), on: active, effect: nil)
    }
    
    func test_setBankDefaultPrepared_shouldSetStatusOnConnectivityErrorFailure_active() {
        
        let active = activeContractSettings()
        
        assert(setBankDefaultPreparedConnectivityError(), on: active) {
            $0.userPaymentSettings = active
            $0.status = .connectivityError
        }
    }
    
    func test_setBankDefaultPrepared_shouldNotDeliverEffectOnConnectivityErrorFailure_active() {
        
        let active = activeContractSettings()
        
        assert(active, setBankDefaultPreparedConnectivityError(), effect: nil)
    }
    
    func test_setBankDefaultPrepared_shouldSetStatusOnServerErrorFailure_active() {
        
        let message = anyMessage()
        let active = activeContractSettings()
        
        assert(.bankDefault(.setBankDefaultPrepared(.serverError(message))), on: active) {
            $0.userPaymentSettings = active
            $0.status = .serverError(message)
        }
    }
    
    func test_setBankDefaultPrepared_shouldNotDeliverEffectOnServerErrorFailure_active() {
        
        let active = activeContractSettings()
        
        assert(active, setBankDefaultPreparedServerError(), effect: nil)
    }
    
    func test_setBankDefaultPrepared_shouldNotChangeStateOnSuccess_inactive() {
        
        let inactive = contractedState(.inactive).state
        
        assert(setBankDefaultPreparedSuccess(), on: inactive)
    }
    
    func test_setBankDefaultPrepared_shouldNotDeliverEffectOnSuccess_inactive() {
        
        let inactive = contractedState(.inactive).state
        
        assert(setBankDefaultPreparedSuccess(), on: inactive, effect: nil)
    }
    
    func test_setBankDefaultPrepared_shouldNotChangeStateOnConnectivityErrorFailure_inactive() {
        
        let inactive = contractedState(.inactive).state
        
        assert(setBankDefaultPreparedConnectivityError(), on: inactive)
    }
    
    func test_setBankDefaultPrepared_shouldNotDeliverEffectOnConnectivityErrorFailure_inactive() {
        
        let inactive = contractedState(.inactive).state
        
        assert(setBankDefaultPreparedConnectivityError(), on: inactive, effect: nil)
    }
    
    func test_setBankDefaultPrepared_shouldNotChangeStateOnServerErrorFailure_inactive() {
        
        let inactive = contractedState(.inactive).state
        
        assert(setBankDefaultPreparedServerError(), on: inactive)
    }
    
    func test_setBankDefaultPrepared_shouldNotDeliverEffectOnServerErrorFailure_inactive() {
        
        let inactive = contractedState(.inactive).state
        
        assert(setBankDefaultPreparedServerError(), on: inactive, effect: nil)
    }
    
    func test_setBankDefaultPrepared_shouldNotChangeStateOnSuccess_missing() {
        
        let missing = missingConsentSuccessFPSState()
        
        assert(setBankDefaultPreparedSuccess(), on: missing)
    }
    
    func test_setBankDefaultPrepared_shouldNotDeliverEffectOnSuccess_missing() {
        
        let missing = missingConsentSuccessFPSState()
        
        assert(setBankDefaultPreparedSuccess(), on: missing, effect: nil)
    }
    
    func test_setBankDefaultPrepared_shouldNotChangeStateOnConnectivityErrorFailure_missing() {
        
        let missing = missingConsentSuccessFPSState()
        
        assert(setBankDefaultPreparedConnectivityError(), on: missing)
    }
    
    func test_setBankDefaultPrepared_shouldNotDeliverEffectOnConnectivityErrorFailure_missing() {
        
        let missing = missingConsentSuccessFPSState()
        
        assert(setBankDefaultPreparedConnectivityError(), on: missing, effect: nil)
    }
    
    func test_setBankDefaultPrepared_shouldNotChangeStateOnServerErrorFailure_missing() {
        
        let missing = missingConsentSuccessFPSState()
        
        assert(setBankDefaultPreparedServerError(), on: missing)
    }
    
    func test_setBankDefaultPrepared_shouldNotDeliverEffectOnServerErrorFailure_missing() {
        
        let missing = missingConsentSuccessFPSState()
        
        assert(setBankDefaultPreparedServerError(), on: missing, effect: nil)
    }
    
    func test_setBankDefaultPrepared_shouldNotChangeStateOnSuccess_connectivityError() {
        
        let connectivityError = connectivityErrorFPSState()
        
        assert(setBankDefaultPreparedSuccess(), on: connectivityError)
    }
    
    func test_setBankDefaultPrepared_shouldNotDeliverEffectOnSuccess_connectivityError() {
        
        let connectivityError = connectivityErrorFPSState()
        
        assert(setBankDefaultPreparedSuccess(), on: connectivityError, effect: nil)
    }
    
    func test_setBankDefaultPrepared_shouldNotChangeStateOnConnectivityErrorFailure_connectivityError() {
        
        let connectivityError = connectivityErrorFPSState()
        
        assert(setBankDefaultPreparedConnectivityError(), on: connectivityError)
    }
    
    func test_setBankDefaultPrepared_shouldNotDeliverEffectOnConnectivityErrorFailure_connectivityError() {
        
        let connectivityError = connectivityErrorFPSState()
        
        assert(setBankDefaultPreparedConnectivityError(), on: connectivityError, effect: nil)
    }
    
    func test_setBankDefaultPrepared_shouldNotChangeStateOnServerErrorFailure_connectivityError() {
        
        let connectivityError = connectivityErrorFPSState()
        
        assert(setBankDefaultPreparedServerError(), on: connectivityError)
    }
    
    func test_setBankDefaultPrepared_shouldNotDeliverEffectOnServerErrorFailure_connectivityError() {
        
        let connectivityError = connectivityErrorFPSState()
        
        assert(setBankDefaultPreparedServerError(), on: connectivityError, effect: nil)
    }
    
    func test_setBankDefaultPrepared_shouldNotChangeStateOnSuccess_serverError() {
        
        let serverError = serverErrorFPSState()
        
        assert(setBankDefaultPreparedSuccess(), on: serverError)
    }
    
    func test_setBankDefaultPrepared_shouldNotDeliverEffectOnSuccess_serverError() {
        
        let serverError = serverErrorFPSState()
        
        assert(setBankDefaultPreparedSuccess(), on: serverError, effect: nil)
    }
    
    func test_setBankDefaultPrepared_shouldNotChangeStateOnConnectivityErrorFailure_serverError() {
        
        let serverError = serverErrorFPSState()
        
        assert(setBankDefaultPreparedConnectivityError(), on: serverError)
    }
    
    func test_setBankDefaultPrepared_shouldNotDeliverEffectOnConnectivityErrorFailure_serverError() {
        
        let serverError = serverErrorFPSState()
        
        assert(setBankDefaultPreparedConnectivityError(), on: serverError, effect: nil)
    }
    
    func test_setBankDefaultPrepared_shouldNotChangeStateOnServerErrorFailure_serverError() {
        
        let serverError = serverErrorFPSState()
        
        assert(setBankDefaultPreparedServerError(), on: serverError)
    }
    
    func test_setBankDefaultPrepared_shouldNotDeliverEffectOnServerErrorFailure_serverError() {
        
        let serverError = serverErrorFPSState()
        
        assert(setBankDefaultPreparedServerError(), on: serverError, effect: nil)
    }
    
    // MARK: - updateContract
    
    func test_updateContract_shouldSetContractOnSuccess_active() {
        
        let (details, activeContract) = contractedState(.active)
        let newContract = paymentContract()
        
        assert(updateContractSuccess(newContract), on: activeContract) {
            $0.userPaymentSettings = .contracted(details.updated(
                paymentContract: newContract
            ))
        }
    }
    
    func test_updateContract_shouldNotDeliverEffectOnSuccess_active() {
        
        let active = contractedState(.active).state
        
        assert(updateContractSuccess(), on: active, effect: nil)
    }
    
    func test_updateContract_shouldSetStatusToConnectivityErrorOnConnectivityFailure_active() {
        
        let (details, active) = contractedState(.active)
        let event = updateContractConnectivityError()
        
        assert(event, on: active) {
            $0.userPaymentSettings = .contracted(details)
            $0.status = .connectivityError
        }
    }
    
    func test_updateContract_shouldNotDeliverEffectOnConnectivityFailure_active() {
        
        let active = contractedState(.active).state
        
        assert(updateContractConnectivityError(), on: active, effect: nil)
    }
    
    func test_updateContract_shouldSetStatusToServerErrorOnServerErrorFailure_active() {
        
        let message = anyMessage()
        let (details, active) = contractedState(.active)
        
        assert(updateContractServerError(message), on: active) {
            $0.userPaymentSettings = .contracted(details)
            $0.status = .serverError(message)
        }
    }
    
    func test_updateContract_shouldNotDeliverEffectOnServerErrorFailure_active() {
        
        let active = contractedState(.active).state
        
        assert(updateContractServerError(), on: active, effect: nil)
    }
    
    func test_updateContract_shouldSetContractOnSuccess_inactive() {
        
        let (details, inactive) = contractedState(.inactive)
        let newContract = paymentContract()
        
        assert(updateContractSuccess(newContract), on: inactive) {
            $0.userPaymentSettings = .contracted(details.updated(
                paymentContract: newContract
            ))
        }
    }
    
    func test_updateContract_shouldNotDeliverEffectOnSuccess_inactive() {
        
        let inactive = contractedState(.inactive).state
        
        assert(updateContractSuccess(), on: inactive, effect: nil)
    }
    
    func test_updateContract_shouldSetStatusToConnectivityErrorOnConnectivityFailure_inactive() {
        
        let (details, inactive) = contractedState(.inactive)
        
        assert(updateContractConnectivityError(), on: inactive) {
            $0.userPaymentSettings = .contracted(details)
            $0.status = .connectivityError
        }
    }
    
    func test_updateContract_shouldNotDeliverEffectOnConnectivityFailure_inactive() {
        
        let inactive = contractedState(.inactive).state
        
        assert(updateContractConnectivityError(), on: inactive, effect: nil)
    }
    
    func test_updateContract_shouldSetStatusToServerErrorOnServerErrorFailure_inactive() {
        
        let message = anyMessage()
        let (details, inactive) = contractedState(.inactive)
        
        assert(updateContractServerError(message), on: inactive) {
            $0.userPaymentSettings = .contracted(details)
            $0.status = .serverError(message)
        }
    }
    
    func test_updateContract_shouldNotDeliverEffectOnServerErrorFailure_inactive() {
        
        let inactive = contractedState(.inactive).state
        
        assert(updateContractServerError(), on: inactive, effect: nil)
    }
    
    func test_updateContract_shouldSetContractOnSuccess_missing() {
        
        let consentResult = consentResultFailure()
        let missing = missingContract(consentResult)
        let (product1, selected) = (makeProduct(), makeProduct())
        let newContract = paymentContract(productID: selected.id)
        let sut = makeSUT(products: [product1, selected])
        
        assert(sut: sut, updateContractSuccess(newContract), on: missing) {
            $0.userPaymentSettings = .contracted(.init(
                paymentContract: newContract,
                consentResult: consentResult,
                bankDefault: .offEnabled,
                productSelector: .init(
                    selectedProduct: selected,
                    products: [product1, selected]
                )
            ))
        }
    }
    
    func test_updateContract_shouldSetContractAndSelectorWithoutSelectedProductOnSuccessAndMissingProduct_missing() {
        
        let consentResult = consentResultFailure()
        let missing = missingContract(consentResult)
        let (product1, missingProduct) = (makeProduct(), makeProduct())
        let newContract = paymentContract(productID: missingProduct.id)
        let sut = makeSUT(products: [product1])
        
        assert(sut: sut, updateContractSuccess(newContract), on: missing) {
            $0.userPaymentSettings = .contracted(.init(
                paymentContract: newContract,
                consentResult: consentResult,
                bankDefault: .offEnabled,
                productSelector: .init(
                    selectedProduct: nil,
                    products: [product1]
                )
            ))
        }
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
        
        assert(sut: sut, event, on: missing) {
            $0.userPaymentSettings = missing
            $0.status = .connectivityError
        }
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
        
        assert(sut: sut, event, on: missing) {
            $0.userPaymentSettings = missing
            $0.status = .serverError(message)
        }
    }
    
    func test_updateContract_shouldNotDeliverEffectOnServerErrorFailure_missing() {
        
        let missing = missingConsentSuccessSettings()
        
        assert(missing, updateContractServerError(), effect: nil)
    }
    
    func test_updateContract_shouldNotChangeStateOnSuccess_connectivityError() {
        
        let connectivityError = connectivityErrorFPSState()
        
        assert(updateContractSuccess(), on: connectivityError)
    }
    
    func test_updateContract_shouldNotDeliverEffectOnSuccess_connectivityError() {
        
        let connectivityError = connectivityErrorFPSState()
        
        assert(updateContractSuccess(), on: connectivityError, effect: nil)
    }
    
    func test_updateContract_shouldNotChangeStateOnConnectivityFailure_connectivityError() {
        
        let connectivityError = connectivityErrorFPSState()
        
        assert(updateContractConnectivityError(), on: connectivityError)
    }
    
    func test_updateContract_shouldNotDeliverEffectOnConnectivityFailure_connectivityError() {
        
        let connectivityError = connectivityErrorFPSState()
        
        assert(updateContractConnectivityError(), on: connectivityError, effect: nil)
    }
    
    func test_updateContract_shouldNotChangeStateOnServerErrorFailure_connectivityError() {
        
        let connectivityError = connectivityErrorFPSState()
        
        assert(updateContractServerError(), on: connectivityError)
    }
    
    func test_updateContract_shouldNotDeliverEffectOnServerErrorFailure_connectivityError() {
        
        let connectivityError = connectivityErrorFPSState()
        
        assert(updateContractServerError(), on: connectivityError, effect: nil)
    }
    
    func test_updateContract_shouldNotChangeStateOnSuccess_serverError() {
        
        let serverError = serverErrorFPSState()
        
        assert(updateContractSuccess(), on: serverError)
    }
    
    func test_updateContract_shouldNotDeliverEffectOnSuccess_serverError() {
        
        let serverError = serverErrorFPSState()
        
        assert(updateContractSuccess(), on: serverError, effect: nil)
    }
    
    func test_updateContract_shouldNotChangeStateOnConnectivityFailure_serverError() {
        
        let serverError = serverErrorFPSState()
        
        assert(updateContractConnectivityError(), on: serverError)
    }
    
    func test_updateContract_shouldNotDeliverEffectOnConnectivityFailure_serverError() {
        
        let serverError = serverErrorFPSState()
        
        assert(updateContractConnectivityError(), on: serverError, effect: nil)
    }
    
    func test_updateContract_shouldNotChangeStateOnServerErrorFailure_serverError() {
        
        let serverError = serverErrorFPSState()
        
        assert(updateContractServerError(), on: serverError)
    }
    
    func test_updateContract_shouldNotDeliverEffectOnServerErrorFailure_serverError() {
        
        let serverError = serverErrorFPSState()
        
        assert(updateContractServerError(), on: serverError, effect: nil)
    }
    
    // MARK: - updateProduct
    
    func test_updateProduct_shouldSetProductOnSuccess_active_collapsed() {
        
        let newProduct = makeProduct()
        let (details, active) = contractedState(.active, selector: .collapsed)
        
        assert(updateProductSuccess(newProduct), on: active) {
            $0.userPaymentSettings = .contracted(details.updated(
                productSelector: details.productSelector.updated(
                    selectedProduct: newProduct,
                    status: .collapsed
                )
            ))
        }
    }
    
    func test_updateProduct_shouldNotDeliverEffectOnSuccess_active_collapsed() {
        
        let active = contractedState(.active, selector: .collapsed).state
        
        assert(updateProductSuccess(), on: active, effect: nil)
    }
    
    func test_updateProduct_shouldCollapseAndSetProductOnSuccess_active_expanded() {
        
        let newProduct = makeProduct()
        let (details, active) = contractedState(.active, selector: .expanded)
        
        assert(updateProductSuccess(newProduct), on: active) {
            $0.userPaymentSettings = .contracted(details.updated(
                productSelector: details.productSelector.updated(
                    selectedProduct: newProduct,
                    status: .collapsed
                )
            ))
        }
    }
    
    func test_updateProduct_shouldNotDeliverEffectOnSuccess_active_expanded() {
        
        let active = contractedState(.active, selector: .expanded).state
        
        assert(updateProductSuccess(), on: active, effect: nil)
    }
    
    func test_updateProduct_shouldSetStatusOnConnectivityErrorFailure_active_collapsed() {
        
        let (details, active) = contractedState(.active, selector: .collapsed)
        
        assert(updateProductConnectivityError(), on: active) {
            $0.userPaymentSettings = .contracted(details)
            $0.status = .connectivityError
        }
    }
    
    func test_updateProduct_shouldNotDeliverEffectOnConnectivityErrorFailure_active_collapsed() {
        
        let active = contractedState(.active, selector: .collapsed).state
        
        assert(updateProductConnectivityError(), on: active, effect: nil)
    }
    
    func test_updateProduct_shouldCollapseAndSetStatusOnConnectivityErrorFailure_active_expanded() {
        
        let (details, active) = contractedState(.active, selector: .expanded)
        
        assert(updateProductConnectivityError(), on: active) {
            $0.userPaymentSettings = .contracted(details.updated(
                productSelector: details.productSelector.updated(
                    status: .collapsed
                )
            ))
            $0.status = .connectivityError
        }
    }
    
    func test_updateProduct_shouldNotDeliverEffectOnConnectivityErrorFailure_active_expanded() {
        
        let active = contractedState(.active, selector: .expanded).state
        
        assert(updateProductConnectivityError(), on: active, effect: nil)
    }
    
    func test_updateProduct_shouldSetStatusOnServerErrorFailure_active_collapsed() {
        
        let message = anyMessage()
        let (details, active) = contractedState(.active, selector: .collapsed)
        
        assert(updateProductServerError(message), on: active) {
            $0.userPaymentSettings = .contracted(details)
            $0.status = .serverError(message)
        }
    }
    
    func test_updateProduct_shouldNotDeliverEffectOnServerErrorFailure_active_collapsed() {
        
        let active = contractedState(.active, selector: .collapsed).state
        
        assert(updateProductServerError(), on: active, effect: nil)
    }
    
    func test_updateProduct_shouldCollapseAndSetStatusOnServerErrorFailure_active_expanded() {
        
        let message = anyMessage()
        let (details, active) = contractedState(.active, selector: .expanded)
        
        assert(updateProductServerError(message), on: active) {
            $0.userPaymentSettings = .contracted(details.updated(
                productSelector: details.productSelector.updated(
                    status: .collapsed
                )
            ))
            $0.status = .serverError(message)
        }
    }
    
    func test_updateProduct_shouldNotDeliverEffectOnServerErrorFailure_active_expanded() {
        
        let active = contractedState(.active, selector: .expanded).state
        
        assert(updateProductServerError(), on: active, effect: nil)
    }
    
    func test_updateProduct_shouldNotChangeStateOnSuccess_inactive() {
        
        let inactive = contractedState(.inactive).state
        
        assert(updateProductSuccess(), on: inactive)
    }
    
    func test_updateProduct_shouldNotDeliverEffectOnSuccess_inactive() {
        
        let inactive = contractedState(.inactive).state
        
        assert(updateProductSuccess(), on: inactive, effect: nil)
    }
    
    func test_updateProduct_shouldNotChangeStateOnConnectivityErrorFailure_inactive() {
        
        let inactive = contractedState(.inactive).state
        
        assert(updateProductConnectivityError(), on: inactive)
    }
    
    func test_updateProduct_shouldNotDeliverEffectOnConnectivityErrorFailure_inactive() {
        
        let inactive = contractedState(.inactive).state
        
        assert(updateProductConnectivityError(), on: inactive, effect: nil)
    }
    
    func test_updateProduct_shouldNotChangeStateOnServerErrorFailure_inactive() {
        
        let inactive = contractedState(.inactive).state
        
        assert(updateProductServerError(), on: inactive)
    }
    
    func test_updateProduct_shouldNotDeliverEffectOnServerErrorFailure_inactive() {
        
        let inactive = contractedState(.inactive).state
        
        assert(updateProductServerError(), on: inactive, effect: nil)
    }
    
    func test_productUpdate_shouldNotChangeStateOnSuccess_missing() {
        
        let missing = missingConsentSuccessFPSState()
        
        assert(updateProductSuccess(), on: missing)
    }
    
    func test_productUpdate_shouldNotDeliverEffectOnSuccess_missing() {
        
        let missing = missingConsentSuccessFPSState()
        
        assert(updateProductSuccess(), on: missing, effect: nil)
    }
    
    func test_productUpdate_shouldNotChangeStateOnConnectivityErrorFailure_missing() {
        
        let missing = missingConsentSuccessFPSState()
        
        assert(updateProductConnectivityError(), on: missing)
    }
    
    func test_productUpdate_shouldNotDeliverEffectOnConnectivityErrorFailure_missing() {
        
        let missing = missingConsentSuccessFPSState()
        
        assert(updateProductConnectivityError(), on: missing, effect: nil)
    }
    
    func test_updateProduct_shouldNotChangeStateOnServerErrorFailure_missing() {
        
        let missing = missingConsentSuccessFPSState()
        
        assert(updateProductServerError(), on: missing)
    }
    
    func test_updateProduct_shouldNotDeliverEffectOnServerErrorFailure_missing() {
        
        let missing = missingConsentSuccessFPSState()
        
        assert(updateProductServerError(), on: missing, effect: nil)
    }
    
    func test_updateProduct_shouldNotChangeStateOnSuccess_connectivityError() {
        
        let connectivityError = connectivityErrorFPSState()
        
        assert(updateProductSuccess(), on: connectivityError)
    }
    
    func test_updateProduct_shouldNotDeliverEffectOnSuccess_connectivityError() {
        
        let connectivityError = connectivityErrorFPSState()
        
        assert(updateProductSuccess(), on: connectivityError, effect: nil)
    }
    
    func test_updateProduct_shouldNotChangeStateOnConnectivityErrorFailure_connectivityError() {
        
        let connectivityError = connectivityErrorFPSState()
        
        assert(updateProductConnectivityError(), on: connectivityError)
    }
    
    func test_updateProduct_shouldNotDeliverEffectOnConnectivityErrorFailure_connectivityError() {
        
        let connectivityError = connectivityErrorFPSState()
        
        assert(updateProductConnectivityError(), on: connectivityError, effect: nil)
    }
    
    func test_updateProduct_shouldNotChangeStateOnServerErrorFailure_connectivityError() {
        
        let connectivityError = connectivityErrorFPSState()
        
        assert(updateProductServerError(), on: connectivityError)
    }
    
    func test_updateProduct_shouldNotDeliverEffectOnServerErrorFailure_connectivityError() {
        
        let connectivityError = connectivityErrorFPSState()
        
        assert(updateProductServerError(), on: connectivityError, effect: nil)
    }
    
    func test_updateProduct_shouldNotChangeStateOnSuccess_serverError() {
        
        let serverError = serverErrorFPSState()
        
        assert(updateProductSuccess(), on: serverError)
    }
    
    func test_updateProduct_shouldNotDeliverEffectOnSuccess_serverError() {
        
        let serverError = serverErrorFPSState()
        
        assert(updateProductSuccess(), on: serverError, effect: nil)
    }
    
    func test_updateProduct_shouldNotChangeStateOnConnectivityErrorFailure_serverError() {
        
        let serverError = serverErrorFPSState()
        
        assert(updateProductConnectivityError(), on: serverError)
    }
    
    func test_updateProduct_shouldNotDeliverEffectOnConnectivityErrorFailure_serverError() {
        
        let serverError = serverErrorFPSState()
        
        assert(updateProductConnectivityError(), on: serverError, effect: nil)
    }
    
    func test_updateProduct_shouldNotChangeStateOnServerErrorFailure_serverError() {
        
        let serverError = serverErrorFPSState()
        
        assert(updateProductServerError(), on: serverError)
    }
    
    func test_updateProduct_shouldNotDeliverEffectOnServerErrorFailure_serverError() {
        
        let serverError = serverErrorFPSState()
        
        assert(updateProductServerError(), on: serverError, effect: nil)
    }
    
    // MARK: - Helpers
    
    private typealias SUT = FastPaymentsSettingsReducer
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
        _ event: Event,
        on settings: UserPaymentSettings,
        updateStateToExpected: UpdateStateToExpected<State>? = nil,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        assert(
            sut: sut,
            event,
            on: .init(userPaymentSettings: settings),
            updateStateToExpected: updateStateToExpected,
            file: file, line: line
        )
    }
    
    private func assert(
        sut: SUT? = nil,
        _ event: Event,
        on state: State,
        updateStateToExpected: UpdateStateToExpected<State>? = nil,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let sut = sut ?? makeSUT()
        
        _assertState(
            sut,
            event,
            on: state,
            updateStateToExpected: updateStateToExpected,
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
        assert(sut: sut, event, on: .init(userPaymentSettings: settings), effect: expectedEffect, file: file, line: line)
    }
    
    private func assert(
        sut: SUT? = nil,
        _ event: Event,
        on state: State,
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
