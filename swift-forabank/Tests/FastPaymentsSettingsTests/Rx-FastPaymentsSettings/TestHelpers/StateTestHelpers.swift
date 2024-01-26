//
//  StateTestHelpers.swift
//
//
//  Created by Igor Malyarov on 20.01.2024.
//

import FastPaymentsSettings
import Foundation

func activeContractSettings(
) -> UserPaymentSettingsResult {
    
    .success(.contracted(contractDetails(
        paymentContract: paymentContract(
            contractStatus: .active
        )
    )))
}

func activePaymentContract(
    _ contractID: UserPaymentSettings.PaymentContract.ContractID = .init(generateRandom11DigitNumber()),
    _ productID: Product.ID = .init(generateRandom11DigitNumber())
) -> UserPaymentSettings.PaymentContract {
    
    .init(id: contractID, productID: productID, contractStatus: .active)
}

func connectivityError(
    status: FastPaymentsSettingsState.Status? = nil
) -> (
    settings: UserPaymentSettingsResult,
    state: FastPaymentsSettingsState
) {
    let settings: UserPaymentSettingsResult = .failure(.connectivityError)
    
    let state = FastPaymentsSettingsState(
        userPaymentSettings: settings,
        status: status
    )
    
    return (settings, state)
}

func connectivityErrorFPSState(
    status: FastPaymentsSettingsState.Status? = nil
) -> FastPaymentsSettingsState {
    
    .init(
        userPaymentSettings: .failure(.connectivityError),
        status: status
    )
}

func consentError(
) -> ConsentListFailure {
    
    .collapsedError
}

func consentList(
) -> ConsentList {
    
    .init(
        banks: .preview,
        consent: .preview,
        mode: .collapsed,
        searchText: ""
    )
}

func consentListFailure(
    _ error: ConsentListFailure = consentError()
) -> ConsentListState {
    
    .failure(error)
}

func consentListSuccess(
    _ consentList: ConsentList = consentList()
) -> ConsentListState {
    
    .success(consentList)
}

func contractDetails(
    paymentContract: UserPaymentSettings.PaymentContract = paymentContract(),
    consentList: ConsentListState = .success(consentList()),
    bankDefault: UserPaymentSettings.BankDefault = .offEnabled,
    productSelector: UserPaymentSettings.ProductSelector = makeProductSelector()
) -> UserPaymentSettings.ContractDetails {
    
    .init(
        paymentContract: paymentContract,
        consentList: consentList,
        bankDefault: bankDefault,
        productSelector: productSelector
    )
}

func contractedSettings(
    _ details: UserPaymentSettings.ContractDetails = contractDetails()
) -> UserPaymentSettingsResult {
    
    .success(.contracted(details))
}

func contractedState(
    _ contractStatus: UserPaymentSettings.PaymentContract.ContractStatus,
    bankDefault: UserPaymentSettings.BankDefault = .offEnabled,
    selectedProduct: Product = makeProduct(),
    selector selectorStatus: UserPaymentSettings.ProductSelector.Status = .collapsed,
    status: FastPaymentsSettingsState.Status? = nil
) -> (
    details: UserPaymentSettings.ContractDetails,
    state: FastPaymentsSettingsState
) {
    let details = contractDetails(
        paymentContract: paymentContract(
            contractStatus: contractStatus
        ),
        bankDefault: bankDefault,
        productSelector: makeProductSelector(
            selected: selectedProduct,
            status: selectorStatus
        )
    )
    
    let state = fastPaymentsSettingsState(
        .success(.contracted(details)),
        status: status
    )
    
    return (details, state)
}

func contractedState(
    _ contractStatus: UserPaymentSettings.PaymentContract.ContractStatus,
    bankDefault: UserPaymentSettings.BankDefault = .offEnabled,
    productSelector: UserPaymentSettings.ProductSelector,
    status: FastPaymentsSettingsState.Status? = nil
) -> (
    details: UserPaymentSettings.ContractDetails,
    state: FastPaymentsSettingsState
) {
    let details = contractDetails(
        paymentContract: paymentContract(
            contractStatus: contractStatus
        ),
        bankDefault: bankDefault,
        productSelector: productSelector
    )
    
    let state = fastPaymentsSettingsState(
        .success(.contracted(details)),
        status: status
    )
    
    return (details, state)
}

func fastPaymentsSettingsState(
    _ userPaymentSettings: UserPaymentSettingsResult? = nil,
    status: FastPaymentsSettingsState.Status? = nil
) -> FastPaymentsSettingsState {
    
    .init(
        userPaymentSettings: userPaymentSettings,
        status: status
    )
}

func inactiveContractSettings(
) -> UserPaymentSettingsResult {
    
    .success(.contracted(contractDetails(
        paymentContract: paymentContract(
            contractStatus: .inactive
        )
    )))
}

func makeProductSelector(
    selected: Product = makeProduct(),
    products: [Product]? = nil,
    status: UserPaymentSettings.ProductSelector.Status = .collapsed
) -> UserPaymentSettings.ProductSelector {
    
    .init(
        selectedProduct: selected,
        products: products ?? [selected],
        status: status
    )
}

func missingContract(
    _ result: ConsentListState
) -> UserPaymentSettingsResult {
    
    .success(.missingContract(result))
}

func missingConsentFailureSettings(
) -> UserPaymentSettingsResult {
    
    .success(.missingContract(.failure(.collapsedError)))
}

func missingConsentSuccessSettings(
) -> UserPaymentSettingsResult {
    
    .success(.missingContract(.success(consentList())))
}

func missingConsentSuccessFPSState(
    _ consentList: ConsentList = consentList(),
    status: FastPaymentsSettingsState.Status? = nil
) -> FastPaymentsSettingsState {
    
    fastPaymentsSettingsState(
        .success(.missingContract(.success(consentList))),
        status: status
    )
}

func paymentContract(
    _ contractID: UserPaymentSettings.PaymentContract.ContractID = .init(generateRandom11DigitNumber()),
    productID: Product.ID = .init(generateRandom11DigitNumber()),
    contractStatus: UserPaymentSettings.PaymentContract.ContractStatus = .active
) -> UserPaymentSettings.PaymentContract {
    
    .init(
        id: contractID,
        productID: productID,
        contractStatus: contractStatus
    )
}

func serverError(
    status: FastPaymentsSettingsState.Status? = nil
) -> (
    settings: UserPaymentSettingsResult,
    state: FastPaymentsSettingsState
) {
    let settings: UserPaymentSettingsResult = .failure(.serverError(UUID().uuidString))
    
    let state = FastPaymentsSettingsState(
        userPaymentSettings: settings,
        status: status
    )
    
    return (settings, state)
}

func serverErrorFPSState(
    status: FastPaymentsSettingsState.Status? = nil
) -> FastPaymentsSettingsState {
    
    .init(
        userPaymentSettings: .failure(.serverError(UUID().uuidString)),
        status: status
    )
}

func serverErrorSettings(
) -> UserPaymentSettingsResult {
    
    .failure(.serverError(UUID().uuidString))
}
