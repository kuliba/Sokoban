//
//  anyContractDetails.swift
//
//
//  Created by Igor Malyarov on 15.01.2024.
//

import FastPaymentsSettings
import Foundation

func anyContractedSettings(
) -> UserPaymentSettings {
    
    .contracted(anyContractDetails())
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
    bankDefault: UserPaymentSettings.BankDefault = .offEnabled
) -> UserPaymentSettings.ContractDetails {
    
    .init(
        paymentContract: paymentContract,
        consentResult: consentResult,
        bankDefault: bankDefault
    )
}

func anyPaymentContract(
    contractStatus: UserPaymentSettings.PaymentContract.ContractStatus = .active
) -> UserPaymentSettings.PaymentContract {
    
    .init(contractStatus: contractStatus)
}

func anyConsentList(
) -> UserPaymentSettings.ConsentList {
    
    .init()
}
