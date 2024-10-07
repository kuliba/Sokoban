//
//  CategoryPickerSectionNavigation.swift
//  ForaBank
//
//  Created by Igor Malyarov on 28.09.2024.
//

import Foundation
import PayHub

typealias CategoryPickerSectionNavigation = SelectedCategoryNavigation<CategoryListModelStub>
typealias PlainCategoryPickerSectionNavigation = SelectedCategoryNavigation<Never>

enum SelectedCategoryNavigation<List> {
    
    case failure(SelectedCategoryFailure)
    case list(List)
    case paymentFlow(PaymentFlow)
    case qrNavigation(QRNavigation)
    
    typealias PaymentFlow = PayHub.PaymentFlow<ClosePaymentsViewModelWrapper, Node<QRModel>, StandardSelectedCategoryDestination, ClosePaymentsViewModelWrapper, TransportPaymentsViewModel>
    
    typealias QRNavigation = Void
}

struct SelectedCategoryFailure: Error, Identifiable {
    
    let id: UUID
    let message: String
}

typealias StandardSelectedCategoryDestination = Result<PaymentProviderPicker.Binder, FailedPaymentProviderPickerStub>

final class FailedPaymentProviderPickerStub: Error {}
