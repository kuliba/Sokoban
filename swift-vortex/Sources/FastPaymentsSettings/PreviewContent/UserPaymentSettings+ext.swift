//
//  UserPaymentSettings+ext.swift
//
//
//  Created by Igor Malyarov on 11.01.2024.
//

extension UserPaymentSettings {
    
    static func active(
        _ consentList: ConsentListState = .success,
        bankDefaultResponse: UserPaymentSettings.GetBankDefaultResponse = .init(bankDefault: .offEnabled)
    ) -> Self {
        
        .contracted(
            .preview(
                paymentContract: .active,
                consentList: consentList,
                bankDefaultResponse: bankDefaultResponse
            )
        )
    }
    
    static func inactive(
        _ consentList: ConsentListState = .success,
        bankDefaultResponse: UserPaymentSettings.GetBankDefaultResponse = .init(bankDefault: .offEnabled)
    ) -> Self {
        
        .contracted(
            .preview(
                paymentContract: .inactive,
                consentList: consentList,
                bankDefaultResponse: bankDefaultResponse
            )
        )
    }
    
    static func missingContract(
        consent: ConsentListState = .success
    ) -> Self {
        
        .missingContract(consent)
    }
}

extension UserPaymentSettings.Details {
    
    static func preview(
        paymentContract: UserPaymentSettings.PaymentContract = .active,
        consentList: ConsentListState = .success,
        bankDefaultResponse: UserPaymentSettings.GetBankDefaultResponse = .init(bankDefault: .offEnabled),
        productSelector: UserPaymentSettings.ProductSelector = .init(
            selectedProduct: .card,
            products: .preview
        )
    ) -> Self {
        
        .init(
            paymentContract: paymentContract,
            consentList: consentList,
            bankDefaultResponse: bankDefaultResponse,
            productSelector: productSelector
        )
    }
}

extension UserPaymentSettings.PaymentContract {
    
    static let active: Self = .init(
        id: .init(generateRandom11DigitNumber()),
        accountID: Product.card.accountID,
        contractStatus: .active,
        phoneNumber: "79171044913",
        phoneNumberMasked: "+7 ... ... 49 13"
    )
    
    static let inactive: Self = .init(
        id: .init(generateRandom11DigitNumber()),
        accountID: Product.account.accountID,
        contractStatus: .inactive,
        phoneNumber: "79171044913",
        phoneNumberMasked: "+7 ... ... 49 13"
    )
}

private extension ConsentListState {
    
    static let success: Self = .success(.preview)
}

private extension ConsentList {
    
    static let preview: Self = .init(
        banks: .preview,
        mode: .collapsed,
        searchText: ""
    )
}
