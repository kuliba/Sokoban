//
//  SelectedCategoryDestination.swift
//  ForaBank
//
//  Created by Igor Malyarov on 03.09.2024.
//

import PayHub

typealias SelectedCategoryDestination = PayHub.PaymentFlow<MobileBinderStub, QRBinderStub, StandardSelectedCategoryDestination, TaxBinderStub, TransportBinderStub>

final class MobileBinderStub {}
final class QRBinderStub {}

typealias StandardSelectedCategoryDestination = Result<SelectedCategoryStub, Error>

final class TaxBinderStub {}
final class TransportBinderStub {}
