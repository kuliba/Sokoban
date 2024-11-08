//
//  QRNavigationDomain.swift
//  
//
//  Created by Igor Malyarov on 08.11.2024.
//

import PayHub

/// A namespace.
public enum _QRNavigationDomain<QRResult, QRNavigation> {}

public extension _QRNavigationDomain {
    
    typealias FlowDomain = PayHubUI.FlowDomain<Select, Navigation>
    typealias Notify = (FlowDomain.NotifyEvent) -> Void
    
    enum Select {
        
        case outside(Outside)
        case qrResult(QRResult)
        
        public enum Outside {
            
            case chat
        }
    }
    
    enum Navigation {
        
        case outside(Outside)
        case qrNavigation(QRNavigation)
        
        public enum Outside {
            
            case chat
        }
    }
}

extension _QRNavigationDomain.Select: Equatable where QRResult: Equatable, QRNavigation: Equatable {}
extension _QRNavigationDomain.Navigation: Equatable where QRResult: Equatable, QRNavigation: Equatable {}
