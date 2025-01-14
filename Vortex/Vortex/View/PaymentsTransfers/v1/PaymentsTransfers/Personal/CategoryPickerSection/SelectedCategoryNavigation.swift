//
//  SelectedCategoryNavigation.swift
//  Vortex
//
//  Created by Igor Malyarov on 28.09.2024.
//

import Foundation
import PayHub

enum SelectedCategoryNavigation {
    
    case failure(SelectedCategoryFailure)
    case paymentFlow(PaymentFlow)
    
    typealias PaymentFlow = PayHub.PaymentFlow<Mobile, QR, Standard, Tax, Transport>
    
    typealias Mobile = ClosePaymentsViewModelWrapper
    
    enum Standard {
        
        // picker view will handle destination
        case destination(StandardSelectedCategoryDestination)
        // root will handle it from category picker section
        case category(ServiceCategory)
    }
    
    typealias QR = Void // it's up to root to handle QR
    typealias Tax = ClosePaymentsViewModelWrapper
    typealias Transport = TransportPaymentsViewModel
}

struct SelectedCategoryFailure: Error, Equatable, Identifiable {
    
    let id: UUID
    let message: String
}
