//
//  SavingsAccountDomain.swift
//  
//
//  Created by Andryusina Nataly on 04.12.2024.
//

import Foundation
import RemoteServices
import RxViewModel
import SavingsAccount
import SavingsServices

enum SavingsAccountDomain {}

extension SavingsAccountDomain {
    
    typealias Destination = Void
    typealias InformerPayload = InformerData
    typealias Landing = RemoteServices.ResponseMapper.GetSavingLandingResponse
    
    enum Select: Equatable {
        
        case goToMain
        case order
    }

    enum Navigation {
        
        case main
        case order
        case failure(FlowFailureKind)
        
        enum FlowFailureKind {
            
            case timeout(InformerPayload)
            case error(String)
        }
    }
    
    // MARK: - Binder
    
    typealias BinderDomain = Vortex.BinderDomain<Content, Select, Navigation>
    typealias Binder = BinderDomain.Binder
        
    // MARK: - Flow
    
    typealias FlowDomain = BinderDomain.FlowDomain
    typealias Flow = FlowDomain.Flow
    
    typealias Notify = (NotifyEvent) -> Void
    typealias NotifyEvent = FlowDomain.NotifyEvent

    // MARK: - Content
    
    typealias ContentState = SavingsAccountContentState<Landing, InformerPayload>
    typealias ContentStatus = SavingsAccountContentStatus<Landing, InformerPayload>
    typealias ContentEvent = SavingsAccountContentEvent<Landing, InformerPayload>
    typealias ContentEffect = SavingsAccountContentEffect
    typealias ContentError = SavingsAccount.BackendFailure<InformerPayload>
    
    typealias ContentReducer = SavingsAccount.ContentReducer<Landing, InformerPayload>
    typealias ContentEffectHandler = SavingsAccount.ContentEffectHandler<Landing, InformerPayload>
    typealias ContentMicroService = SavingsAccount.ContentEffectHandlerMicroServices<Landing, InformerPayload>
    
    typealias Content = RxViewModel<ContentState, ContentEvent, ContentEffect>
    typealias ContentView = SavingsAccountContentView<SpinnerRefreshView, SavingsAccountWrapperView, Landing, InformerPayload>
    typealias ContentWrapperView = RxWrapperView<ContentView, ContentState, ContentEvent, ContentEffect>
}
