//
//  PaymentsTransfersPersonalDomain.swift
//
//
//  Created by Igor Malyarov on 28.10.2024.
//

import PayHub
import RxViewModel

/// A namespace.
public enum PaymentsTransfersPersonalDomain<QRNavigation, ScanQR> {}

public extension PaymentsTransfersPersonalDomain {
    
    // MARK: - Flow
    
    typealias FlowDomain = PayHubUI.FlowDomain<Select, Navigation>
    
    typealias Notify = (NotifyEvent) -> Void
    typealias NotifyEvent = FlowDomain.NotifyEvent
    
    enum Select {
        
        case qrNavigation(QRNavigation)
        case scanQR
    }
    
    enum Navigation {
        
        case qrNavigation(QRNavigation)
        case scanQR(ScanQR)
    }
}

extension PaymentsTransfersPersonalDomain.Select: Equatable where QRNavigation: Equatable {}
extension PaymentsTransfersPersonalDomain.Navigation: Equatable where QRNavigation: Equatable, ScanQR: Equatable {}
