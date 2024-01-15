//
//  anyContractDetails.swift
//
//
//  Created by Igor Malyarov on 15.01.2024.
//

import FastPaymentsSettings

func anyContractedSettings(
) -> UserPaymentSettings {
    
    .contracted(anyContractDetails())
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
