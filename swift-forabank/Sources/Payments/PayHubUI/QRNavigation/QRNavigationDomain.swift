//
//  QRNavigationDomain.swift
//  
//
//  Created by Igor Malyarov on 08.11.2024.
//

import PayHub

/// A namespace.
public enum QRNavigationDomain<MixedPicker, MultiplePicker, Operator, Provider, Payments, QRCode, QRMapping, QRFailure, Source, ServicePicker> {}

public extension QRNavigationDomain {
    
    typealias FlowDomain = PayHubUI.FlowDomain<Select, Navigation>
    typealias Notify = (FlowDomain.NotifyEvent) -> Void
    
    enum Select {
        
        case outside(Outside)
        case qrResult(QRResult)
        
        public enum Outside {
            
            case chat
        }

        public typealias QRResult = PayHub.QRResult<QRCode, QRMappedResult>
        public typealias QRMappedResult = PayHub.QRMappedResult<Operator, Provider, QRCode, QRMapping, Source>
    }
    
    enum Navigation {
        
        case outside(Outside)
        case qrNavigation(QRNavigation)
        
        public enum Outside {
            
            case chat
        }
        
        public typealias QRNavigation = PayHubUI.QRNavigation<MixedPicker, MultiplePicker, Payments, QRFailure, ServicePicker>
    }
}
