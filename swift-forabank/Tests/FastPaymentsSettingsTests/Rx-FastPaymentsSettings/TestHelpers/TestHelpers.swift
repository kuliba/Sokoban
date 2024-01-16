//
//  anyContractDetails.swift
//
//
//  Created by Igor Malyarov on 15.01.2024.
//

import FastPaymentsSettings
import Foundation

func anyProductID(
    _ rawValue: Int = generateRandom11DigitNumber()
) -> Product.ID {
    
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

func anyMissingSuccessSettings(
) -> UserPaymentSettings {
    
    .missingContract(.success(anyConsentList()))
}

func anyMissingFailureSettings(
) -> UserPaymentSettings {
    
    .missingContract(.failure(.init()))
}

func anyServerErrorSettings(
) -> UserPaymentSettings {
    
    .failure(.serverError(UUID().uuidString))
}

func anyContractDetails(
    paymentContract: UserPaymentSettings.PaymentContract = anyPaymentContract(),
    consentResult: UserPaymentSettings.ConsentResult = .success(anyConsentList()),
    bankDefault: UserPaymentSettings.BankDefault = .offEnabled,
    product: UserPaymentSettings.Product = anyUserPaymentSettingsProduct()
) -> UserPaymentSettings.ContractDetails {
    
    .init(
        paymentContract: paymentContract,
        consentResult: consentResult,
        bankDefault: bankDefault,
        product: product
    )
}

func anyUserPaymentSettingsProduct(
    id: UserPaymentSettings.Product.ProductID = anyUserPaymentSettingsProductProductID(),
    type: UserPaymentSettings.Product.ProductType = .account
) -> UserPaymentSettings.Product {
    
    .init(id: id, type: type)
}

func anyUserPaymentSettingsProductProductID(
    _ idRawValue: Int = generateRandom11DigitNumber()
) -> UserPaymentSettings.Product.ProductID {
    
    .init(idRawValue)
}

func anyInactiveContractDetails(
    consentResult: UserPaymentSettings.ConsentResult = .success(anyConsentList()),
    bankDefault: UserPaymentSettings.BankDefault = .offEnabled,
    product: UserPaymentSettings.Product = anyUserPaymentSettingsProduct()
) -> UserPaymentSettings.ContractDetails {
    
    .init(
        paymentContract: anyPaymentContract(
            contractStatus: .inactive
        ),
        consentResult: consentResult,
        bankDefault: bankDefault,
        product: product
    )
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
    productIDR: FastPaymentsSettingsEffect.ContractCore.ProductID = .init(generateRandom11DigitNumber()),
    productType: FastPaymentsSettingsEffect.ContractCore.ProductType = .account,
    targetStatus: FastPaymentsSettingsEffectHandler.UpdateContractPayload.TargetStatus = .active
) -> FastPaymentsSettingsEffect.TargetContract {
    
    .init(
        core: .init(
            contractID: contractID,
            productID: productIDR,
            productType: productType
        ),
        targetStatus: targetStatus)
}

func anyUpdateProductPayload(
    _ contractIDRawValue: Int = generateRandom11DigitNumber(),
    _ productIDRawValue: Int = generateRandom11DigitNumber(),
    _ productType: FastPaymentsSettingsEffectHandler.UpdateProductPayload.ProductType = .account
) -> FastPaymentsSettingsEffectHandler.UpdateProductPayload {
    
    .init(
        contractID: .init(contractIDRawValue),
        productID: .init(productIDRawValue),
        productType: productType
    )
}
