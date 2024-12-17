//
//  RootViewModelFactory+makeSavingsAccount.swift
//  ForaBank
//
//  Created by Andryusina Nataly on 09.12.2024.
//

import Foundation
import GenericRemoteService
import RemoteServices
import SavingsServices

extension RootViewModelFactory {
    
    @inlinable
    func makeSavingsAccount() -> SavingsAccountDomain.Binder {
        
        let getSavingLanding = nanoServiceComposer.compose(
            createRequest: RequestFactory.createGetSavingLandingRequest,
            mapResponse: RemoteServices.ResponseMapper.mapGetSavingLandingResponse,
            mapError: SavingsAccountDomain.ContentError.init(error:)
        )

        let nanoServices: SavingsAccountDomain.ComposerNanoServices = .init(
            loadLanding: { getSavingLanding(( "", $0), $1) },
            orderAccount: {_ in }
        )
        
        return makeSavingsAccount(nanoServices: nanoServices)
    }
    
    @inlinable
    func makeSavingsAccount(
        nanoServices: SavingsAccountDomain.ComposerNanoServices
    ) -> SavingsAccountDomain.Binder {
        
        return compose(
            getNavigation: getSavingsAccountNavigation,
            content: makeContent(
                nanoServices: nanoServices,
                status: .initiate
            ),
            witnesses: .init(
                emitting: {
                    $0.$state.compactMap(\.select)
                },
                dismissing: { content in
                    { content.event(.resetSelection) }
                }
            )
        )
    }
    
    private func makeContent(
        nanoServices: SavingsAccountDomain.ComposerNanoServices,
        status: SavingsAccountDomain.ContentStatus
    ) -> SavingsAccountDomain.Content {
        
        let reducer = SavingsAccountDomain.ContentReducer()
        let effectHandler = SavingsAccountDomain.ContentEffectHandler(
            microServices: .init(
                loadLanding: nanoServices.loadLanding
            ),
            landingType: "DEFAULT"
        )
        
        return .init(
            initialState: .init(status: status),
            reduce: reducer.reduce(_:_:),
            handleEffect: effectHandler.handleEffect,
            scheduler: schedulers.main
        )
    }

    @inlinable
    func getSavingsAccountNavigation(
        select: SavingsAccountDomain.Select,
        notify: @escaping SavingsAccountDomain.Notify,
        completion: @escaping (SavingsAccountDomain.Navigation) -> Void
    ) {
        switch select {
        case .goToMain:
            completion(.main)
        case .order:
            completion(.order)
        }
    }
}

private extension SavingsAccountDomain.ContentError {
    
    typealias RemoteError = RemoteServiceError<Error, Error, RemoteServices.ResponseMapper.MappingError>
    
    init(
        error: RemoteError
    ) {
        switch error {
        case let .performRequest(error):
            if error.isNotConnectedToInternetOrTimeout() {
                self = .init(kind: .informer(.init(message: "Проверьте подключение к сети", icon: .wifiOff)))
            } else {
                self = .init(kind: .alert("Попробуйте позже."))
            }
            
        default:
            self = .init(kind: .alert("Попробуйте позже."))
        }
    }
}
