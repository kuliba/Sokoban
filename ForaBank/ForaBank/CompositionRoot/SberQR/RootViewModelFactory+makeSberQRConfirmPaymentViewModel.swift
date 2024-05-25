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
    
    static func makeSberQRConfirmPaymentViewModel(
        model: Model,
        logger: LoggerAgentProtocol
    ) -> MakeSberQRConfirmPaymentViewModel {
        
        return { response, pay in
            
            let getProducts = { [weak model] in
                
                model?.sberQRProducts(response) ?? []
            }
            
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
                scheduler: .makeMain()
            )
            
            return viewModel
        }
    }
}

private extension Model {
    
    func sberQRProducts(
        _ response: GetSberQRDataResponse
    ) -> [ProductSelect.Product] {
        
        paymentProducts()
            .mapToSberQRProducts(
                response: response,
                formatBalance: { [weak self] in
                    
                    self?.formattedBalance(of: $0) ?? ""
                }, 
                getImage: { self.images.value[$0]?.image }
            )
    }
}
