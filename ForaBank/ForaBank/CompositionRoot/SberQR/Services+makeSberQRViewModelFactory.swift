//
//  Services+makeSberQRViewModelFactory.swift
//  ForaBank
//
//  Created by Igor Malyarov on 11.12.2023.
//

import Foundation
import SberQR

extension Services {
    
    static func makeSberQRViewModelFactory(
        model: Model,
        logger: LoggerAgentProtocol
    ) -> SberQRViewModelFactory {
        
        let makeSberQRConfirmPaymentViewModel = makeSberQRConfirmPaymentViewModel(
            model: model,
            logger: logger
        )
        
        return .init(
            makeSberQRConfirmPaymentViewModel: makeSberQRConfirmPaymentViewModel
        )
    }
    
    private static func makeSberQRConfirmPaymentViewModel(
        model: Model,
        logger: LoggerAgentProtocol
    ) -> MakeSberQRConfirmPaymentViewModel {
        
        return { url, response, completion, pay in
            
            let getProducts = { [weak model] in
                
                (model?.allProducts ?? [])
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
