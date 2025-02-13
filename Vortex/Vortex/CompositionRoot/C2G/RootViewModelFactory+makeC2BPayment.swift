//
//  RootViewModelFactory+makeC2BPayment.swift
//  Vortex
//
//  Created by Igor Malyarov on 13.02.2025.
//

extension RootViewModelFactory {
    
    @inlinable
    func makeC2BPayment(
    ) -> C2GPaymentDomain.Binder {
        
        composeBinder(
            content: (),
            initialState: .init(),
            delayProvider: delayProvider,
            getNavigation: getNavigation,
            selectWitnesses: .empty
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
            createC2GPayment(payload) { [weak self] in
                
                guard let self else { return }
                
                switch $0 {
                case let .failure(failure):
                    completion(.failure(failure))
                    
                case let .success(success):
                    completion(.success(success))
                }
            }
        }
    }
    
    @inlinable
    func createC2GPayment(
        _ payload: C2GPaymentDomain.Select.Payload,
        completion: @escaping (CreateC2GPaymentResult) -> Void
    ) {
        // TODO: - replace stub with remote service, call on background
        schedulers.background.delay(for: .seconds(2)) {
            
            switch payload {
            case "connectivityFailure":
                completion(.failure(.connectivity("Возникла техническая ошибка")))
                
            case "serverFailure":
                completion(.failure(.server("Возникла техническая ошибка")))
                
            default:
                completion(.success(()))
            }
        }
    }
    
    typealias CreateC2GPaymentResult = Result<Void, BackendFailure> // TODO: replace Void with  CreateC2GPaymentResponse from C2GBackend when ready
}
