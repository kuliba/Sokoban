//
//  RootViewModelFactory+getOutlineProduct.swift
//  Vortex
//
//  Created by Igor Malyarov on 23.11.2024.
//

import AnywayPaymentDomain

extension RootViewModelFactory {
    
    @inlinable
    func getOutlineProduct(
        source: AnywayPaymentSourceParser.Source
    ) -> AnywayPaymentOutline.Product? {
        
        return model.outlineProduct()
    }
}
