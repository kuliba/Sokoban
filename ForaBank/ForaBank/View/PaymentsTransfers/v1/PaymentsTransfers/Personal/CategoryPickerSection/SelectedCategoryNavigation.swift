//
//  SelectedCategoryNavigation.swift
//  ForaBank
//
//  Created by Igor Malyarov on 28.09.2024.
//

import Foundation
import PayHub

typealias CategoryPickerSectionNavigation = SelectedCategoryNavigation

enum SelectedCategoryNavigation {
    
    case failure(SelectedCategoryFailure)
    case paymentFlow(PaymentFlow)
    case qrNavigation(QRNavigation)
    
    typealias Mobile = ClosePaymentsViewModelWrapper
    typealias Standard = StandardSelectedCategoryDestination
    typealias QR = Node<QRScannerModel>
    typealias Tax = ClosePaymentsViewModelWrapper
    typealias Transport = TransportPaymentsViewModel
    
    typealias PaymentFlow = PayHub.PaymentFlow<Mobile, QR, Standard, Tax, Transport>
    
    typealias QRNavigation = ForaBank.QRNavigation
}

struct SelectedCategoryFailure: Error, Equatable, Identifiable {
    
    let id: UUID
    let message: String
}

typealias StandardSelectedCategoryDestination = Result<PaymentProviderPicker.Binder, FailedPaymentProviderPickerStub>

final class FailedPaymentProviderPickerStub: Error {}
