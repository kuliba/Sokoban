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
            getFastContractAccountID { [weak self] in
                
                self?.getUINData(
                    fastAccountID: $0,
                    uin: uin
                ) { [weak self] in
                    
                    guard let self else { return }
                    
                    completion($0.map(makeC2BPayment))
                }
            }
        }
    }
    
    @inlinable
    func getFastContractAccountID(
        completion: @escaping (Int?) -> Void
    ) {
        let map = RemoteServices.ResponseMapper.mapFastPaymentContractFindListResponse
        let mapAccountID = { map($0, $1).map(\.?.contract.accountID) }
        let service = nanoServiceComposer.compose(
            createRequest: Vortex.RequestFactory.createFastPaymentContractFindListRequest,
            mapResponse: mapAccountID
        )
        
        service(()) { completion(try? $0.get()); _ = service }
    }
    
    @inlinable
    func getUINData(
        fastAccountID: Int?,
        uin: SearchByUINDomain.UIN,
        completion: @escaping (GetUINDataResult) -> Void
    ) {
        let (products, selectedProduct) = getC2GProducts(fastAccountID: fastAccountID)
        
        guard let selectedProduct
        else { return completion(.missingC2GPaymentEligibleProducts) }
        
        guard !uin.hasEasterEgg else {
            
            return easterEggsGetUINData(uin, selectedProduct, completion)
        }
        
        let service = onBackground(
            makeRequest: Vortex.RequestFactory.createGetUINDataRequest,
            mapResponse: RemoteServices.ResponseMapper.mapGetUINDataResponse,
            connectivityFailureMessage: .connectivity
        )
        
        service(uin.value) { [weak self] in
            
            let format = self?.format(amount:currency:)
            
            let result = $0.map { 
                
                return C2GPaymentDomain.ContentPayload(
                    discount: $0.discount,
                    discountExpiry: $0.discountExpiry,
                    formattedAmount: format?($0.transAmm, "RUB"),
                    selectedProduct: selectedProduct,
                    products: products,
                    termsCheck: $0.termsCheck,
                    uin: $0.uin,
                    url: $0.url
                )
            }
            
            completion(result)
            _ = service
        }
    }
    
    @inlinable
    func getC2GProducts(
        fastAccountID: Int?
    ) -> (products: [ProductSelect.Product], selected: ProductSelect.Product?) {
        
        let products = model.c2gProductSelectProducts()
        let fastProduct = fastAccountID.map { id in products.first { $0.id.rawValue == id }}
        let selected = fastProduct ?? products.first
        
        return (products, selected)
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
                    discount: nil,//"$ 00.01",
                    discountExpiry: nil,//"soon",
                    formattedAmount: "$ 1 000",
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
    
    static let c2gConnectivity: Self = .connectivity(.connectivity)
    
    static let missingC2GPaymentEligibleProducts: Self = .connectivity(.missingC2GPaymentEligibleProducts)
}

private extension String {
    
    static let connectivity: Self = "Возникла техническая ошибка.\nСвяжитесь с поддержкой банка для уточнения"
    
    static let missingC2GPaymentEligibleProducts: Self = "У вас нет подходящих для платежа продуктов."
}

// TODO: remove with easter egg stub
private extension SearchByUINDomain.UIN {
    
    var hasEasterEgg: Bool {
        
        ["01234567890123456789", "12345678901234567890", "99999999999999999999"].contains(value)
    }
}
