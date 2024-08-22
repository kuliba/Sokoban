//
//  PayHubPickerContent.swift
//  PayHubPreview
//
//  Created by Igor Malyarov on 16.08.2024.
//

import Foundation
import PayHub
import RxViewModel

typealias PayHubPickerState = LoadablePickerState<UUID, OperationPickerItem<Latest>>
typealias PayHubPickerEvent = LoadablePickerEvent<OperationPickerItem<Latest>>
typealias PayHubPickerEffect = LoadablePickerEffect

typealias PayHubPickerReducer = LoadablePickerReducer<UUID, OperationPickerItem<Latest>>
typealias PayHubPickerEffectHandler = LoadablePickerEffectHandler<OperationPickerItem<Latest>>

typealias PayHubPickerContent = RxViewModel<PayHubPickerState, PayHubPickerEvent, PayHubPickerEffect>
