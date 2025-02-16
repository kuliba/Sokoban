//
//  RootViewModelFactory+makeC2BPayment.swift
//  Vortex
//
//  Created by Igor Malyarov on 13.02.2025.
//

import C2GCore
import PaymentComponents
import RemoteServices

extension RootViewModelFactory {
    
    @inlinable
    func makeC2BPayment(
        payload: C2GPaymentDomain.ContentPayload
    ) -> C2GPaymentDomain.Binder {
        
        composeBinder(
            content: makeC2BPaymentContent(payload: payload),
            delayProvider: delayProvider,
            getNavigation: getNavigation,
            selectWitnesses: .empty
        )
    }
    
    @inlinable
    func makeC2BPaymentContent(
        payload: C2GPaymentDomain.ContentPayload
    ) -> C2GPaymentDomain.Content {
        
        let initialState = C2GPaymentState(
            productSelect: .init(selected: payload.selectedProduct),
            termsCheck: payload.termsCheck,
            uin: payload.uin,
            context: payload.url
        )
        
        let productSelectReducer = ProductSelectReducer(
            getProducts: { payload.products }
        )
        let reducer = C2GPaymentDomain.ContentReducer(
            productSelectReduce: productSelectReducer.reduce
        )
        
        return .init(
            initialState: initialState,
            reduce: reducer.reduce,
            handleEffect: { _,_ in },
            scheduler: schedulers.main
        )
    }
    
    @inlinable
    func delayProvider(
        navigation: C2GPaymentDomain.Navigation
    ) -> Delay {
        
        return .zero
    }
    
    @inlinable
    func getNavigation(
        select: C2GPaymentDomain.Select,
        notify: @escaping C2GPaymentDomain.Notify,
        completion: @escaping (C2GPaymentDomain.Navigation) -> Void
    ) {
        switch select {
        case let .pay(payload):
            createC2GPayment(payload, completion: completion)
        }
    }
    
    @inlinable
    func createC2GPayment(
        _ digest: C2GPaymentDomain.Select.Digest,
        completion: @escaping (C2GPaymentDomain.Navigation) -> Void
    ) {
        let payload = digest.payload
        
        guard !payload.uin.hasEasterEgg
        else { return createC2GPaymentEasterEggs(payload, completion: completion) }
        
        let service = onBackground(
            makeRequest: RequestFactory.createCreateC2GPaymentRequest,
            mapResponse: RemoteServices.ResponseMapper.mapCreateC2GPaymentResponse
        )
        
        service(payload) {
            
            print($0)
            completion(.success(()))
            _ = service
        }
    }
    
    // TODO: remove stub
    @inlinable
    func createC2GPaymentEasterEggs(
        _ payload: RemoteServices.RequestFactory.CreateC2GPaymentPayload,
        completion: @escaping (C2GPaymentDomain.Navigation) -> Void
    ) {
        schedulers.background.delay(for: .seconds(2)) {
            
            switch payload.uin {
            case "01234567890123456789":
                completion(.connectivityFailure)
                
            case "12345678901234567890":
                completion(.failure(.server("server error")))
                
            default:
                completion(.success(()))
            }
        }
    }
    
    typealias CreateC2GPaymentResult = Result<Void, BackendFailure> // TODO: replace Void with  CreateC2GPaymentResponse from C2GBackend when ready
}

// MARK: - Helpers

private extension C2GPaymentDomain.Navigation {
    
    static let connectivityFailure: Self = .failure(.connectivity("Возникла техническая ошибка.\nСвяжитесь с поддержкой банка для уточнения"))
}

// TODO: remove with stub
private extension String {
    
    var hasEasterEgg: Bool {
        
        ["01234567890123456789", "12345678901234567890"].contains(self)
    }
}

// MARK: - Adapters

private extension C2GPaymentDigest {
    
    var payload: RemoteServices.RequestFactory.CreateC2GPaymentPayload {
 
        switch productID.type {
        case .account:
            return .init(accountID: productID.id, cardID: nil, uin: uin)

        case .card:
            return .init(accountID: nil, cardID: productID.id, uin: uin)
        }
    }
}
