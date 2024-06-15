//
//  AnywayElementModelMapperComposer.swift
//  ForaBank
//
//  Created by Igor Malyarov on 15.06.2024.
//

import AnywayPaymentDomain
import OTPInputComponent
import ProductSelectComponent

final class AnywayElementModelMapperComposer {
    
    private let currencyOfProduct: CurrencyOfProduct
    private let getProducts: GetProducts
    private let initiateOTP: InitiateOTP
    
    init(
        currencyOfProduct: @escaping CurrencyOfProduct,
        getProducts: @escaping GetProducts,
        initiateOTP: @escaping InitiateOTP
    ) {
        self.currencyOfProduct = currencyOfProduct
        self.getProducts = getProducts
        self.initiateOTP = initiateOTP
    }
    
    typealias CurrencyOfProduct = (ProductSelect.Product) -> String
    typealias GetProducts = () -> [ProductSelect.Product]
    typealias InitiateOTP = CountdownEffectHandler.InitiateOTP
}

extension AnywayElementModelMapperComposer {
    
    func compose(
        event: @escaping (Event) -> Void
    ) -> AnywayElementModelMapper {
        
        return .init(
            event: event,
            currencyOfProduct: currencyOfProduct,
            getProducts: getProducts,
            initiateOTP: initiateOTP
        )
    }
    
    typealias Event = AnywayPaymentEvent
}
