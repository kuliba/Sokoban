//
//  AuthLandingDomain.swift
//  Vortex
//
//  Created by Дмитрий Савушкин on 06.03.2025.
//

import Foundation
import RxViewModel

enum AuthProductsLandingDomain {}

extension AuthProductsLandingDomain {

    // MARK: - Binder
    
    typealias Binder = Vortex.Binder<Content, Flow>
    typealias BinderComposer = Vortex.BinderComposer<Content, Select, Navigation>
    
    // MARK: - Content
    
    typealias Content = AuthProductsViewModel
    typealias Domain = AuthProductsLandingDomain
    
    // MARK: - Flow
    
    typealias FlowDomain = Vortex.FlowDomain<Select, Navigation>
    typealias Flow = FlowDomain.Flow
    
    typealias NotifyEvent = FlowDomain.NotifyEvent
    typealias Notify = (NotifyEvent) -> Void
    
    enum Select: Equatable {
        case `continue`
    }
    
    enum Navigation {

        case `continue`
    }
}
