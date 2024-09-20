//
//  CategoryPickerSectionDestination.swift
//  ForaBank
//
//  Created by Igor Malyarov on 03.09.2024.
//

import PayHub

typealias CategoryPickerSectionDestination = PayHub.CategoryPickerSectionDestination<SelectedCategoryDestination, CategoryListModelStub>

typealias SelectedCategoryDestination = PayHub.PaymentFlow<MobileBinderStub, QRBinderStub, StandardSelectedCategoryDestination, TaxBinderStub, TransportBinderStub>

final class MobileBinderStub {}
final class QRBinderStub {}

typealias StandardSelectedCategoryDestination = Result<SelectedCategoryStub, FailedPaymentProviderPickerStub>

final class FailedPaymentProviderPickerStub: Error {}

final class TaxBinderStub {}
final class TransportBinderStub {}
