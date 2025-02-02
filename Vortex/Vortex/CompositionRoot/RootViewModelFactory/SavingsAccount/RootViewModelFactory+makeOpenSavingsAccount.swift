//
//  RootViewModelFactory+makeOpenSavingsAccount.swift
//  Vortex
//
//  Created by Andryusina Nataly on 02.02.2025.
//

import Combine
import Foundation
import GenericRemoteService
import RemoteServices
import SavingsServices

extension RootViewModelFactory {
    
    @inlinable
    func makeOpenSavingsAccount() -> SavingsAccountDomain.OpenAccountBinder {
        
        let getSavingLanding = nanoServiceComposer.compose(
            createRequest: RequestFactory.createGetSavingLandingRequest,
            mapResponse: RemoteServices.ResponseMapper.mapGetSavingLandingResponse,
            mapError: SavingsAccountDomain.ContentError.init(error:)
        )

        let getOpenAccount = nanoServiceComposer.compose(
            createRequest: RequestFactory.createGetOpenAccountFormRequest,
            mapResponse: RemoteServices.ResponseMapper.mapGetOpenAccountFormResponse,
            mapError: SavingsAccountDomain.ContentError.init(error:)
        )

        let nanoServices: SavingsAccountDomain.ComposerNanoServices = .init(
            loadLanding: { getSavingLanding($0, $1) },
            openSavingsAccount: { getOpenAccount("", $0) }
        )
        
        return makeOpenSavingsAccount(nanoServices: nanoServices)
    }
   
    @inlinable
    func makeOpenSavingsAccount(
        nanoServices: SavingsAccountDomain.ComposerNanoServices
    ) -> SavingsAccountDomain.OpenAccountBinder {
        
        let content = makeOpenSavingsAccountContent(
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
    
    private func makeOpenSavingsAccountContent(
        nanoServices: SavingsAccountDomain.ComposerNanoServices,
        status: SavingsAccountDomain.OpenAccountContentStatus
    ) -> SavingsAccountDomain.OpenAccountContent {
        
        let reducer = SavingsAccountDomain.OpenAccountContentReducer()
        let effectHandler = SavingsAccountDomain.OpenAccountContentEffectHandler(
            microServices: .init(
                loadLanding: nanoServices.openSavingsAccount
            )
        )
        
        return .init(
            initialState: .init(status: status, navTitle: .init(title: "", subtitle: "")),
            reduce: reducer.reduce(_:_:),
            handleEffect: effectHandler.handleEffect,
            scheduler: schedulers.main
        )
    }

    @inlinable
    func emitting(
        content: SavingsAccountDomain.OpenAccountContent
    ) -> some Publisher<FlowEvent<SavingsAccountDomain.Select, Never>, Never> {
        
        Empty()
    }
    
    @inlinable
    func dismissing(
        content: SavingsAccountDomain.OpenAccountContent
    ) -> () -> Void {
        
        return {}
    }
}

/*private extension SavingsAccountDomain.ContentError {
    
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
*/
