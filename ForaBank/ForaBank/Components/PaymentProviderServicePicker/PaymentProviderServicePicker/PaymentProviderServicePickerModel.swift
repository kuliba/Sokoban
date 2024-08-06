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

typealias PaymentProviderServicePickerModel = AsyncPickerModel<PaymentProviderServicePickerPayload, ServicePickerItem, PaymentProviderServicePickerResult>

struct ServicePickerItem: Equatable {
    
    let service: UtilityService
    let isOneOf: Bool
}

typealias PaymentProviderServicePickerResult = Result<AnywayTransactionState.Transaction, ServiceFailureAlert.ServiceFailure>
