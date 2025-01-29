//
//  CategoryPickerSectionDomain.swift
//  Vortex
//
//  Created by Igor Malyarov on 03.09.2024.
//

import PayHubUI

/// A namespace.
enum CategoryPickerSectionDomain {}

extension CategoryPickerSectionDomain {
    
    // MARK: - Binder
    
    typealias Binder = Vortex.Binder<Content, Flow>
    
    // MARK: - Content
    
    typealias ContentDomain = CategoryPickerContentDomain<ServiceCategory>
    typealias Content = ContentDomain.Content
    
    // MARK: - Flow
    
    typealias FlowDomain = Vortex.FlowDomain<Select, Navigation>
    typealias Flow = FlowDomain.Flow
    typealias Notify = FlowDomain.Notify
    
    typealias Select = ServiceCategory
    
    enum Navigation {
        
        case failure(SelectedCategoryFailure)
        case destination(Destination)
        case outside(Outside)
    }
    
    enum Destination {
        
        case mobile(Mobile)
        case taxAndStateServices(Tax)
        case transport(Transport)
        
        typealias Mobile = PaymentsViewModel
        typealias Tax = PaymentsViewModel
        typealias Transport = TransportPaymentsViewModel
    }
    
    enum Outside {
        
        case qr
        case standard(ServiceCategory)
    }
}
