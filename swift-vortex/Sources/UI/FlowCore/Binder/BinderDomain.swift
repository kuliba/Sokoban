//
//  BinderDomain.swift
//
//
//  Created by Igor Malyarov on 10.11.2024.
//

/// A namespace.
public enum BinderDomain<Content, Select, Navigation> {}

public extension BinderDomain {
    
    // MARK: - Binder
    
    typealias Binder = FlowCore.Binder<Content, Flow>
    typealias BinderComposer = FlowCore.BinderComposer<Content, Select, Navigation>
    
    typealias GetNavigation = (Select, @escaping Notify, @escaping (Navigation) -> Void) -> Void
    
    typealias Witnesses = ContentWitnesses<Content, FlowEvent<Select, Never>>
    
    // MARK: - Flow
    
    typealias FlowDomain = FlowCore.FlowDomain<Select, Navigation>
    typealias Flow = FlowDomain.Flow
    
    typealias Notify = (FlowDomain.NotifyEvent) -> Void
}
