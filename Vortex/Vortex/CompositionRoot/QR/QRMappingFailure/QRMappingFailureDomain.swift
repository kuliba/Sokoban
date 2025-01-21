//
//  QRMappingFailureDomain.swift
//  Vortex
//
//  Created by Igor Malyarov on 13.01.2025.
//

import PayHubUI

/// A namespace.
enum QRMappingFailureDomain {}

extension QRMappingFailureDomain {
    
    // MARK: - Binder
    
    typealias Binder = Vortex.Binder<Content, Flow>
    
    // MARK: - Content
    
    typealias Content = Void
    
    // MARK: - Flow
    
    typealias FlowDomain = Vortex.FlowDomain<Select, Navigation>
    typealias Flow = FlowDomain.Flow
    
    typealias NotifyEvent = FlowDomain.NotifyEvent
    typealias Notify = (NotifyEvent) -> Void
    
    enum Select: Equatable {
        
        case back
        case detailPayment
        case manualSearch
        case scanQR
    }
    
    enum Navigation {
        
        case back
        case detailPayment(Node<PaymentsViewModel>)
        case categoryPicker(Node<CategoryPickerViewDomain.Binder>)
        case scanQR
    }
}
