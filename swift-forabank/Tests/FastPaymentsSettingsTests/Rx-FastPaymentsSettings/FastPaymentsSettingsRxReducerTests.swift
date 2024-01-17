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
    
    // MARK: - loadedSettings
    
    func test_loadedSettings_shouldSetStateToSettingsWithoutStatus_emptyState() {
        
        let state = fastPaymentsSettingsState(status: .inflight)
        let loaded = contractedSettings()
        
        assert(state, .loadedSettings(loaded), reducedTo: .init(
            userPaymentSettings: loaded,
            status: nil
        ))
    }
    
    func test_loadedSettings_shouldNotDeliverEffect_emptyState() {
        
        let state = fastPaymentsSettingsState(status: .inflight)
        let loaded = contractedSettings()
        
        assert(state, .loadedSettings(loaded), effect: nil)
    }
    
    func test_loadedSettings_shouldSetStateToLoadedSettingsWithoutStatus_nonEmptyState() {
        
        let contracted = contractedSettings()
        let loaded = contractedSettings()
        let state = fastPaymentsSettingsState(contracted, status: .inflight)
        
        assert(state, .loadedSettings(loaded), reducedTo: .init(
            userPaymentSettings: loaded,
            status: nil
        ))
    }
    
    func test_loadedSettings_shouldNotDeliverEffect_nonEmptyState() {
        
        let contracted = contractedSettings()
        let loaded = contractedSettings()
        let state = fastPaymentsSettingsState(contracted, status: .inflight)
        
        assert(state, .loadedSettings(loaded), effect: nil)
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
        
        let (details, active) = contractedState(.active, isSelectorExpanded: true)
        
        assert(active, .collapseProducts, reducedTo: .init(
            userPaymentSettings: .contracted(details.updated(
                productSelector: details.productSelector.updated(
                    isExpanded: false
                )
            ))
        ))
    }
    
    func test_collapseProducts_shouldNotChangeStateOnActive_collapsed() {
        
        let active = contractedState(.active, isSelectorExpanded: false).state
        
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
    
    // MARK: - contractUpdate
    
    func test_contractUpdate_shouldSetContractOnSuccess_active() {
        
        let (details, activeContract) = contractedState(.active)
        let newContract = paymentContract()
        
        assert(
            activeContract,
            contractUpdateSuccess(newContract),
            reducedTo: .init(
                userPaymentSettings: .contracted(.init(
                    paymentContract: newContract,
                    consentResult: details.consentResult,
                    bankDefault: details.bankDefault,
                    productSelector: details.productSelector
                ))
            )
        )
    }
    
    func test_contractUpdate_shouldNotDeliverEffectOnSuccess_active() {
        
        let active = contractedState(.active).state
        
        assert(active, contractUpdateSuccess(), effect: nil)
    }
    
    func test_contractUpdate_shouldSetStatusToConnectivityErrorOnConnectivityFailure_active() {
        
        let (details, active) = contractedState(.active)
        let event = contractUpdateConnectivityError()
        
        assert(
            active,
            event,
            reducedTo: .init(
                userPaymentSettings: .contracted(details),
                status: .connectivityError
            )
        )
    }
    
    func test_contractUpdate_shouldNotDeliverEffectOnConnectivityFailure_active() {
        
        let active = contractedState(.active).state
        
        assert(active, contractUpdateConnectivityError(), effect: nil)
    }
    
    func test_contractUpdate_shouldSetStatusToServerErrorOnServerErrorFailure_active() {
        
        let message = anyMessage()
        let (details, active) = contractedState(.active)
        
        assert(
            active,
            contractUpdateServerError(message),
            reducedTo: .init(
                userPaymentSettings: .contracted(details),
                status: .serverError(message)
            )
        )
    }
    
    func test_contractUpdate_shouldNotDeliverEffectOnServerErrorFailure_active() {
        
        let active = contractedState(.active).state
        
        assert(active, contractUpdateServerError(), effect: nil)
    }
    
    func test_contractUpdate_shouldSetContractOnSuccess_inactive() {
        
        let (details, inactive) = contractedState(.inactive)
        let newContract = paymentContract()
        
        assert(
            inactive,
            contractUpdateSuccess(newContract),
            reducedTo: .init(
                userPaymentSettings: .contracted(.init(
                    paymentContract: newContract,
                    consentResult: details.consentResult,
                    bankDefault: details.bankDefault,
                    productSelector: details.productSelector
                ))
            )
        )
    }
    
    func test_contractUpdate_shouldNotDeliverEffectOnSuccess_inactive() {
        
        let inactive = contractedState(.inactive).state
        
        assert(inactive, contractUpdateSuccess(), effect: nil)
    }
    
    func test_contractUpdate_shouldSetStatusToConnectivityErrorOnConnectivityFailure_inactive() {
        
        let (details, inactive) = contractedState(.inactive)
        
        assert(
            inactive,
            contractUpdateConnectivityError(),
            reducedTo: .init(
                userPaymentSettings: .contracted(details),
                status: .connectivityError
            )
        )
    }
    
    func test_contractUpdate_shouldNotDeliverEffectOnConnectivityFailure_inactive() {
        
        let inactive = contractedState(.inactive).state
        
        assert(inactive, contractUpdateConnectivityError(), effect: nil)
    }
    
    func test_contractUpdate_shouldSetStatusToServerErrorOnServerErrorFailure_inactive() {
        
        let message = anyMessage()
        let (details, inactive) = contractedState(.inactive)
        
        assert(
            inactive,
            contractUpdateServerError(message),
            reducedTo: .init(
                userPaymentSettings: .contracted(details),
                status: .serverError(message)
            )
        )
    }
    
    func test_contractUpdate_shouldNotDeliverEffectOnServerErrorFailure_inactive() {
        
        let inactive = contractedState(.inactive).state
        
        assert(inactive, contractUpdateServerError(), effect: nil)
    }
    
    func test_contractUpdate_shouldSetContractOnSuccess_missing() {
        
        let consentResult = consentResultFailure()
        let missing = missingContract(consentResult)
        let (product1, product2) = (makeProduct(), makeProduct())
        let newContract = paymentContract(productID: product2.id)
        let sut = makeSUT(products: [product1, product2])
        
        assert(
            sut: sut,
            missing,
            contractUpdateSuccess(newContract),
            reducedTo: .init(
                userPaymentSettings: .contracted(.init(
                    paymentContract: newContract,
                    consentResult: consentResult,
                    bankDefault: .offEnabled,
                    productSelector: .init(
                        selectedProduct: product2,
                        products: [product1, product2]
                    )
                ))
            )
        )
    }
    
    func test_contractUpdate_shouldSetContractAndSelectorWithoutSelectedProductOnSuccessAndMissingProduct_missing() {
        
        let consentResult = consentResultFailure()
        let missing = missingContract(consentResult)
        let (product1, product2) = (makeProduct(), makeProduct())
        let newContract = paymentContract(productID: product2.id)
        let sut = makeSUT(products: [product1])
        
        assert(
            sut: sut,
            missing,
            contractUpdateSuccess(newContract),
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
    
    func test_contractUpdate_shouldNotDeliverEffectOnSuccess_missing() {
        
        let missing = missingConsentSuccessSettings()
        
        assert(missing, contractUpdateSuccess(), effect: nil)
    }
    
    func test_contractUpdate_shouldSetStatusToConnectivityErrorOnConnectivityFailure_missing() {
        
        let missing = missingConsentFailureSettings()
        let product = makeProduct()
        let sut = makeSUT(products: [product])
        let event = contractUpdateConnectivityError()
        
        assert(
            sut: sut, missing, event,
            reducedTo: .init(
                userPaymentSettings: missing,
                status: .connectivityError
            )
        )
    }
    
    func test_contractUpdate_shouldNotDeliverEffectOnConnectivityFailure_missing() {
        
        let missing = missingConsentSuccessSettings()
        
        assert(missing, contractUpdateConnectivityError(), effect: nil)
    }
    
    func test_contractUpdate_shouldSetStatusToServerErrorOnServerErrorFailure_missing() {
        
        let message = anyMessage()
        let missing = missingConsentFailureSettings()
        let product = makeProduct()
        let sut = makeSUT(products: [product])
        let event = contractUpdateServerError(message)
        
        assert(
            sut: sut, missing, event,
            reducedTo: .init(
                userPaymentSettings: missing,
                status: .serverError(message)
            )
        )
    }
    
    func test_contractUpdate_shouldNotDeliverEffectOnServerErrorFailure_missing() {
        
        let missing = missingConsentSuccessSettings()
        
        assert(missing, contractUpdateServerError(), effect: nil)
    }
    
    func test_contractUpdate_shouldNotChangeStateOnSuccess_connectivityError() {
        
        let connectivityError = connectivityErrorFPSState()
        
        assert(connectivityError, contractUpdateSuccess(), reducedTo: connectivityError)
    }
    
    func test_contractUpdate_shouldNotDeliverEffectOnSuccess_connectivityError() {
        
        let connectivityError = connectivityErrorFPSState()
        
        assert(connectivityError, contractUpdateSuccess(), effect: nil)
    }
    
    func test_contractUpdate_shouldNotChangeStateOnConnectivityFailure_connectivityError() {
        
        let connectivityError = connectivityErrorFPSState()
        
        assert(connectivityError, contractUpdateConnectivityError(), reducedTo: connectivityError)
    }
    
    func test_contractUpdate_shouldNotDeliverEffectOnConnectivityFailure_connectivityError() {
        
        let connectivityError = connectivityErrorFPSState()
        
        assert(connectivityError, contractUpdateConnectivityError(), effect: nil)
    }
    
    func test_contractUpdate_shouldNotChangeStateOnServerErrorFailure_connectivityError() {
        
        let connectivityError = connectivityErrorFPSState()
        
        assert(connectivityError, contractUpdateServerError(), reducedTo: connectivityError)
    }
    
    func test_contractUpdate_shouldNotDeliverEffectOnServerErrorFailure_connectivityError() {
        
        let connectivityError = connectivityErrorFPSState()
        
        assert(connectivityError, contractUpdateServerError(), effect: nil)
    }
    
    func test_contractUpdate_shouldNotChangeStateOnSuccess_serverError() {
        
        let serverError = serverErrorFPSState()
        
        assert(serverError, contractUpdateSuccess(), reducedTo: serverError)
    }
    
    func test_contractUpdate_shouldNotDeliverEffectOnSuccess_serverError() {
        
        let serverError = serverErrorFPSState()
        
        assert(serverError, contractUpdateSuccess(), effect: nil)
    }
    
    func test_contractUpdate_shouldNotChangeStateOnConnectivityFailure_serverError() {
        
        let serverError = serverErrorFPSState()
        
        assert(serverError, contractUpdateConnectivityError(), reducedTo: serverError)
    }
    
    func test_contractUpdate_shouldNotDeliverEffectOnConnectivityFailure_serverError() {
        
        let serverError = serverErrorFPSState()
        
        assert(serverError, contractUpdateConnectivityError(), effect: nil)
    }
    
    func test_contractUpdate_shouldNotChangeStateOnServerErrorFailure_serverError() {
        
        let serverError = serverErrorFPSState()
        
        assert(serverError, contractUpdateServerError(), reducedTo: serverError)
    }
    
    func test_contractUpdate_shouldNotDeliverEffectOnServerErrorFailure_serverError() {
        
        let serverError = serverErrorFPSState()
        
        assert(serverError, contractUpdateServerError(), effect: nil)
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
        
        let (details, active) = contractedState(.active, isSelectorExpanded: false)
        
        assert(active, .expandProducts, reducedTo: .init(
            userPaymentSettings: .contracted(details.updated(
                productSelector: details.productSelector.updated(
                    isExpanded: true
                )
            ))
        ))
    }
    
    func test_expandProducts_shouldNotChangeStateOnActive_expanded() {
        
        let active = contractedState(.active, isSelectorExpanded: true).state
        
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
    
    // MARK: - productUpdate
    
    func test_productUpdate_shouldSetProductOnSuccess_active() {
        
        let newProduct = makeProduct()
        let (details, active) = contractedState(.active)
        
        assert(
            active,
            .productUpdate(.success(newProduct)),
            reducedTo: .init(
                userPaymentSettings: .contracted(.init(
                    paymentContract: details.paymentContract,
                    consentResult: details.consentResult,
                    bankDefault: details.bankDefault,
                    productSelector: details.productSelector.selected(product: newProduct)
                ))
            )
        )
    }
    
    func test_productUpdate_shouldNotDeliverEffectOnSuccess_active() {
        
        let active = contractedState(.active).state
        
        assert(active, productUpdateSuccess(), effect: nil)
    }
    
    func test_productUpdate_shouldSetStatusOnConnectivityErrorFailure_active() {
        
        let active = activeContractSettings()
        
        assert(
            active,
            productUpdateConnectivityError(),
            reducedTo: .init(
                userPaymentSettings: active,
                status: .connectivityError
            )
        )
    }
    
    func test_productUpdate_shouldNotDeliverEffectOnConnectivityErrorFailure_active() {
        
        let active = contractedState(.active).state
        
        assert(active, productUpdateConnectivityError(), effect: nil)
    }
    
    func test_productUpdate_shouldSetStatusOnServerErrorFailure_active() {
        
        let message = anyMessage()
        let active = activeContractSettings()
        
        assert(
            active,
            .productUpdate(.failure(.serverError(message))),
            reducedTo: .init(
                userPaymentSettings: active,
                status: .serverError(message)
            )
        )
    }
    
    func test_productUpdate_shouldNotDeliverEffectOnServerErrorFailure_active() {
        
        let active = contractedState(.active).state
        
        assert(active, productUpdateServerError(), effect: nil)
    }
    
    func test_productUpdate_shouldNotChangeStateOnSuccess_inactive() {
        
        let inactive = contractedState(.inactive).state
        
        assert(inactive, productUpdateSuccess(), reducedTo: inactive)
    }
    
    func test_productUpdate_shouldNotDeliverEffectOnSuccess_inactive() {
        
        let inactive = contractedState(.inactive).state
        
        assert(inactive, productUpdateSuccess(), effect: nil)
    }
    
    func test_productUpdate_shouldNotChangeStateOnConnectivityErrorFailure_inactive() {
        
        let inactive = contractedState(.inactive).state
        
        assert(inactive, productUpdateConnectivityError(), reducedTo: inactive)
    }
    
    func test_productUpdate_shouldNotDeliverEffectOnConnectivityErrorFailure_inactive() {
        
        let inactive = contractedState(.inactive).state
        
        assert(inactive, productUpdateConnectivityError(), effect: nil)
    }
    
    func test_productUpdate_shouldNotChangeStateOnServerErrorFailure_inactive() {
        
        let inactive = contractedState(.inactive).state
        
        assert(inactive, productUpdateServerError(), reducedTo: inactive)
    }
    
    func test_productUpdate_shouldNotDeliverEffectOnServerErrorFailure_inactive() {
        
        let inactive = contractedState(.inactive).state
        
        assert(inactive, productUpdateServerError(), effect: nil)
    }
    
    func test_productUpdate_shouldNotChangeStateOnSuccess_missing() {
        
        let missing = missingConsentSuccessFPSState()
        
        assert(missing, productUpdateSuccess(), reducedTo: missing)
    }
    
    func test_productUpdate_shouldNotDeliverEffectOnSuccess_missing() {
        
        let missing = missingConsentSuccessFPSState()
        
        assert(missing, productUpdateSuccess(), effect: nil)
    }
    
    func test_productUpdate_shouldNotChangeStateOnConnectivityErrorFailure_missing() {
        
        let missing = missingConsentSuccessFPSState()
        
        assert(missing, productUpdateConnectivityError(), reducedTo: missing)
    }
    
    func test_productUpdate_shouldNotDeliverEffectOnConnectivityErrorFailure_missing() {
        
        let missing = missingConsentSuccessFPSState()
        
        assert(missing, productUpdateConnectivityError(), effect: nil)
    }
    
    func test_productUpdate_shouldNotChangeStateOnServerErrorFailure_missing() {
        
        let missing = missingConsentSuccessFPSState()
        
        assert(missing, productUpdateServerError(), reducedTo: missing)
    }
    
    func test_productUpdate_shouldNotDeliverEffectOnServerErrorFailure_missing() {
        
        let missing = missingConsentSuccessFPSState()
        
        assert(missing, productUpdateServerError(), effect: nil)
    }
    
    func test_productUpdate_shouldNotChangeStateOnSuccess_connectivityError() {
        
        let connectivityError = connectivityErrorFPSState()
        
        assert(connectivityError, productUpdateSuccess(), reducedTo: connectivityError)
    }
    
    func test_productUpdate_shouldNotDeliverEffectOnSuccess_connectivityError() {
        
        let connectivityError = connectivityErrorFPSState()
        
        assert(connectivityError, productUpdateSuccess(), effect: nil)
    }
    
    func test_productUpdate_shouldNotChangeStateOnConnectivityErrorFailure_connectivityError() {
        
        let connectivityError = connectivityErrorFPSState()
        
        assert(connectivityError, productUpdateConnectivityError(), reducedTo: connectivityError)
    }
    
    func test_productUpdate_shouldNotDeliverEffectOnConnectivityErrorFailure_connectivityError() {
        
        let connectivityError = connectivityErrorFPSState()
        
        assert(connectivityError, productUpdateConnectivityError(), effect: nil)
    }
    
    func test_productUpdate_shouldNotChangeStateOnServerErrorFailure_connectivityError() {
        
        let connectivityError = connectivityErrorFPSState()
        
        assert(connectivityError, productUpdateServerError(), reducedTo: connectivityError)
    }
    
    func test_productUpdate_shouldNotDeliverEffectOnServerErrorFailure_connectivityError() {
        
        let connectivityError = connectivityErrorFPSState()
        
        assert(connectivityError, productUpdateServerError(), effect: nil)
    }
    
    func test_productUpdate_shouldNotChangeStateOnSuccess_serverError() {
        
        let serverError = serverErrorFPSState()
        
        assert(serverError, productUpdateSuccess(), reducedTo: serverError)
    }
    
    func test_productUpdate_shouldNotDeliverEffectOnSuccess_serverError() {
        
        let serverError = serverErrorFPSState()
        
        assert(serverError, productUpdateSuccess(), effect: nil)
    }
    
    func test_productUpdate_shouldNotChangeStateOnConnectivityErrorFailure_serverError() {
        
        let serverError = serverErrorFPSState()
        
        assert(serverError, productUpdateConnectivityError(), reducedTo: serverError)
    }
    
    func test_productUpdate_shouldNotDeliverEffectOnConnectivityErrorFailure_serverError() {
        
        let serverError = serverErrorFPSState()
        
        assert(serverError, productUpdateConnectivityError(), effect: nil)
    }
    
    func test_productUpdate_shouldNotChangeStateOnServerErrorFailure_serverError() {
        
        let serverError = serverErrorFPSState()
        
        assert(serverError, productUpdateServerError(), reducedTo: serverError)
    }
    
    func test_productUpdate_shouldNotDeliverEffectOnServerErrorFailure_serverError() {
        
        let serverError = serverErrorFPSState()
        
        assert(serverError, productUpdateServerError(), effect: nil)
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
    
    // MARK: - setBankDefaultPrepare
    
    func test_setBankDefaultPrepare_shouldSetBankDefaultAndInformerOnSuccess_active() {
        
        let (details, active) = contractedState(.active)
        
        assert(
            active,
            .setBankDefaultPrepare(nil),
            reducedTo: .init(
                userPaymentSettings: .contracted(.init(
                    paymentContract: details.paymentContract,
                    consentResult: details.consentResult,
                    bankDefault: .onDisabled,
                    productSelector: details.productSelector
                )),
                status: .setBankDefaultSuccess
            )
        )
    }
    
    func test_setBankDefaultPrepare_shouldNotDeliverEffectOnSuccess_active() {
        
        let active = contractedState(.active).state
        
        assert(active, .setBankDefaultPrepare(nil), effect: nil)
    }
    
    func test_setBankDefaultPrepare_shouldSetStatusOnConnectivityErrorFailure_active() {
        
        let active = activeContractSettings()
        
        assert(
            active,
            .setBankDefaultPrepare(.connectivityError),
            reducedTo: .init(
                userPaymentSettings: active,
                status: .connectivityError
            )
        )
    }
    
    func test_setBankDefaultPrepare_shouldNotDeliverEffectOnConnectivityErrorFailure_active() {
        
        let active = activeContractSettings()
        
        assert(active, .setBankDefaultPrepare(.connectivityError), effect: nil)
    }
    
    func test_setBankDefaultPrepare_shouldSetStatusOnServerErrorFailure_active() {
        
        let message = anyMessage()
        let active = activeContractSettings()
        
        assert(
            active,
            .setBankDefaultPrepare(.serverError(message)),
            reducedTo: .init(
                userPaymentSettings: active,
                status: .serverError(message)
            )
        )
    }
    
    func test_setBankDefaultPrepare_shouldNotDeliverEffectOnServerErrorFailure_active() {
        
        let active = activeContractSettings()
        
        assert(active, setBankDefaultPrepareServerError(), effect: nil)
    }
    
    func test_setBankDefaultPrepare_shouldNotChangeStateOnSuccess_inactive() {
        
        let inactive = contractedState(.inactive).state
        
        assert(inactive, .setBankDefaultPrepare(nil), reducedTo: inactive)
    }
    
    func test_setBankDefaultPrepare_shouldNotDeliverEffectOnSuccess_inactive() {
        
        let inactive = contractedState(.inactive).state
        
        assert(inactive, .setBankDefaultPrepare(nil), effect: nil)
    }
    
    func test_setBankDefaultPrepare_shouldNotChangeStateOnConnectivityErrorFailure_inactive() {
        
        let inactive = contractedState(.inactive).state
        
        assert(inactive, .setBankDefaultPrepare(.connectivityError), reducedTo: inactive)
    }
    
    func test_setBankDefaultPrepare_shouldNotDeliverEffectOnConnectivityErrorFailure_inactive() {
        
        let inactive = contractedState(.inactive).state
        
        assert(inactive, .setBankDefaultPrepare(.connectivityError), effect: nil)
    }
    
    func test_setBankDefaultPrepare_shouldNotChangeStateOnServerErrorFailure_inactive() {
        
        let inactive = contractedState(.inactive).state
        
        assert(inactive, setBankDefaultPrepareServerError(), reducedTo: inactive)
    }
    
    func test_setBankDefaultPrepare_shouldNotDeliverEffectOnServerErrorFailure_inactive() {
        
        let inactive = contractedState(.inactive).state
        
        assert(inactive, setBankDefaultPrepareServerError(), effect: nil)
    }
    
    func test_setBankDefaultPrepare_shouldNotChangeStateOnSuccess_missing() {
        
        let missing = missingConsentSuccessFPSState()
        
        assert(missing, .setBankDefaultPrepare(nil), reducedTo: missing)
    }
    
    func test_setBankDefaultPrepare_shouldNotDeliverEffectOnSuccess_missing() {
        
        let missing = missingConsentSuccessFPSState()
        
        assert(missing, .setBankDefaultPrepare(nil), effect: nil)
    }
    
    func test_setBankDefaultPrepare_shouldNotChangeStateOnConnectivityErrorFailure_missing() {
        
        let missing = missingConsentSuccessFPSState()
        
        assert(missing, .setBankDefaultPrepare(.connectivityError), reducedTo: missing)
    }
    
    func test_setBankDefaultPrepare_shouldNotDeliverEffectOnConnectivityErrorFailure_missing() {
        
        let missing = missingConsentSuccessFPSState()
        
        assert(missing, .setBankDefaultPrepare(.connectivityError), effect: nil)
    }
    
    func test_setBankDefaultPrepare_shouldNotChangeStateOnServerErrorFailure_missing() {
        
        let missing = missingConsentSuccessFPSState()
        
        assert(missing, setBankDefaultPrepareServerError(), reducedTo: missing)
    }
    
    func test_setBankDefaultPrepare_shouldNotDeliverEffectOnServerErrorFailure_missing() {
        
        let missing = missingConsentSuccessFPSState()
        
        assert(missing, setBankDefaultPrepareServerError(), effect: nil)
    }
    
    func test_setBankDefaultPrepare_shouldNotChangeStateOnSuccess_connectivityError() {
        
        let connectivityError = connectivityErrorFPSState()
        
        assert(connectivityError, .setBankDefaultPrepare(nil), reducedTo: connectivityError)
    }
    
    func test_setBankDefaultPrepare_shouldNotDeliverEffectOnSuccess_connectivityError() {
        
        let connectivityError = connectivityErrorFPSState()
        
        assert(connectivityError, .setBankDefaultPrepare(nil), effect: nil)
    }
    
    func test_setBankDefaultPrepare_shouldNotChangeStateOnConnectivityErrorFailure_connectivityError() {
        
        let connectivityError = connectivityErrorFPSState()
        
        assert(connectivityError, .setBankDefaultPrepare(.connectivityError), reducedTo: connectivityError)
    }
    
    func test_setBankDefaultPrepare_shouldNotDeliverEffectOnConnectivityErrorFailure_connectivityError() {
        
        let connectivityError = connectivityErrorFPSState()
        
        assert(connectivityError, .setBankDefaultPrepare(.connectivityError), effect: nil)
    }
    
    func test_setBankDefaultPrepare_shouldNotChangeStateOnServerErrorFailure_connectivityError() {
        
        let connectivityError = connectivityErrorFPSState()
        
        assert(connectivityError, setBankDefaultPrepareServerError(), reducedTo: connectivityError)
    }
    
    func test_setBankDefaultPrepare_shouldNotDeliverEffectOnServerErrorFailure_connectivityError() {
        
        let connectivityError = connectivityErrorFPSState()
        
        assert(connectivityError, setBankDefaultPrepareServerError(), effect: nil)
    }
    
    func test_setBankDefaultPrepare_shouldNotChangeStateOnSuccess_serverError() {
        
        let serverError = serverErrorFPSState()
        
        assert(serverError, .setBankDefaultPrepare(nil), reducedTo: serverError)
    }
    
    func test_setBankDefaultPrepare_shouldNotDeliverEffectOnSuccess_serverError() {
        
        let serverError = serverErrorFPSState()
        
        assert(serverError, .setBankDefaultPrepare(nil), effect: nil)
    }
    
    func test_setBankDefaultPrepare_shouldNotChangeStateOnConnectivityErrorFailure_serverError() {
        
        let serverError = serverErrorFPSState()
        
        assert(serverError, .setBankDefaultPrepare(.connectivityError), reducedTo: serverError)
    }
    
    func test_setBankDefaultPrepare_shouldNotDeliverEffectOnConnectivityErrorFailure_serverError() {
        
        let serverError = serverErrorFPSState()
        
        assert(serverError, .setBankDefaultPrepare(.connectivityError), effect: nil)
    }
    
    func test_setBankDefaultPrepare_shouldNotChangeStateOnServerErrorFailure_serverError() {
        
        let serverError = serverErrorFPSState()
        
        assert(serverError, setBankDefaultPrepareServerError(), reducedTo: serverError)
    }
    
    func test_setBankDefaultPrepare_shouldNotDeliverEffectOnServerErrorFailure_serverError() {
        
        let serverError = serverErrorFPSState()
        
        assert(serverError, setBankDefaultPrepareServerError(), effect: nil)
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
        isExpanded: Bool? = nil
    ) -> Self {
        
        .init(
            selectedProduct: selectedProduct ?? self.selectedProduct,
            products: products ?? self.products,
            isExpanded: isExpanded ?? self.isExpanded
        )
    }
}
