//
//  SavingsAccountDomain.swift
//  
//
//  Created by Andryusina Nataly on 04.12.2024.
//

import Foundation
import FlowCore
import RemoteServices
import RxViewModel
import SavingsAccount
import SavingsServices
import SwiftUI
import OTPInputComponent

enum SavingsAccountDomain {}

extension SavingsAccountDomain {
    
    typealias Destination = Void
    typealias InformerPayload = InformerData
    typealias Landing = RemoteServices.ResponseMapper.GetSavingLandingResponse
    typealias LandingItem = RemoteServices.ResponseMapper.GetSavingLandingData
    typealias OpenAccountLanding = RemoteServices.ResponseMapper.GetOpenAccountFormResponse
    typealias OpenAccountLandingItem = RemoteServices.ResponseMapper.GetOpenAccountFormData

    enum Select: Equatable {
        
        case goToMain
        case openSavingsAccount
        case failure(FlowFailureKind)
    }
    
    enum FlowFailureKind: Equatable {
        
        case timeout(InformerPayload)
        case error(String)
    }

    enum Navigation {
        
        case main
        case openSavingsAccount
        case failure(FlowFailureKind)
        case loaded
    }
    
    // MARK: - Binder
    
    typealias BinderDomain = FlowCore.BinderDomain<Content, Select, Navigation>
    typealias Binder = BinderDomain.Binder
        
    // MARK: - Flow
    
    typealias FlowDomain = BinderDomain.FlowDomain
    typealias Flow = FlowDomain.Flow
    
    typealias FlowState = FlowDomain.State
    typealias FlowEvent = FlowDomain.Event
    
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
    
    typealias Content = RxViewModel<ContentState, ContentEvent, ContentEffect>
    typealias ContentView = SavingsAccountContentView<SpinnerRefreshView, SavingsAccountView, Landing, InformerPayload>
    typealias ContentWrapperView = RxWrapperView<ContentView, ContentState, ContentEvent, ContentEffect>
    typealias WrapperView = RxWrapperView<FlowView<ContentWrapperView, InformerView>, FlowDomain.State, FlowDomain.Event, FlowDomain.Effect>
    
    typealias ViewFactory = SavingsAccountContentViewFactory<SpinnerRefreshView, Landing, SavingsAccountView>
    
    typealias Config = SavingsAccountConfig
    
    typealias OTPView = TimedOTPInputWrapperView<OTPInfoView, OTPWarningView>
}

