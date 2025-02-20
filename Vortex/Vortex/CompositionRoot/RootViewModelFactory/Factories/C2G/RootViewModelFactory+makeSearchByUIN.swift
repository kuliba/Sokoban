//
//  RootViewModelFactory+makeSearchByUIN.swift
//  Vortex
//
//  Created by Igor Malyarov on 13.02.2025.
//

import C2GBackend
import Foundation
import ProductSelectComponent
import RemoteServices

extension RootViewModelFactory {
    
    @inlinable
    func makeSearchByUIN(
        uin: String? = nil
    ) -> SearchByUINDomain.Binder {
        
        composeBinder(
            content: makeUINInputViewModel(value: uin ?? ""),
            initialState: .init(),
            getNavigation: getNavigation,
            selectWitnesses: .empty
        )
    }
    
    @inlinable
    func getNavigation(
        select: SearchByUINDomain.Select,
        notify: @escaping SearchByUINDomain.Notify,
        completion: @escaping (SearchByUINDomain.Navigation) -> Void
    ) {
        switch select {
        case let .uin(uin):
            getUINData(uin) { [weak self] in
                
                guard let self else { return }
                
                switch $0 {
                case let .failure(failure):
                    completion(.failure(failure))
                    
                case let .success(payload):
                    completion(.payment(makeC2BPayment(payload: payload)))
                }
            }
        }
    }
    
    @inlinable
    func getUINData(
        _ uin: SearchByUINDomain.UIN,
        completion: @escaping (GetUINDataResult) -> Void
    ) {
        let products = model.c2gProductSelectProducts()
        let selectedProduct = model.sbpLinkedProduct() ?? products.first
        
        guard let selectedProduct
        else { return completion(.missingC2GPaymentEligibleProducts) }
        
        guard !uin.hasEasterEgg else {
            
            return easterEggsGetUINData(uin, selectedProduct, completion)
        }
        
        let service = onBackground(
            makeRequest: Vortex.RequestFactory.createGetUINDataRequest,
            mapResponse: RemoteServices.ResponseMapper.mapGetUINDataResponse
        )
        
        service(uin.value) {
            
            switch $0 {
            case let .failure(failure as BackendFailure):
                completion(.failure(failure))
                
            case .failure:
                completion(.failure(.c2gConnectivity))
                
            case let .success(response):
                completion(.success(.init(
                    selectedProduct: selectedProduct,
                    products: products,
                    termsCheck: response.termsCheck,
                    uin: response.uin,
                    url: response.url
                )))
            }
            
            _ = service
        }
    }
    
    // TODO: remove easter egg stub
    @inlinable
    func easterEggsGetUINData(
        _ uin: SearchByUINDomain.UIN,
        _ product: ProductSelect.Product,
        _ completion: @escaping (GetUINDataResult) -> Void
    ) {
        schedulers.background.delay(for: .seconds(2)) {
            
            switch uin.value {
            case "01234567890123456789":
                completion(.failure(.c2gConnectivity))
                
            case "12345678901234567890":
                completion(.failure(.server("Server Failure")))
                
            case "99999999999999999999":
                completion(.success(.init(
                    selectedProduct: product,
                    products: [],
                    termsCheck: nil,
                    uin: "99999999999999999999",
                    url: nil
                )))
                
            default:
                completion(.failure(.server("Server Failure")))
            }
        }
    }
    
    typealias GetUINDataResult = Result<C2GPaymentDomain.ContentPayload, BackendFailure>
}

private extension RootViewModelFactory.GetUINDataResult {
    
    static let missingC2GPaymentEligibleProducts: Self = .failure(.missingC2GPaymentEligibleProducts)
}

private extension BackendFailure {
    
    static let c2gConnectivity: Self = .connectivity("Возникла техническая ошибка.\nСвяжитесь с поддержкой банка для уточнения")
    
    static let missingC2GPaymentEligibleProducts: Self = .connectivity("У вас нет подходящих для платежа продуктов.")
}

// TODO: remove with easter egg stub
private extension SearchByUINDomain.UIN {
    
    var hasEasterEgg: Bool {
        
        ["01234567890123456789", "12345678901234567890", "99999999999999999999"].contains(value)
    }
}
