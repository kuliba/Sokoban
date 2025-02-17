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
    
    enum Select {
     
        case category(ServiceCategory)
        case qr
    }
    
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
        
        enum Tax {
            
            case legacy(PaymentsViewModel)
            case v1(Node<TaxPaymentsDomain.Binder>)
        }
        
        typealias Transport = TransportPaymentsViewModel
    }
    
    enum Outside {
        
        case qr
        case standard(ServiceCategory)
        case searchByUIN
    }
}

/// A namespace.
enum TaxPaymentsDomain {}

extension TaxPaymentsDomain {
    
    // MARK: Binder
    
    typealias Binder = Vortex.Binder<Content, Flow>
    
    // MARK: - Content
    
    typealias Content = PaymentsViewModel
    
    // MARK: - Flow
    
    typealias FlowDomain = Vortex.FlowDomain<Select, Navigation>
    typealias Flow = FlowDomain.Flow
    typealias Notify = FlowDomain.Notify
    
    enum Select {
    
        case searchByUIN
    }
 
    enum Navigation {
        
        case searchByUIN
    }
}
