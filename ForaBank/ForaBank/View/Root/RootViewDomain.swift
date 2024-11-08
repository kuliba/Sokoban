//
//  RootViewDomain.swift
//  ForaBank
//
//  Created by Igor Malyarov on 07.11.2024.
//

import PayHub
import PayHubUI

enum RootViewDomain {
    
    // MARK: - Binder
    
    typealias Binder = PayHub.Binder<Content, Flow>
    
    // MARK: - Content
    
    typealias Content = RootViewModel
    
    // MARK: - Flow
    
    typealias FlowDomain = PayHubUI.FlowDomain<Select, Navigation>
    typealias Flow = FlowDomain.Flow
    
    typealias Notify = (FlowDomain.NotifyEvent) -> Void
    
    enum Select {
        
        case scanQR
    }
    
    enum Navigation {
        
        case scanQR
    }
}
