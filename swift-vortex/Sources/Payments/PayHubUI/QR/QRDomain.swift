//
//  QRDomain.swift
//
//
//  Created by Igor Malyarov on 28.10.2024.
//

import PayHub

/// A namespace/
public enum QRDomain<Navigation, QR, QRResult> {}

public extension QRDomain {
    
    // MARK: - Binder
    
    typealias Binder = PayHub.Binder<Content, Flow>
    typealias Witnesses = ContentFlowWitnesses<Content, Flow, Select, Navigation>
    
    // MARK: - Content
    
    typealias Content = QR
    
    // MARK: - Flow
    
    typealias FlowDomain = PayHubUI.FlowDomain<Select, Navigation>
    typealias Flow = FlowDomain.Flow
    
    typealias Notify = (FlowDomain.NotifyEvent) -> Void
    
    typealias Select = QRResult
}
