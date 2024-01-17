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
        
        let active = contractedFastPaymentsSettingsState(.active).state
        
        assert(active, .activateContract, reducedTo: active)
    }
    
    func test_activateContract_shouldNotDeliverEffectOnActiveContract() {
        
        let active = contractedFastPaymentsSettingsState(.active).state
        
        assert(active, .activateContract, effect: nil)
    }
    
    func test_activateContract_shouldChangeStatusToInflightOnInactiveContract() {
        
        let inactive = inactiveContractSettings()
        
        assert(inactive, .activateContract, reducedTo: .init(
            userPaymentSettings: inactive,
            status: .inflight
        ))
    }
    
    func test_activateContract_shouldDeliverEffectOnInactiveContract() {
        
        let (details, inactive) = contractedFastPaymentsSettingsState(.inactive)
        let target = target(details, .active)
        
        assert(inactive, .activateContract, effect: .activateContract(target))
    }
    
    func test_activateContract_shouldChangeStatusToMissingProductOnMissingProductAtMissingSettingsWithConsentFailure() {
        
        let missing = missingConsentFailureSettings()
        let sut = makeSUT(product: nil)
        
        assert(sut: sut, missing, .activateContract, reducedTo: .init(
            userPaymentSettings: missing,
            status: .missingProduct
        ))
    }
    
    func test_activateContract_shouldNotDeliverEffectOnMissingProductAtMissingSettingsWithConsentFailure() {
        
        let missing = missingConsentFailureSettings()
        let sut = makeSUT(product: nil)
        
        assert(sut: sut, missing, .activateContract, effect: nil)
    }
    
    func test_activateContract_shouldChangeStatusToInflightOnAvailableProductAtMissingSettingsWithConsentFailure() {
        
        let missing = missingConsentFailureSettings()
        let sut = makeSUT(product: makeProduct())
        
        assert(sut: sut, missing, .activateContract, reducedTo: .init(
            userPaymentSettings: missing,
            status: .inflight
        ))
    }
    
    func test_activateContract_shouldDeliverEffectOnAvailableProductAtMissingSettingsWithConsentFailure() {
        
        let missing = missingConsentFailureSettings()
        let product = makeProduct()
        let sut = makeSUT(product: product)
        
        assert(sut: sut, missing, .activateContract, effect: .createContract(.init(product.id.rawValue)))
    }
    
    func test_activateContract_shouldChangeStatusToMissingProductOnMissingProductAtMissingSettingsWithConsentSuccess() {
        
        let missing = missingConsentSuccessSettings()
        let sut = makeSUT(product: nil)
        
        assert(sut: sut, missing, .activateContract, reducedTo: .init(
            userPaymentSettings: missing,
            status: .missingProduct
        ))
    }
    
    func test_activateContract_shouldNotDeliverEffectOnMissingProductAtMissingSettingsWithConsentSuccess() {
        
        let missing = missingConsentSuccessSettings()
        let sut = makeSUT(product: nil)
        
        assert(sut: sut, missing, .activateContract, effect: nil)
    }
    
    func test_activateContract_shouldChangeStatusToInflightOnAvailableProductAtMissingSettingsWithConsentSuccess() {
        
        let missing = missingConsentSuccessSettings()
        let sut = makeSUT(product: makeProduct())
        
        assert(sut: sut, missing, .activateContract, reducedTo: .init(
            userPaymentSettings: missing,
            status: .inflight
        ))
    }
    
    func test_activateContract_shouldDeliverEffectOnAvailableProductAtMissingSettingsWithConsentSuccess() {
        
        let missing = missingConsentSuccessSettings()
        let product = makeProduct()
        let sut = makeSUT(product: product)
        
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
    
    // MARK: - contractUpdate
    
    func test_contractUpdate_shouldSetContractOnSuccess_active() {
        
        let (details, activeContract) = contractedFastPaymentsSettingsState(.active)
        let newContract = paymentContract()
        
        assert(
            activeContract,
            contractUpdateSuccess(newContract),
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
        
        let active = contractedFastPaymentsSettingsState(.active).state
        
        assert(active, contractUpdateSuccess(), effect: nil)
    }
    
    func test_contractUpdate_shouldSetStatusToConnectivityErrorOnConnectivityFailure_active() {
        
        let (details, active) = contractedFastPaymentsSettingsState(.active)
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
        
        let active = contractedFastPaymentsSettingsState(.active).state
        
        assert(active, contractUpdateConnectivityError(), effect: nil)
    }
    
    func test_contractUpdate_shouldSetStatusToServerErrorOnServerErrorFailure_active() {
        
        let message = anyMessage()
        let (details, active) = contractedFastPaymentsSettingsState(.active)
        
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
        
        let active = contractedFastPaymentsSettingsState(.active).state
        
        assert(active, contractUpdateServerError(), effect: nil)
    }
    
    func test_contractUpdate_shouldSetContractOnSuccess_inactive() {
        
        let (details, inactive) = contractedFastPaymentsSettingsState(.inactive)
        let newContract = paymentContract()
        
        assert(
            inactive,
            contractUpdateSuccess(newContract),
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
        
        let inactive = contractedFastPaymentsSettingsState(.inactive).state
        
        assert(inactive, contractUpdateSuccess(), effect: nil)
    }
    
    func test_contractUpdate_shouldSetStatusToConnectivityErrorOnConnectivityFailure_inactive() {
        
        let (details, inactive) = contractedFastPaymentsSettingsState(.inactive)
        
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
        
        let inactive = contractedFastPaymentsSettingsState(.inactive).state

        assert(inactive, contractUpdateConnectivityError(), effect: nil)
    }
    
    func test_contractUpdate_shouldSetStatusToServerErrorOnServerErrorFailure_inactive() {
        
        let message = anyMessage()
        let (details, inactive) = contractedFastPaymentsSettingsState(.inactive)
        
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
        
        let inactive = contractedFastPaymentsSettingsState(.inactive).state
        
        assert(inactive, contractUpdateServerError(), effect: nil)
    }
    
    func test_contractUpdate_shouldSetContractOnSuccess_missing() {
        
        let newContract = paymentContract()
        let consentResult: UserPaymentSettings.ConsentResult = .failure(.init())
        let missing: UserPaymentSettings = .missingContract(consentResult)
        let product = makeProduct()
        let sut = makeSUT(product: product)
        
        assert(
            sut: sut,
            missing,
            contractUpdateSuccess(newContract),
            reducedTo: .init(
                userPaymentSettings: .contracted(.init(
                    paymentContract: newContract,
                    consentResult: consentResult,
                    bankDefault: .offEnabled,
                    product: product
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
        let sut = makeSUT(product: product)
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
        let sut = makeSUT(product: product)
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
    
    func test_deactivateContract_shouldDeliverEffectOnActive() {
        
        let (details, active) = contractedFastPaymentsSettingsState(.active)
        let target = target(details, .inactive)
        
        assert(active, .deactivateContract, effect: .deactivateContract(target))
    }
    
    func test_deactivateContract_shouldNotChangeStateOnInactive() {
        
        let inactive = contractedFastPaymentsSettingsState(.inactive).state
        
        assert(inactive, .deactivateContract, reducedTo: inactive)
    }
    
    func test_deactivateContract_shouldNotDeliverEffectOnInactive() {
        
        let inactive = contractedFastPaymentsSettingsState(.inactive).state
        
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
    
    // MARK: - productUpdate
    
    func test_productUpdate_shouldSetProductOnSuccess_active() {
        
        let newProduct = makeProduct()
        let (details, active) = contractedFastPaymentsSettingsState(.active)
        
        assert(
            active,
            .productUpdate(.success(newProduct)),
            reducedTo: .init(
                userPaymentSettings: .contracted(.init(
                    paymentContract: details.paymentContract,
                    consentResult: details.consentResult,
                    bankDefault: details.bankDefault,
                    product: newProduct
                ))
            )
        )
    }
    
    func test_productUpdate_shouldNotDeliverEffectOnSuccess_active() {
        
        let active = contractedFastPaymentsSettingsState(.active).state
        
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
        
        let active = contractedFastPaymentsSettingsState(.active).state
        
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
        
        let active = contractedFastPaymentsSettingsState(.active).state
        
        assert(active, productUpdateServerError(), effect: nil)
    }
    
    func test_productUpdate_shouldNotChangeStateOnSuccess_inactive() {
        
        let inactive = contractedFastPaymentsSettingsState(.inactive).state
        
        assert(inactive, productUpdateSuccess(), reducedTo: inactive)
    }
    
    func test_productUpdate_shouldNotDeliverEffectOnSuccess_inactive() {
        
        let inactive = contractedFastPaymentsSettingsState(.inactive).state
        
        assert(inactive, productUpdateSuccess(), effect: nil)
    }
    
    func test_productUpdate_shouldNotChangeStateOnConnectivityErrorFailure_inactive() {
        
        let inactive = contractedFastPaymentsSettingsState(.inactive).state
        
        assert(inactive, productUpdateConnectivityError(), reducedTo: inactive)
    }
    
    func test_productUpdate_shouldNotDeliverEffectOnConnectivityErrorFailure_inactive() {
        
        let inactive = contractedFastPaymentsSettingsState(.inactive).state
        
        assert(inactive, productUpdateConnectivityError(), effect: nil)
    }
    
    func test_productUpdate_shouldNotChangeStateOnServerErrorFailure_inactive() {
        
        let inactive = contractedFastPaymentsSettingsState(.inactive).state
        
        assert(inactive, productUpdateServerError(), reducedTo: inactive)
    }
    
    func test_productUpdate_shouldNotDeliverEffectOnServerErrorFailure_inactive() {
        
        let inactive = contractedFastPaymentsSettingsState(.inactive).state
        
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
    
    // MARK: - setBankDefaultPrepare
    
    func test_setBankDefaultPrepare_shouldSetBankDefaultAndInformerOnSuccess_active() {
        
        let (details, active) = contractedFastPaymentsSettingsState(.active)
        
        assert(
            active,
            .setBankDefaultPrepare(nil),
            reducedTo: .init(
                userPaymentSettings: .contracted(.init(
                    paymentContract: details.paymentContract,
                    consentResult: details.consentResult,
                    bankDefault: .onDisabled,
                    product: details.product
                )),
                status: .setBankDefaultSuccess
            )
        )
    }
    
    func test_setBankDefaultPrepare_shouldNotDeliverEffectOnSuccess_active() {
        
        let active = contractedFastPaymentsSettingsState(.active).state
        
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
        
        let inactive = contractedFastPaymentsSettingsState(.inactive).state
        
        assert(inactive, .setBankDefaultPrepare(nil), reducedTo: inactive)
    }
    
    func test_setBankDefaultPrepare_shouldNotDeliverEffectOnSuccess_inactive() {
        
        let inactive = contractedFastPaymentsSettingsState(.inactive).state
        
        assert(inactive, .setBankDefaultPrepare(nil), effect: nil)
    }
    
    func test_setBankDefaultPrepare_shouldNotChangeStateOnConnectivityErrorFailure_inactive() {
        
        let inactive = contractedFastPaymentsSettingsState(.inactive).state
        
        assert(inactive, .setBankDefaultPrepare(.connectivityError), reducedTo: inactive)
    }
    
    func test_setBankDefaultPrepare_shouldNotDeliverEffectOnConnectivityErrorFailure_inactive() {
        
        let inactive = contractedFastPaymentsSettingsState(.inactive).state
        
        assert(inactive, .setBankDefaultPrepare(.connectivityError), effect: nil)
    }
    
    func test_setBankDefaultPrepare_shouldNotChangeStateOnServerErrorFailure_inactive() {
        
        let inactive = contractedFastPaymentsSettingsState(.inactive).state
        
        assert(inactive, setBankDefaultPrepareServerError(), reducedTo: inactive)
    }
    
    func test_setBankDefaultPrepare_shouldNotDeliverEffectOnServerErrorFailure_inactive() {
        
        let inactive = contractedFastPaymentsSettingsState(.inactive).state
        
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
        
        let serverError = fastPaymentsSettingsState(serverErrorSettings())

        assert(serverError, .setBankDefaultPrepare(nil), reducedTo: serverError)
    }
    
    func test_setBankDefaultPrepare_shouldNotDeliverEffectOnSuccess_serverError() {
        
        let serverError = fastPaymentsSettingsState(serverErrorSettings())

        assert(serverError, .setBankDefaultPrepare(nil), effect: nil)
    }
    
    func test_setBankDefaultPrepare_shouldNotChangeStateOnConnectivityErrorFailure_serverError() {
        
        let serverError = fastPaymentsSettingsState(serverErrorSettings())

        assert(serverError, .setBankDefaultPrepare(.connectivityError), reducedTo: serverError)
    }
    
    func test_setBankDefaultPrepare_shouldNotDeliverEffectOnConnectivityErrorFailure_serverError() {
        
        let serverError = fastPaymentsSettingsState(serverErrorSettings())

        assert(serverError, .setBankDefaultPrepare(.connectivityError), effect: nil)
    }
    
    func test_setBankDefaultPrepare_shouldNotChangeStateOnServerErrorFailure_serverError() {
        
        let serverError = fastPaymentsSettingsState(serverErrorSettings())

        assert(serverError, setBankDefaultPrepareServerError(), reducedTo: serverError)
    }
    
    func test_setBankDefaultPrepare_shouldNotDeliverEffectOnServerErrorFailure_serverError() {
        
        let serverError = fastPaymentsSettingsState(serverErrorSettings())
        
        assert(serverError, setBankDefaultPrepareServerError(), effect: nil)
    }
    
    // MARK: - Helpers
    
    private typealias SUT = FastPaymentsSettingsRxReducer
    private typealias State = SUT.State
    private typealias Event = SUT.Event
    private typealias Effect = SUT.Effect
    
    private func makeSUT(
        product: Product? = makeProduct(),
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
            product: contractDetails.product
        )
    }
}
