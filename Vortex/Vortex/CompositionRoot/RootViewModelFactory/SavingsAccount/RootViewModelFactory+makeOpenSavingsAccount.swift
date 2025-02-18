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
        
        let content = makeOpenSavingsAccountContent(
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
        status: SavingsAccountDomain.OpenAccountContentStatus
    ) -> SavingsAccountDomain.OpenAccountContent {
        
        let getOpenAccount = nanoServiceComposer.compose(
            createRequest: RequestFactory.createGetOpenAccountFormRequest,
            mapResponse: RemoteServices.ResponseMapper.mapGetOpenAccountFormResponse,
            mapError: SavingsAccountDomain.ContentError.init(error:)
        )

        let reducer = SavingsAccountDomain.OpenAccountContentReducer()
        let effectHandler = SavingsAccountDomain.OpenAccountContentEffectHandler { dismissInformer, completion in
            
            getOpenAccount("") { [weak self] in
                
                if case .informer = $0.failure?.kind {
                    
                    self?.schedulers.background.delay(for: .seconds(2), dismissInformer)
                }
                
                completion($0)
            }
        }
        
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
