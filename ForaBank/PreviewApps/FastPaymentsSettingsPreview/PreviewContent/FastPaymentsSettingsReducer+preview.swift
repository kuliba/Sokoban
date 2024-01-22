//
//  FastPaymentsSettingsReducer+preview.swift
//  FastPaymentsSettingsPreview
//
//  Created by Igor Malyarov on 11.01.2024.
//

import FastPaymentsSettings

extension FastPaymentsSettingsReducer {
    
    static var preview: FastPaymentsSettingsReducer {
 
        let bankDefaultReducer = BankDefaultReducer()
        let contractReducer = ContractReducer(getProducts: { .preview })
        let productsReducer = ProductsReducer(getProducts: { .preview })
        
        return .init(
            bankDefaultReduce: bankDefaultReducer.reduce(_:_:),
            contractReduce: contractReducer.reduce(_:_:),
            productsReduce: productsReducer.reduce(_:_:)
        )
    }
}
