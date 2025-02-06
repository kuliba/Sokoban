//
//  OpenCardDomain.swift
//  Vortex
//
//  Created by Igor Malyarov on 06.02.2025.
//

import FlowCore

/// A namespace.
enum OpenCardDomain {
    
    // MARK: - Binder
    
    typealias Binder = FlowCore.Binder<Content, Flow>
    
    // MARK: - Content
    
    typealias Content = Void
    
    // MARK: - Flow
    
    typealias FlowDomain = FlowCore.FlowDomain<Select, Navigation>
    typealias Flow = FlowDomain.Flow
    
    enum Select {}
    
    enum Navigation {}
}
