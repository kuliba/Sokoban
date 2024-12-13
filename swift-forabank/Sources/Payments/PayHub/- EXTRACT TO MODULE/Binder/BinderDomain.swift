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
    
    typealias Binder = PayHub.Binder<Content, Flow>
    typealias BinderComposer = PayHub.BinderComposer<Content, Select, Navigation>
    
    typealias GetNavigation = (Select, @escaping Notify, @escaping (Navigation) -> Void) -> Void
    
    typealias Witnesses = ContentWitnesses<Content, Select>
    
    // MARK: - Flow
    
    typealias FlowDomain = PayHub.FlowDomain<Select, Navigation>
    typealias Flow = FlowDomain.Flow
    
    typealias Notify = (FlowDomain.NotifyEvent) -> Void
}
