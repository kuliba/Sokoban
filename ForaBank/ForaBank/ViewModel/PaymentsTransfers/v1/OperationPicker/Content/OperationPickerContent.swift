//
//  OperationPickerContent.swift
//  ForaBank
//
//  Created by Igor Malyarov on 22.08.2024.
//

import Foundation
import PayHub
import PayHubUI
import RxViewModel

typealias Latest = UtilityPaymentLastPayment

typealias OperationPickerState = PayHubUI.OperationPickerState<Latest>
typealias OperationPickerEvent = PayHubUI.OperationPickerEvent<Latest>
typealias OperationPickerEffect = PayHubUI.OperationPickerEffect

typealias OperationPickerReducer = PayHubUI.OperationPickerReducer<Latest>
typealias OperationPickerEffectHandler = PayHubUI.OperationPickerEffectHandler<Latest>

typealias OperationPickerContent = RxViewModel<OperationPickerState, OperationPickerEvent, OperationPickerEffect>
