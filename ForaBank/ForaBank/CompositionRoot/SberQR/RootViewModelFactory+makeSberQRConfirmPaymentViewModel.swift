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
        
        allProducts
            .filter(\.allowDebit)
            .filter(\.isMainProduct)
            .mapToSberQRProducts(
                response: response,
                formatBalance: { [weak self] in
                    
                    self?.formattedBalance(of: $0) ?? ""
                }
            )
    }
}

extension Model {
    
    func formattedBalance(
        of product: ProductData
    ) -> String? {
        
        if let card = product as? ProductCardData {
            
            return amountFormatted(
                amount: card.balanceValue,
                currencyCode: card.currency,
                style: .clipped
            )
        }
        
        if let account = product as? ProductAccountData {
            
            return amountFormatted(
                amount: account.balanceValue,
                currencyCode: account.currency,
                style: .clipped
            )
        }
        
        return nil
    }
}

private extension ProductData {
    
    var isMainProduct: Bool {
        
        if let card = self as? ProductCardData,
           let isMain = card.isMain {
            
            return isMain
        }
        
        if self is ProductAccountData {
            
            return true
        }
        
        return false
    }
}
