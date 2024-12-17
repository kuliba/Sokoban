//
//  OperationPickerDomain.swift
//  
//
//  Created by Igor Malyarov on 22.11.2024.
//

import PayHub

/// A namespace/
public enum OperationPickerDomain<Latest, Navigation> {}

public extension OperationPickerDomain {
    
    // MARK: - Binder
    
    typealias Binder = PayHub.Binder<Content, Flow>
    typealias Composer = BinderComposer<Content, Select, Navigation>
    
    // MARK: - Content
    
    typealias Content = OperationPickerContent<Latest>
    
    // MARK: - Flow
    
    typealias FlowDomain = PayHub.FlowDomain<Select, Navigation>
    typealias Flow = FlowDomain.Flow
    typealias Notify = (FlowDomain.NotifyEvent) -> Void
    
    typealias Select = OperationPickerElement<Latest>
}
