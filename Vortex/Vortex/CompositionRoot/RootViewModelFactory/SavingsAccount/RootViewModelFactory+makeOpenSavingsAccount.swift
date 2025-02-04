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
        
        let getOpenAccount = nanoServiceComposer.compose(
            createRequest: RequestFactory.createGetOpenAccountFormRequest,
            mapResponse: RemoteServices.ResponseMapper.mapGetOpenAccountFormResponse,
            mapError: SavingsAccountDomain.ContentError.init(error:)
        )

        let nanoServices: SavingsAccountDomain.ComposerOpenNanoServices = .init(
            loadLanding: {
               getOpenAccount("", $0)
            }
        )
        
        return makeOpenSavingsAccount(nanoServices: nanoServices)
    }
   
    @inlinable
    func makeOpenSavingsAccount(
        nanoServices: SavingsAccountDomain.ComposerOpenNanoServices
    ) -> SavingsAccountDomain.OpenAccountBinder {
        
        let content = makeOpenSavingsAccountContent(
            nanoServices: nanoServices,
            status: .initiate
        )
        
        return composeBinder(
            content: content,
            delayProvider: delayProvider,
            getNavigation: getSavingsAccountNavigation,
            witnesses: .init(emitting: emittingOpen, dismissing: dismissing)
        )
    }
    
    private func makeOpenSavingsAccountContent(
        nanoServices: SavingsAccountDomain.ComposerOpenNanoServices,
        status: SavingsAccountDomain.OpenAccountContentStatus
    ) -> SavingsAccountDomain.OpenAccountContent {
        
        let reducer = SavingsAccountDomain.OpenAccountContentReducer()
        let effectHandler = SavingsAccountDomain.OpenAccountContentEffectHandler(
            microServices: .init(
                loadLanding: nanoServices.loadLanding
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
    func emittingOpen(
        content: SavingsAccountDomain.OpenAccountContent
    ) -> some Publisher<FlowEvent<SavingsAccountDomain.Select, Never>, Never> {
        
        content.$state.compactMap(\.select).map(FlowEvent.select)
    }
    
    @inlinable
    func dismissing(
        content: SavingsAccountDomain.OpenAccountContent
    ) -> () -> Void {
        
        return {}
    }
}
