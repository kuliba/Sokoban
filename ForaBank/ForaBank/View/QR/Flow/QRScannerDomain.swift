//
//  QRScannerDomain.swift
//  ForaBank
//
//  Created by Igor Malyarov on 19.11.2024.
//

import PayHub
import PayHubUI

/// A namespace.
enum QRScannerDomain {}

extension QRScannerDomain {
    
    // MARK: - Binder
    
    typealias Binder = PayHub.Binder<Content, Flow>
    
    // MARK: - Content
    
    typealias Content = QRScannerModel
    
    // MARK: - Flow
    
    typealias FlowDomain = PayHubUI.FlowDomain<Select, Navigation>
    typealias Flow = FlowDomain.Flow
    
    enum Select {
        
    }
    
    enum Navigation {
        
    }
}
