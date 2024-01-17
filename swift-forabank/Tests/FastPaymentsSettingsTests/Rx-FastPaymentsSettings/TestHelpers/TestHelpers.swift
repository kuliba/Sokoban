//
//  anyContractDetails.swift
//
//
//  Created by Igor Malyarov on 15.01.2024.
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

func anyEffectProductID(
    _ rawValue: Int = generateRandom11DigitNumber()
) -> FastPaymentsSettingsEffect.ProductID {
    
    .init(rawValue)
}

func anyMessage() -> String {
    
    UUID().uuidString
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
) -> UserPaymentSettings.ConsentError {
    
    .init()
}

func consentList(
) -> UserPaymentSettings.ConsentList {
    
    .init()
}

func consentResultFailure(
    _ error: UserPaymentSettings.ConsentError = consentError()
) -> UserPaymentSettings.ConsentResult {
    
    .failure(error)
}

func consentResultSuccess(
    _ consentList: UserPaymentSettings.ConsentList = consentList()
) -> UserPaymentSettings.ConsentResult {
    
    .success(consentList)
}

func contractDetails(
    paymentContract: UserPaymentSettings.PaymentContract = paymentContract(),
    consentResult: UserPaymentSettings.ConsentResult = .success(consentList()),
    bankDefault: UserPaymentSettings.BankDefault = .offEnabled,
    productSelector: UserPaymentSettings.ProductSelector = makeProductSelector()
) -> UserPaymentSettings.ContractDetails {
    
    .init(
        paymentContract: paymentContract,
        consentResult: consentResult,
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
    isSelectorExpanded: Bool = false,
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
            isExpanded: isSelectorExpanded
        )
    )
    
    let state = fastPaymentsSettingsState(
        .contracted(details),
        status: status
    )
    
    return (details, state)
}

func fastPaymentsSettingsEffectTargetContract(
    contractID: FastPaymentsSettingsEffect.ContractCore.ContractID = .init(generateRandom11DigitNumber()),
    product: Product = makeProduct(),
    targetStatus: FastPaymentsSettingsEffectHandler.UpdateContractPayload.TargetStatus = .active
) -> FastPaymentsSettingsEffect.TargetContract {
    
    .init(
        core: .init(
            contractID: contractID,
            product: product
        ),
        targetStatus: targetStatus)
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

func makeProduct(
    _ rawValue: Int = generateRandom11DigitNumber(),
    productType: Product.ProductType = .account
) -> Product {
    
    .init(id: .init(rawValue), productType: productType)
}

func makeProductSelector(
    selected: Product = makeProduct(),
    products: [Product]? = nil,
    isExpanded: Bool = false
) -> UserPaymentSettings.ProductSelector {
    
    .init(
        selectedProduct: selected,
        products: products ?? [selected],
        isExpanded: isExpanded
    )
}

func missingContract(
    _ result: UserPaymentSettings.ConsentResult
) -> UserPaymentSettings {
    
    .missingContract(result)
}

func missingConsentFailureSettings(
) -> UserPaymentSettings {
    
    .missingContract(.failure(.init()))
}

func missingConsentSuccessSettings(
) -> UserPaymentSettings {
    
    .missingContract(.success(consentList()))
}

func missingConsentSuccessFPSState(
    _ consentList: UserPaymentSettings.ConsentList = consentList(),
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

func setBankDefaultPreparedServerError() -> FastPaymentsSettingsEvent {
    
    .setBankDefaultPrepared(.serverError(UUID().uuidString))
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

func updateProductPayload(
    _ contractIDRawValue: Int = generateRandom11DigitNumber(),
    product: Product = makeProduct()
) -> FastPaymentsSettingsEffectHandler.UpdateProductPayload {
    
    .init(
        contractID: .init(contractIDRawValue),
        product: product
    )
}

func updateContractConnectivityError() -> FastPaymentsSettingsEvent {
    
    .updateContract(.failure(.connectivityError))
}

func updateContractServerError(
    _ message: String = anyMessage()
) -> FastPaymentsSettingsEvent {
    
    .updateContract(.failure(.serverError(message)))
}

func updateContractSuccess(
    _ contract: UserPaymentSettings.PaymentContract = paymentContract()
) -> FastPaymentsSettingsEvent {
    
    .updateContract(.success(contract))
}

func updateProductConnectivityError() -> FastPaymentsSettingsEvent {
    
    .updateProduct(.failure(.connectivityError))
}

func updateProductServerError() -> FastPaymentsSettingsEvent {
    
    .updateProduct(.failure(.serverError(UUID().uuidString)))
}

func updateProductSuccess() -> FastPaymentsSettingsEvent {
    
    .updateProduct(.success(makeProduct()))
}
