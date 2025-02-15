//
//  RootViewModelFactory+makeSearchByUIN.swift
//  Vortex
//
//  Created by Igor Malyarov on 13.02.2025.
//

extension RootViewModelFactory {
    
    @inlinable
    func makeSearchByUIN(
        uin: String? = nil
    ) -> SearchByUINDomain.Binder {
        
        composeBinder(
            content: uin,
            initialState: .init(),
            delayProvider: delayProvider,
            getNavigation: getNavigation,
            selectWitnesses: .empty
        )
    }
    
    @inlinable
    func delayProvider(
        navigation: SearchByUINDomain.Navigation
    ) -> Delay {
        
        return .zero
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
                    
                case .success(()):
                    completion(.payment(makeC2BPayment()))
                }
            }
        }
    }
    
    @inlinable
    func getUINData(
        _ uin: SearchByUINDomain.UIN,
        completion: @escaping (GetUINDataResult) -> Void
    ) {
        // TODO: - replace stub with remote service, call on background
        schedulers.background.delay(for: .seconds(2)) {
            
            switch uin.value {
            case "connectivityFailure":
                completion(.failure(.c2gConnectivity))
                
            case "serverFailure":
                completion(.failure(.server("Server Failure"))) // TODO: pass error message from response
                
            default:
                completion(.success(()))
            }
        }
    }
    
    typealias GetUINDataResult = Result<Void, BackendFailure> // TODO: replace Void with  GetUINDataResponse from C2GBackend when ready
}

private extension BackendFailure {
    
    static let c2gConnectivity: Self = .connectivity("Возникла техническая ошибка.\nСвяжитесь с поддержкой банка для уточнения")
}
