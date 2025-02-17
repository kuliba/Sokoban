//
//  QRNavigationDomain.swift
//  
//
//  Created by Igor Malyarov on 08.11.2024.
//

import FlowCore
import PayHub

/// A namespace.
public enum QRNavigationDomain<ConfirmSberQR, MixedPicker, MultiplePicker, Operator, OperatorModel, Payments, Provider, QRCode, QRFailure, QRMapping, ServicePicker, Source, SearchByUIN>
 {}

public extension QRNavigationDomain {
    
    typealias FlowDomain = FlowCore.FlowDomain<Select, Navigation>
    typealias Notify = (FlowDomain.NotifyEvent) -> Void
    
    enum Select {
        
        case outside(Outside)
        case qrResult(QRResult)
        
        public enum Outside {
            
            case chat, main, payments
        }

        public typealias QRResult = PayHub.QRResult<QRCode, QRMappedResult>
        public typealias QRMappedResult = PayHub.QRMappedResult<Operator, Provider, QRCode, QRMapping, Source>
    }
    
    enum Navigation {
        
        case outside(Outside)
        case qrNavigation(QRNavigation)
        
        public enum Outside {
            
            case chat, main, payments
        }
        
        public typealias QRNavigation = PayHubUI.QRNavigation<ConfirmSberQR, MixedPicker, MultiplePicker, OperatorModel, Payments, QRFailure, ServicePicker, SearchByUIN>
    }
}
