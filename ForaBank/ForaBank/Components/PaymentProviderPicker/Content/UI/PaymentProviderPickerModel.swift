//
//  PaymentProviderPickerModel.swift
//  ForaBank
//
//  Created by Igor Malyarov on 01.08.2024.
//

import RxViewModel

typealias PaymentProviderPickerModel<Operator> = RxViewModel<PaymentProviderPickerState<Operator>, PaymentProviderPickerEvent<Operator>, PaymentProviderPickerEffect>
