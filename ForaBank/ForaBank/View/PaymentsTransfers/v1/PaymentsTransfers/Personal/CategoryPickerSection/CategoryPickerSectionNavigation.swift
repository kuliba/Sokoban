//
//  CategoryPickerSectionNavigation.swift
//  ForaBank
//
//  Created by Igor Malyarov on 28.09.2024.
//

import Foundation
import PayHub

enum CategoryPickerSectionNavigation {
    
    case failure(SelectedCategoryFailure)
    case list(CategoryListModelStub)
    case paymentFlow(PaymentFlow)
    case qrFlow(QRFlow)
    
    typealias PaymentFlow = PayHub.PaymentFlow<ClosePaymentsViewModelWrapper, Node<QRModel>, StandardSelectedCategoryDestination, ClosePaymentsViewModelWrapper, TransportPaymentsViewModel>
    
    typealias QRFlow = Void
}

struct SelectedCategoryFailure: Error, Identifiable {
    
    let id: UUID
    let message: String
}

typealias StandardSelectedCategoryDestination = Result<PaymentProviderPicker.Binder, FailedPaymentProviderPickerStub>

final class FailedPaymentProviderPickerStub: Error {}
