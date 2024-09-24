//
//  SegmentedPaymentProviderPickerModel.swift
//  ForaBank
//
//  Created by Igor Malyarov on 01.08.2024.
//

import RxViewModel

typealias SegmentedPaymentProviderPickerModel<Operator> = RxViewModel<SegmentedPaymentProviderPickerState<Operator>, SegmentedPaymentProviderPickerEvent<Operator>, SegmentedPaymentProviderPickerEffect>
