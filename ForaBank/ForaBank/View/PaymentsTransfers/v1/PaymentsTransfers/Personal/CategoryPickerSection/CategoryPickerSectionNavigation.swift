//
//  CategoryPickerSectionNavigation.swift
//  ForaBank
//
//  Created by Igor Malyarov on 03.09.2024.
//

import Foundation
import PayHub
import PayHubUI

typealias CategoryPickerSectionDomain = PayHubUI.CategoryPickerSectionDomain<ServiceCategory, SelectedCategoryDestination, CategoryListModelStub, SelectedCategoryFailure>

extension CategoryPickerSectionDomain {
    
    typealias Navigation = FlowState.Navigation
    typealias Destination = FlowState.Destination
}

typealias SelectedCategoryDestination = PayHub.PaymentFlow<ClosePaymentsViewModelWrapper, QRBinderStub, StandardSelectedCategoryDestination, TaxBinderStub, TransportBinderStub>

struct SelectedCategoryFailure: Error, Identifiable {
    
    let id: UUID
    let message: String
}

final class QRBinderStub {}

typealias StandardSelectedCategoryDestination = Result<PaymentProviderPicker.Binder, FailedPaymentProviderPickerStub>

final class FailedPaymentProviderPickerStub: Error {}

final class TaxBinderStub {}
final class TransportBinderStub {}
