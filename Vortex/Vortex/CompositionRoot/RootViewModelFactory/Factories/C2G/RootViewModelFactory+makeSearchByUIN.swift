//
//  RootViewModelFactory+makeSearchByUIN.swift
//  Vortex
//
//  Created by Igor Malyarov on 13.02.2025.
//

import C2GBackend
import Foundation
import RemoteServices

extension RootViewModelFactory {
    
    @inlinable
    func makeSearchByUIN(
        uin: String? = nil
    ) -> SearchByUINDomain.Binder {
        
        composeBinder(
            content: makeUINInputViewModel(value: uin ?? ""),
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
        guard !uin.hasEasterEgg
        else { return getUINDataEasterEggs(uin, completion: completion) }
        
        let service = onBackground(
            makeRequest: Vortex.RequestFactory.createGetUINDataRequest,
            mapResponse: RemoteServices.ResponseMapper.mapGetUINDataResponse
        )
        
        service(uin.value) {
            
            print($0) // TODO: use in completion
            completion(.success(()))
            _ = service
        }
    }
    
    // TODO: remove stub
    @inlinable
    func getUINDataEasterEggs(
        _ uin: SearchByUINDomain.UIN,
        completion: @escaping (GetUINDataResult) -> Void
    ) {
        schedulers.background.delay(for: .seconds(2)) {
            
            switch uin.value {
            case "01234567890123456789":
                completion(.failure(.c2gConnectivity))
                
            case "12345678901234567890":
                completion(.failure(.server("Server Failure")))
                
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

// TODO: remove with stub
private extension SearchByUINDomain.UIN {
    
    var hasEasterEgg: Bool {
        
        ["01234567890123456789", "12345678901234567890"].contains(value)
    }
}
