//
//  RootDomain.swift
//  BinderComposerPreview
//
//  Created by Igor Malyarov on 14.12.2024.
//

import PayHub
import PayHubUI

/// A namespace.
enum RootDomain {
    
    // MARK: - Binder
    
    typealias Binder = PayHub.Binder<Content, Flow>
    typealias BinderComposer = PayHub.BinderComposer<Content, Select, Navigation>
    
    // MARK: - Content
    
    typealias Content = PlainPickerContent<Select>
    
    // MARK: - Flow
    
    typealias FlowDomain = PayHub.FlowDomain<Select, Navigation>
    typealias Flow = FlowDomain.Flow
    typealias Notify = FlowDomain.Notify
    
    enum Select: Equatable, CaseIterable {
        
        case destination, sheet
    }
    
    enum Navigation {
        
        case destination(Node<DestinationDomain.Content>)
        case sheet(Node<DestinationDomain.Content>)
    }
}
