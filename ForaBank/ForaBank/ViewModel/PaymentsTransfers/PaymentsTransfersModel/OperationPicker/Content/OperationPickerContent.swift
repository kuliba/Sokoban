//
//  OperationPickerContent.swift
//  ForaBank
//
//  Created by Igor Malyarov on 22.08.2024.
//

import Foundation
import PayHub
import RxViewModel

typealias Latest = UtilityPaymentLastPayment

typealias OperationPickerPickerState = LoadablePickerState<UUID, PayHubPickerItem<Latest>>
typealias OperationPickerEvent = LoadablePickerEvent<PayHubPickerItem<Latest>>
typealias OperationPickerEffect = LoadablePickerEffect

typealias OperationPickerReducer = LoadablePickerReducer<UUID, PayHubPickerItem<Latest>>
typealias OperationPickerEffectHandler = LoadablePickerEffectHandler<PayHubPickerItem<Latest>>

typealias OperationPickerContent = RxViewModel<OperationPickerPickerState, OperationPickerEvent, OperationPickerEffect>
