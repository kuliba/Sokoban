//
//  PayHubPickerTypes.swift
//  PayHubPreview
//
//  Created by Igor Malyarov on 16.08.2024.
//

import Foundation
import PayHub
import RxViewModel

// MARK: - PayHubPicker Content

typealias PayHubPickerState = LoadablePickerState<UUID, PayHubPickerItem<Latest>>
typealias PayHubPickerEvent = LoadablePickerEvent<PayHubPickerItem<Latest>>
typealias PayHubPickerEffect = LoadablePickerEffect

typealias PayHubPickerReducer = LoadablePickerReducer<UUID, PayHubPickerItem<Latest>>
typealias PayHubPickerEffectHandler = LoadablePickerEffectHandler<PayHubPickerItem<Latest>>

typealias PayHubPickerContent = RxViewModel<PayHubPickerState, PayHubPickerEvent, PayHubPickerEffect>

// MARK: - PayHubPicker Flow

typealias PayHubPickerFlowState = PayHub.PayHubPickerFlowState<Exchange, LatestFlow, Status, Templates>
typealias PayHubPickerFlowEvent = PayHub.PayHubPickerFlowEvent<Exchange, Latest, LatestFlow, Status, Templates>
typealias PayHubPickerFlowEffect = PayHub.PayHubPickerFlowEffect<Latest>

typealias PayHubPickerFlowReducer = PayHub.PayHubPickerFlowReducer<Exchange, Latest, LatestFlow, Status, Templates>
typealias PayHubPickerFlowEffectHandler = PayHub.PayHubPickerFlowEffectHandler<Exchange, Latest, LatestFlow, Templates>

typealias PayHubPickerFlow = RxViewModel<PayHubPickerFlowState, PayHubPickerFlowEvent, PayHubPickerFlowEffect>
