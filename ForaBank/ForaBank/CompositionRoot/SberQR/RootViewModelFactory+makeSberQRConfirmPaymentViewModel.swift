//
//  RootViewModelFactory+makeSberQRConfirmPaymentViewModel.swift
//  ForaBank
//
//  Created by Igor Malyarov on 11.12.2023.
//

import Foundation
import ProductSelectComponent
import SberQR

extension RootViewModelFactory {
    
    @inlinable
    func makeSberQRConfirmPaymentViewModel(
        response: GetSberQRDataResponse,
        pay: @escaping (SberQRConfirmPaymentState) -> Void
    ) throws -> SberQRConfirmPaymentViewModel {
        
        let getProducts = sberQRProducts(response)
        
        struct EmptySberQRProductsError: Error {}
        
        let product = try getProducts().first
            .get(orThrow: EmptySberQRProductsError())
        
        let initialState = try SberQRConfirmPaymentState(
            product: product,
            response: response
        )
        
        let viewModel: SberQRConfirmPaymentViewModel = .default(
            initialState: initialState,
            getProducts: getProducts,
            pay: pay,
            scheduler: schedulers.main
        )
        
        return viewModel
    }
    
    func sberQRProducts(
        _ response: GetSberQRDataResponse
    ) -> () -> [ProductSelect.Product] {
        
        return { [weak model] in
            
            guard let model else { return [] }
            
            return model.paymentEligibleProducts()
                .mapToSberQRProducts(
                    response: response,
                    formatBalance: {
                        
                        model.formattedBalance(of: $0) ?? ""
                    },
                    getImage: {
                        
                        model.images.value[$0]?.image
                    }
                )
        }
    }
}
