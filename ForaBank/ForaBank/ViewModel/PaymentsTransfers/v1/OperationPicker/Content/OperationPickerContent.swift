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

typealias OperationPickerPickerState = LoadablePickerState<UUID, OperationPickerItem<Latest>>
typealias OperationPickerEvent = LoadablePickerEvent<OperationPickerItem<Latest>>
typealias OperationPickerEffect = LoadablePickerEffect

typealias OperationPickerReducer = LoadablePickerReducer<UUID, OperationPickerItem<Latest>>
typealias OperationPickerEffectHandler = LoadablePickerEffectHandler<OperationPickerItem<Latest>>

typealias OperationPickerContent = RxViewModel<OperationPickerPickerState, OperationPickerEvent, OperationPickerEffect>
