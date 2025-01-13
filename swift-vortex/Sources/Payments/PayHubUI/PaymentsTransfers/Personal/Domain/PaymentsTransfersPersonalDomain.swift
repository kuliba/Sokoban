//
//  PaymentsTransfersPersonalDomain.swift
//
//
//  Created by Igor Malyarov on 28.10.2024.
//

import FlowCore
import RxViewModel

/// A namespace.
public enum PaymentsTransfersPersonalDomain<Select, Navigation> {}

public extension PaymentsTransfersPersonalDomain {
    
    // MARK: - Binder
    
    typealias BinderDomain = FlowCore.BinderDomain<Content, Select, Navigation>
    typealias Binder = BinderDomain.Binder
    typealias Composer = BinderDomain.BinderComposer
    
    typealias GetNavigation = BinderDomain.GetNavigation
    typealias Witnesses = BinderDomain.Witnesses
    
    // MARK: - Content
    
    typealias Content = PaymentsTransfersPersonalContent
    
    // MARK: - Flow
    
    typealias FlowDomain = BinderDomain.FlowDomain
    typealias Flow = FlowDomain.Flow
    
    typealias Notify = (NotifyEvent) -> Void
    typealias NotifyEvent = FlowDomain.NotifyEvent
}
