//
//  PDFDocumentDomain.swift
//  Vortex
//
//  Created by Igor Malyarov on 19.03.2025.
//

import PDFKit

enum PDFDocumentDomain {}

extension PDFDocumentDomain {
    
    // MARK: - Binder
    
    typealias Binder = Vortex.Binder<Content, Flow>
    
    // MARK: - Content
    
    typealias ContentDomain = StateMachineDomain<PDFDocument, Error>
    typealias Content = ContentDomain.Model
    
    // MARK: - Flow
    
    typealias FlowDomain = Vortex.FlowDomain<Select, Navigation>
    typealias Flow = FlowDomain.Flow
    typealias Notify = FlowDomain.Notify
    
    enum Select {
        
        case alert(String)
    }
    
    enum Navigation {
        
        case alert(String)
    }
}
