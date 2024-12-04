//
//  SelectedCategoryNavigation.swift
//  ForaBank
//
//  Created by Igor Malyarov on 28.09.2024.
//

import Foundation
import PayHub

enum SelectedCategoryNavigation {
    
    case failure(SelectedCategoryFailure)
    case paymentFlow(PaymentFlow)
    
    typealias Mobile = ClosePaymentsViewModelWrapper
    typealias Standard = StandardSelectedCategoryDestination
    typealias QR = Void // it's up to root to handle QR
    typealias Tax = ClosePaymentsViewModelWrapper
    typealias Transport = TransportPaymentsViewModel
    
    typealias PaymentFlow = PayHub.PaymentFlow<Mobile, QR, Standard, Tax, Transport>
}

struct SelectedCategoryFailure: Error, Equatable, Identifiable {
    
    let id: UUID
    let message: String
}

typealias StandardSelectedCategoryDestination = Result<PaymentProviderPickerDomain.Binder, FailedPaymentProviderPickerStub>

final class FailedPaymentProviderPickerStub: Error {}
