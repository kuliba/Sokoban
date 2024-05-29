//
//  AnywayPaymentUpdate+preview.swift
//  TransactionPreview
//
//  Created by Igor Malyarov on 20.05.2024.
//

import AnywayPaymentDomain

extension AnywayPaymentUpdate {
    
    static let preview: Self = .init(
        details: .preview,
        fields: [],
        parameters: []
    )
}

private extension AnywayPaymentUpdate.Details {
    
    static let preview: Self = .init(
        amounts: .preview,
        control: .preview,
        info: .preview
    )
}

private extension AnywayPaymentUpdate.Details.Amounts {
    
    static let preview: Self = .init(
        amount: nil,
        creditAmount: nil,
        currencyAmount: nil,
        currencyPayee: nil,
        currencyPayer: nil,
        currencyRate: nil,
        debitAmount: nil,
        fee: nil
    )
}

private extension AnywayPaymentUpdate.Details.Control {
    
    static let preview: Self = .init(
        isFinalStep: false, 
        isFraudSuspected: false,
        needMake: false,
        needOTP: false,
        needSum: false
    )
}

private extension AnywayPaymentUpdate.Details.Info {
    
    static let preview: Self = .init(
        documentStatus: nil,
        infoMessage: nil,
        payeeName: nil,
        paymentOperationDetailID: nil,
        printFormType: nil
    )
}
