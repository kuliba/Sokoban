//
//  AnywayElementModelMapperComposer.swift
//  ForaBank
//
//  Created by Igor Malyarov on 25.07.2024.
//

import Foundation
import ProductSelectComponent

final class AnywayElementModelMapperComposer {
    
    private let model: Model
    
    init(model: Model) {
        
        self.model = model
    }
}

extension AnywayElementModelMapperComposer {
    
    func compose(
        flag: StubbedFeatureFlag.Option
    ) -> AnywayElementModelMapper {
        
        return .init(
            currencyOfProduct: currencyOfProduct,
            format: format,
            getProducts: model.productSelectProducts,
            flag: flag
        )
    }
}

private extension AnywayElementModelMapperComposer {
    
    func format(
        currency: String?,
        amount: Decimal
    ) -> String {
        
        return model.formatted(amount, with: currency ?? "") ?? ""
    }
    
    func getCurrencySymbol(
        for currency: String
    ) -> String {
        
        model.dictionaryCurrencySymbol(for: currency) ?? ""
    }
    
    func currencyOfProduct(
        product: ProductSelect.Product
    ) -> String {
        
        model.currencyOf(product: product) ?? ""
    }
}
