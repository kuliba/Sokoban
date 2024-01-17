//
//  anyContractDetails.swift
//
//
//  Created by Igor Malyarov on 15.01.2024.
//

import FastPaymentsSettings
import Foundation

func anyProduct(
    _ rawValue: Int = generateRandom11DigitNumber(),
    productType: Product.ProductType = .account
) -> Product {
    
    .init(id: .init(rawValue), productType: productType)
}

func anyEffectProductID(
    _ rawValue: Int = generateRandom11DigitNumber()
) -> FastPaymentsSettingsEffect.ProductID {
    
    .init(rawValue)
}

func makeFPSState(
    _ userPaymentSettings: UserPaymentSettings? = nil,
    status: FastPaymentsSettingsState.Status? = nil
) -> FastPaymentsSettingsState {
    
    .init(
        userPaymentSettings: userPaymentSettings,
        status: status
    )
}

func makeFPSState(
    _ status: UserPaymentSettings.PaymentContract.ContractStatus
) -> (
    details: UserPaymentSettings.ContractDetails,
    state: FastPaymentsSettingsState
) {
    let details = anyContractDetails(
        paymentContract: anyPaymentContract(
            contractStatus: status
        )
    )

    let state = makeFPSState(.contracted(details))
    
    return (details, state)
}

func missingConsentSuccessFPSState(
    _ consentList: UserPaymentSettings.ConsentList = anyConsentList()
) -> FastPaymentsSettingsState {
    
    makeFPSState(.missingContract(.success(consentList)))
}

func connectivityErrorFPSState(
    status: FastPaymentsSettingsState.Status? = nil
) -> FastPaymentsSettingsState {
    
    .init(
        userPaymentSettings: .failure(.connectivityError),
        status: status
    )
}

func serverErrorFPSState(
    status: FastPaymentsSettingsState.Status? = nil
) -> FastPaymentsSettingsState {
    
    .init(
        userPaymentSettings: .failure(.serverError(UUID().uuidString)),
        status: status
    )
}

func anyContractedSettings(
    _ details: UserPaymentSettings.ContractDetails = anyContractDetails()
) -> UserPaymentSettings {
    
    .contracted(details)
}

func anyActiveContractSettings(
) -> UserPaymentSettings {
    
    .contracted(anyContractDetails(
        paymentContract: anyPaymentContract(
            contractStatus: .active
        )
    ))
}

func anyInactiveContractSettings(
) -> UserPaymentSettings {
    
    .contracted(anyContractDetails(
        paymentContract: anyPaymentContract(
            contractStatus: .inactive
        )
    ))
}

func anyMissingConsentFailureSettings(
) -> UserPaymentSettings {
    
    .missingContract(.failure(.init()))
}

func anyMissingConsentSuccessSettings(
) -> UserPaymentSettings {
    
    .missingContract(.success(anyConsentList()))
}

func anyServerErrorSettings(
) -> UserPaymentSettings {
    
    .failure(.serverError(UUID().uuidString))
}

func anyContractDetails(
    paymentContract: UserPaymentSettings.PaymentContract = anyPaymentContract(),
    consentResult: UserPaymentSettings.ConsentResult = .success(anyConsentList()),
    bankDefault: UserPaymentSettings.BankDefault = .offEnabled,
    product: Product = anyUserPaymentSettingsProduct()
) -> UserPaymentSettings.ContractDetails {
    
    .init(
        paymentContract: paymentContract,
        consentResult: consentResult,
        bankDefault: bankDefault,
        product: product
    )
}

func anyUserPaymentSettingsProduct(
    id: Product.ProductID = anyUserPaymentSettingsProductProductID(),
    type productType: Product.ProductType = .account
) -> Product {
    
    .init(id: id, productType: productType)
}

func anyUserPaymentSettingsProductProductID(
    _ idRawValue: Int = generateRandom11DigitNumber()
) -> Product.ProductID {
    
    .init(idRawValue)
}

func anyPaymentContract(
    _ idRawValue: Int = generateRandom11DigitNumber(),
    contractStatus: UserPaymentSettings.PaymentContract.ContractStatus = .active
) -> UserPaymentSettings.PaymentContract {
    
    .init(
        id: .init(idRawValue),
        contractStatus: contractStatus
    )
}

func anyActivePaymentContract(
    _ idRawValue: Int = generateRandom11DigitNumber()
) -> UserPaymentSettings.PaymentContract {
    
    .init(id: .init(idRawValue), contractStatus: .active)
}

func anyConsentList(
) -> UserPaymentSettings.ConsentList {
    
    .init()
}

func anyFastPaymentsSettingsEffectTargetContract(
    contractID: FastPaymentsSettingsEffect.ContractCore.ContractID = .init(generateRandom11DigitNumber()),
    product: Product = anyProduct(),
    targetStatus: FastPaymentsSettingsEffectHandler.UpdateContractPayload.TargetStatus = .active
) -> FastPaymentsSettingsEffect.TargetContract {
    
    .init(
        core: .init(
            contractID: contractID,
            product: product
        ),
        targetStatus: targetStatus)
}

func anyUpdateProductPayload(
    _ contractIDRawValue: Int = generateRandom11DigitNumber(),
    product: Product = anyProduct()
) -> FastPaymentsSettingsEffectHandler.UpdateProductPayload {
    
    .init(
        contractID: .init(contractIDRawValue),
        product: product
    )
}
