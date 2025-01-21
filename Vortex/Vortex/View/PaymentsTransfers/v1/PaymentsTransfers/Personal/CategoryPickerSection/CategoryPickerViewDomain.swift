//
//  CategoryPickerViewDomain.swift
//  Vortex
//
//  Created by Igor Malyarov on 15.01.2025.
//

import PayHubUI

/// A namespace.
enum CategoryPickerViewDomain {}

extension CategoryPickerViewDomain {
    
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
        case standard(Standard)
        case taxAndStateServices(Tax)
        case transport(Transport)
        
        typealias Mobile = ClosePaymentsViewModelWrapper
        typealias Standard = StandardSelectedCategoryDestination
        typealias Tax = ClosePaymentsViewModelWrapper
        typealias Transport = TransportPaymentsViewModel
    }
    
    enum Outside {
        
        case qr
    }
}
