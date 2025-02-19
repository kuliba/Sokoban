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

        let getVerificationCode = nanoServiceComposer.compose(
            createRequest: RequestFactory.createPrepareOpenSavingsAccountRequest,
            mapResponse: RemoteServices.ResponseMapper.mapPrepareOpenSavingsAccountResponse,
            mapError: SavingsAccountDomain.ContentError.init(error:)
        )

        let reducer = SavingsAccountDomain.OpenAccountContentReducer()
        let effectHandler = SavingsAccountDomain.OpenAccountContentEffectHandler(
            load: { dismissInformer, completion in
                
                getOpenAccount("") { [weak self] in
                    
                    if let self, case .informer = $0.failure?.kind {
                        
                        self.schedulers.background.delay(for: self.settings.informerDelay, dismissInformer)
                    }

                    completion($0)
                }
            },
            getVerificationCode: { completion in
                
                getVerificationCode(()) {
                    
                    switch $0 {
                    case let .failure(failure):
                        completion(.failure(failure))
                        
                    default:
                        completion(.success(1))
                    }
                }
            }
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
