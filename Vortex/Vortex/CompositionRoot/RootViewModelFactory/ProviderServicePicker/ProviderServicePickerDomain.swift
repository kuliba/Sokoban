//
//  ProviderServicePickerDomain.swift
//  Vortex
//
//  Created by Igor Malyarov on 29.12.2024.
//

import VortexTools

/// A nameSpace.
enum ProviderServicePickerDomain {}

extension ProviderServicePickerDomain {
    
    // MARK: - Binder
    
    typealias Binder = Vortex.Binder<Content, Flow>
    
    // MARK: - Content
    
    struct Content: Equatable {
        
        let provider: Provider
        let services: Services
        
        typealias Provider = UtilityPaymentOperator
        typealias Services = MultiElementArray<UtilityService>
    }
    
    // MARK: - Flow
    
    typealias FlowDomain = Vortex.FlowDomain<Select, Navigation>
    typealias Flow = FlowDomain.Flow
    
    typealias Notify = FlowDomain.Notify
    typealias NotifyEvent = FlowDomain.NotifyEvent
    
    enum Select: Equatable {
    
        case outside(Outside)
        case service(ServicePayload)
        
        struct ServicePayload: Equatable {
            
            let item: ServicePickerItem
            let `operator`: UtilityPaymentOperator
        }
    }
    
    enum Outside: Equatable {
        
        case main, payments
    }
    
    enum Navigation {
        
        case outside(Outside)
        case failure(ServiceFailureAlert.ServiceFailure)
        case payment(Node<AnywayFlowModel>)
    }
}
