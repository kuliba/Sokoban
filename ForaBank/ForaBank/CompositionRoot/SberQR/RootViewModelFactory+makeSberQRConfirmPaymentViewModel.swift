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
        url: URL,
        pay: @escaping (SberQRConfirmPaymentState) -> Void,
        completion: @escaping (SberQRConfirmPaymentViewModel?) -> Void
    ) {
        getSberQRData(url: url) { [weak self] result in
            
            guard let self else { return }
            
            guard case let .success(response) = result,
                  let model = try? makeSberQRConfirmPaymentViewModel(response: response, pay: pay)
            else { return completion(nil) }
            
            completion(model)
        }
    }
    
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
            
            return model?.sberQRProducts(response) ?? []
        }
    }
}

extension Model {
    
    func sberQRProducts(
        _ response: GetSberQRDataResponse
    ) -> [ProductSelect.Product] {
        
        paymentEligibleProducts()
            .mapToSberQRProducts(
                response: response,
                formatBalance: { [weak self] in
                    
                    self?.formattedBalance(of: $0) ?? ""
                },
                getImage: { self.images.value[$0]?.image }
            )
    }
}

