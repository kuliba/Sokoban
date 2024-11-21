//
//  PaymentsTransfersPersonalDomain.swift
//
//
//  Created by Igor Malyarov on 28.10.2024.
//

import PayHub
import RxViewModel

/// A namespace.
public enum PaymentsTransfersPersonalDomain<Select, Navigation> {}

public extension PaymentsTransfersPersonalDomain {
    
    // MARK: - Binder
    
    typealias Binder = PayHub.Binder<Content, Flow>
    typealias Composer = PayHubUI.BinderComposer<Content, Select, Navigation>
    
    // MARK: - Content
    
    typealias Content = PaymentsTransfersPersonalContent
    
    // MARK: - Flow
    
    typealias FlowDomain = PayHubUI.FlowDomain<Select, Navigation>
    typealias Flow = FlowDomain.Flow
    
    typealias Notify = (NotifyEvent) -> Void
    typealias NotifyEvent = FlowDomain.NotifyEvent
}
