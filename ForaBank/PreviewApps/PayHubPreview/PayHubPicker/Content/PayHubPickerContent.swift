//
//  PayHubPickerContent.swift
//  PayHubPreview
//
//  Created by Igor Malyarov on 16.08.2024.
//

import Foundation
import PayHub
import RxViewModel

typealias PayHubPickerState = LoadablePickerState<UUID, PayHubPickerItem<Latest>>
typealias PayHubPickerEvent = LoadablePickerEvent<PayHubPickerItem<Latest>>
typealias PayHubPickerEffect = LoadablePickerEffect

typealias PayHubPickerReducer = LoadablePickerReducer<UUID, PayHubPickerItem<Latest>>
typealias PayHubPickerEffectHandler = LoadablePickerEffectHandler<PayHubPickerItem<Latest>>

typealias PayHubPickerContent = RxViewModel<PayHubPickerState, PayHubPickerEvent, PayHubPickerEffect>
