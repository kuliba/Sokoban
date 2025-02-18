//
//  RootViewModelFactory+makeSavingsAccount.swift
//  Vortex
//
//  Created by Andryusina Nataly on 09.12.2024.
//

import Combine
import Foundation
import FlowCore
import GenericRemoteService
import RemoteServices
import SavingsServices

extension RootViewModelFactory {
    
    @inlinable
    func makeSavingsNodes(
        _ dismiss: @escaping () -> Void
    ) -> SavingsAccountNodes {
        
        let binder: SavingsAccountDomain.Binder = makeSavingsAccount()
        let openBinder: SavingsAccountDomain.OpenAccountBinder = makeOpenSavingsAccount()
        
        let cancellable = binder.flow.$state
            .compactMap {
                switch $0.navigation {
                case .main: return ()
                    
                default: return nil
                }
            }
            .sink { dismiss() }
        
        let openCancellable = openBinder.flow.$state
            .compactMap {
                switch $0.navigation {
                case .main: return ()
                    
                default: return nil
                }
            }
            .sink { dismiss() }
        
        return .init(
            openSavingsAccountNode: .init(model: openBinder, cancellable: openCancellable),
            savingsAccountNode: .init(model: binder, cancellable: cancellable)
        )
    }
    
    @inlinable
    func makeSavingsAccount() -> SavingsAccountDomain.Binder {
        
        let getSavingLanding = nanoServiceComposer.compose(
            createRequest: RequestFactory.createGetSavingLandingRequest,
            mapResponse: RemoteServices.ResponseMapper.mapGetSavingLandingResponse,
            mapError: SavingsAccountDomain.ContentError.init(error:)
        )

        let nanoServices: SavingsAccountDomain.ComposerLandingNanoService = .init(
            loadLanding: { getSavingLanding($0, $1) }
        )
        
        return makeSavingsAccount(nanoServices: nanoServices)
    }
    
    @inlinable
    func makeSavingsAccount(
        nanoServices: SavingsAccountDomain.ComposerLandingNanoService
    ) -> SavingsAccountDomain.Binder {
        
        let content = makeContent(
            nanoServices: nanoServices,
            status: .initiate
        )
        
        return composeBinder(
            content: content,
            delayProvider: delayProvider,
            getNavigation: getSavingsAccountNavigation,
            witnesses: .init(emitting: emitting, dismissing: dismissing)
        )
    }
    
    @inlinable
    func delayProvider(
        navigation: SavingsAccountDomain.Navigation
    ) -> Delay {
        
        switch navigation {
        case .main:                  return .milliseconds(100)
        case .openSavingsAccount:   return settings.delay
        case .failure:               return settings.delay
        }
    }
    
    private func makeContent(
        nanoServices: SavingsAccountDomain.ComposerLandingNanoService,
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
            initialState: .init(status: status, navTitle: .init(title: "", subtitle: "")),
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
        case .openSavingsAccount:
            completion(.openSavingsAccount)
        }
    }
    
    @inlinable
    func emitting(
        content: SavingsAccountDomain.Content
    ) -> some Publisher<FlowEvent<SavingsAccountDomain.Select, Never>, Never> {
        
        content.$state.compactMap(\.select).map(FlowEvent.select)
    }
    
    @inlinable
    func dismissing(
        content: SavingsAccountDomain.Content
    ) -> () -> Void {
        
        return {}
    }
}

extension SavingsAccountDomain.ContentError {
    
    typealias RemoteError = RemoteServiceError<Error, Error, RemoteServices.ResponseMapper.MappingError>
    
    init(
        error: RemoteError
    ) {
        switch error {
        case let .performRequest(error):
            if error.isNotConnectedToInternetOrTimeout() {
                self = .init(kind: .informer(.init(message: "Ошибка загрузки данных.\nПопробуйте позже.", icon: .close)))
            } else {
                self = .init(kind: .alert("Попробуйте позже."))
            }
            
        default:
            self = .init(kind: .alert("Попробуйте позже."))
        }
    }
}
