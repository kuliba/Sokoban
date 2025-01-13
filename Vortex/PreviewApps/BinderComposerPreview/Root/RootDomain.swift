//
//  RootDomain.swift
//  BinderComposerPreview
//
//  Created by Igor Malyarov on 14.12.2024.
//

import FlowCore
import PayHub
import PayHubUI

/// A namespace.
enum RootDomain {}

extension RootDomain {
    
    // MARK: - Binder
    
    typealias Binder = FlowCore.Binder<Content, Flow>
    typealias BinderComposer = FlowCore.BinderComposer<Content, Select, Navigation>
    
    // MARK: - Content
    
    typealias Content = PlainPickerContent<Select>
    
    // MARK: - Flow
    
    typealias FlowDomain = FlowCore.FlowDomain<Select, Navigation>
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
