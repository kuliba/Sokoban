//
//  RootViewModelFactory+makeSberQRConfirmPaymentViewModel.swift
//  ForaBank
//
//  Created by Igor Malyarov on 11.12.2023.
//

import Foundation
import SberQR

extension RootViewModelFactory {
    
    static func makeSberQRConfirmPaymentViewModel(
        model: Model,
        logger: LoggerAgentProtocol
    ) -> MakeSberQRConfirmPaymentViewModel {
        
        return { response, pay in
            
            let getProducts = { [weak model] in
                
                (model?.allProducts ?? [])
                    .filter(\.allowDebit)
                    .filter(\.isMain)
                    .mapToSberQRProducts(response: response)
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

private extension ProductData {
    
    var isMain: Bool {
        
        if let card = self as? ProductCardData {
            
            return card.isMain
        }
        
        if self is ProductAccountData {
            
            return true
        }
        
        return false
    }
}
