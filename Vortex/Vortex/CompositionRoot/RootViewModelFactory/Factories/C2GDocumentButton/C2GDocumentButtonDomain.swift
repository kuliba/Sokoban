//
//  C2GDocumentButtonDomain.swift
//  Vortex
//
//  Created by Igor Malyarov on 19.03.2025.
//

/// A namespace
enum C2GDocumentButtonDomain {}

extension C2GDocumentButtonDomain {
    
    // MARK: - Binder
    
    typealias Binder = Vortex.Binder<Content, Flow>
    
    // MARK: - Content
    
    typealias Content = Int
    
    // MARK: - Flow
    
    typealias FlowDomain = Vortex.FlowDomain<Select, Navigation>
    typealias Flow = FlowDomain.Flow
    typealias Notify = FlowDomain.Notify
    
    enum Select {
        
        case tap(Int)
    }
    
    enum Navigation {
        
        case destination(PDFDocumentDomain.Binder)
    }
}
