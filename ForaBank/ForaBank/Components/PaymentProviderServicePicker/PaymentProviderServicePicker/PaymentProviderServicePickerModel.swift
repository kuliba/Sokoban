//
//  PaymentProviderServicePickerModel.swift
//  ForaBank
//
//  Created by Igor Malyarov on 24.07.2024.
//

import ForaTools
import Foundation
import RxViewModel

typealias AsyncPickerModel<Payload, Item, Response> = RxViewModel<AsyncPickerState<Payload, Item, Response>, AsyncPickerEvent<Item, Response>, AsyncPickerEffect<Payload, Item>>

typealias PaymentProviderServicePickerModel = AsyncPickerModel<PaymentProviderServicePickerPayload, UtilityService, PaymentProviderServicePickerResult>

typealias PaymentProviderServicePickerResult = Result<AnywayTransactionState.Transaction, ServiceFailureAlert.ServiceFailure>
