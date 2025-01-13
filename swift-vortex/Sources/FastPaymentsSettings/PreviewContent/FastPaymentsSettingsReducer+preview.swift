//
//  FastPaymentsSettingsReducer+preview.swift
//
//
//  Created by Igor Malyarov on 11.01.2024.
//

extension FastPaymentsSettingsReducer {
    
    static var preview: FastPaymentsSettingsReducer {
 
        let bankDefaultReducer = BankDefaultReducer()
        let consentListReducer = ConsentListRxReducer()
        let contractReducer = ContractReducer(getProducts: { .preview })
        let productsReducer = ProductsReducer(getProducts: { .preview })
        
        return .init(
            bankDefaultReduce: bankDefaultReducer.reduce(_:_:),
            consentListReduce: consentListReducer.reduce(_:_:),
            contractReduce: contractReducer.reduce(_:_:),
            productsReduce: productsReducer.reduce(_:_:)
        )
    }
}
