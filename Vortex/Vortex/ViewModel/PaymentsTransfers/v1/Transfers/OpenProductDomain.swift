//
//  OpenProductDomain.swift
//  Vortex
//
//  Created by Igor Malyarov on 30.01.2025.
//

/// A namespace.
enum OpenProductDomain {}

extension OpenProductDomain {
    
    // MARK: - Flow
    
    typealias FlowDomain = Vortex.FlowDomain<Select, Navigation>
    typealias Flow = FlowDomain.Flow
    typealias Notify = FlowDomain.Notify
    typealias NotifyEvent = FlowDomain.NotifyEvent
    
    enum Select {
        
        case openProduct
        case productType(OpenProductType)
    }
    
    enum Navigation {
        
        case alert(String)
        case openAccount(OpenAccountViewModel)
        case openDeposit(OpenDepositListViewModel)
        case openProduct(Node<MyProductsOpenProductView.ViewModel>)
    }
}
