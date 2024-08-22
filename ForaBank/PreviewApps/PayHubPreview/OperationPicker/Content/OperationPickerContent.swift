//
//  OperationPickerContent.swift
//  PayHubPreview
//
//  Created by Igor Malyarov on 16.08.2024.
//

import Foundation
import PayHub
import RxViewModel

typealias OperationPickerState = LoadablePickerState<UUID, OperationPickerItem<Latest>>
typealias OperationPickerEvent = LoadablePickerEvent<OperationPickerItem<Latest>>
typealias OperationPickerEffect = LoadablePickerEffect

typealias OperationPickerReducer = LoadablePickerReducer<UUID, OperationPickerItem<Latest>>
typealias OperationPickerEffectHandler = LoadablePickerEffectHandler<OperationPickerItem<Latest>>

typealias OperationPickerContent = RxViewModel<OperationPickerState, OperationPickerEvent, OperationPickerEffect>
