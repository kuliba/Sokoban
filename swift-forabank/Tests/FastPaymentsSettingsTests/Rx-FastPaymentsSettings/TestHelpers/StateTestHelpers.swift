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

func bankDefault(
    _ bankDefault: UserPaymentSettings.GetBankDefaultResponse.BankDefault = .offEnabled,
    requestLimitMessage: String? = nil
) -> UserPaymentSettings.GetBankDefaultResponse {
    
    .init(bankDefault: bankDefault, requestLimitMessage: requestLimitMessage)
}

func connectivityError(
    status: FastPaymentsSettingsState.Status? = nil
) -> (
    settings: UserPaymentSettingsResult,
    state: FastPaymentsSettingsState
) {
    let settings: UserPaymentSettingsResult = .failure(.connectivityError)
    
    let state = FastPaymentsSettingsState(
        settingsResult: settings,
        status: status
    )
    
    return (settings, state)
}

func connectivityErrorFPSState(
    status: FastPaymentsSettingsState.Status? = nil
) -> FastPaymentsSettingsState {
    
    .init(
        settingsResult: .failure(.connectivityError),
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
    bankDefaultResponse: UserPaymentSettings.GetBankDefaultResponse = .init(bankDefault: .offEnabled),
    productSelector: UserPaymentSettings.ProductSelector = makeProductSelector()
) -> UserPaymentSettings.Details {
    
    .init(
        paymentContract: paymentContract,
        consentList: consentList,
        bankDefaultResponse: bankDefaultResponse,
        productSelector: productSelector
    )
}

func contractedSettings(
    _ details: UserPaymentSettings.Details = contractDetails()
) -> UserPaymentSettingsResult {
    
    .success(.contracted(details))
}

func contractedState(
    _ contractStatus: UserPaymentSettings.PaymentContract.ContractStatus,
    bankDefaultResponse: UserPaymentSettings.GetBankDefaultResponse = .init(bankDefault: .offEnabled),
    selectedProduct: Product = makeProduct(),
    selector selectorStatus: UserPaymentSettings.ProductSelector.Status = .collapsed,
    status: FastPaymentsSettingsState.Status? = nil
) -> (
    details: UserPaymentSettings.Details,
    state: FastPaymentsSettingsState
) {
    let details = contractDetails(
        paymentContract: paymentContract(
            contractStatus: contractStatus
        ),
        bankDefaultResponse: bankDefaultResponse,
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
    bankDefaultResponse: UserPaymentSettings.GetBankDefaultResponse = .init(bankDefault: .offEnabled),
    productSelector: UserPaymentSettings.ProductSelector,
    status: FastPaymentsSettingsState.Status? = nil
) -> (
    details: UserPaymentSettings.Details,
    state: FastPaymentsSettingsState
) {
    let details = contractDetails(
        paymentContract: paymentContract(
            contractStatus: contractStatus
        ),
        bankDefaultResponse: bankDefaultResponse,
        productSelector: productSelector
    )
    
    let state = fastPaymentsSettingsState(
        .success(.contracted(details)),
        status: status
    )
    
    return (details, state)
}

func fastPaymentsSettingsState(
    _ settingsResult: UserPaymentSettingsResult? = nil,
    status: FastPaymentsSettingsState.Status? = nil
) -> FastPaymentsSettingsState {
    
    .init(
        settingsResult: settingsResult,
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
    contractStatus: UserPaymentSettings.PaymentContract.ContractStatus = .active,
    phoneNumber: PhoneNumber = anyPhoneNumber(),
    phoneNumberMasked: String = anyMessage()
) -> UserPaymentSettings.PaymentContract {
    
    .init(
        id: contractID,
        productID: productID,
        contractStatus: contractStatus,
        phoneNumber: phoneNumber,
        phoneNumberMasked: phoneNumberMasked
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
        settingsResult: settings,
        status: status
    )
    
    return (settings, state)
}

func serverErrorFPSState(
    status: FastPaymentsSettingsState.Status? = nil
) -> FastPaymentsSettingsState {
    
    .init(
        settingsResult: .failure(.serverError(UUID().uuidString)),
        status: status
    )
}

func serverErrorSettings(
) -> UserPaymentSettingsResult {
    
    .failure(.serverError(UUID().uuidString))
}
