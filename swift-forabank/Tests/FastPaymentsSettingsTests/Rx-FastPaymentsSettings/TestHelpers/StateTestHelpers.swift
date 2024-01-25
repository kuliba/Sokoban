//
//  StateTestHelpers.swift
//
//
//  Created by Igor Malyarov on 20.01.2024.
//

import FastPaymentsSettings
import Foundation

func activeContractSettings(
) -> UserPaymentSettings {
    
    .contracted(contractDetails(
        paymentContract: paymentContract(
            contractStatus: .active
        )
    ))
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
    settings: UserPaymentSettings,
    state: FastPaymentsSettingsState
) {
    let settings: UserPaymentSettings = .failure(.connectivityError)
    
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
) -> UserPaymentSettings {
    
    .contracted(details)
}

func contractedSettings(
    _ contractStatus: UserPaymentSettings.PaymentContract.ContractStatus,
    bankDefault: UserPaymentSettings.BankDefault = .offEnabled
) -> UserPaymentSettings {
    
    let details = contractDetails(
        paymentContract: paymentContract(
            contractStatus: contractStatus
        ),
        bankDefault: bankDefault
    )
    
    return .contracted(details)
}

func contractedState(
    _ contractStatus: UserPaymentSettings.PaymentContract.ContractStatus,
    bankDefault: UserPaymentSettings.BankDefault = .offEnabled,
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
            status: selectorStatus
        )
    )
    
    let state = fastPaymentsSettingsState(
        .contracted(details),
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
        .contracted(details),
        status: status
    )
    
    return (details, state)
}

func fastPaymentsSettingsState(
    _ userPaymentSettings: UserPaymentSettings? = nil,
    status: FastPaymentsSettingsState.Status? = nil
) -> FastPaymentsSettingsState {
    
    .init(
        userPaymentSettings: userPaymentSettings,
        status: status
    )
}

func inactiveContractSettings(
) -> UserPaymentSettings {
    
    .contracted(contractDetails(
        paymentContract: paymentContract(
            contractStatus: .inactive
        )
    ))
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
) -> UserPaymentSettings {
    
    .missingContract(result)
}

func missingConsentFailureSettings(
) -> UserPaymentSettings {
    
    .missingContract(.failure(.collapsedError))
}

func missingConsentSuccessSettings(
) -> UserPaymentSettings {
    
    .missingContract(.success(consentList()))
}

func missingConsentSuccessFPSState(
    _ consentList: ConsentList = consentList(),
    status: FastPaymentsSettingsState.Status? = nil
) -> FastPaymentsSettingsState {
    
    fastPaymentsSettingsState(
        .missingContract(.success(consentList)),
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
    settings: UserPaymentSettings,
    state: FastPaymentsSettingsState
) {
    let settings: UserPaymentSettings = .failure(.serverError(UUID().uuidString))
    
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
) -> UserPaymentSettings {
    
    .failure(.serverError(UUID().uuidString))
}
