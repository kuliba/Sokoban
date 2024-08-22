//
//  PayHubPickerFlow.swift
//  PayHubPreview
//
//  Created by Igor Malyarov on 21.08.2024.
//

import PayHub
import RxViewModel

typealias PayHubPickerFlowState = PayHub.PayHubPickerFlowState<Exchange, LatestFlow, Status, Templates>
typealias PayHubPickerFlowEvent = PayHub.PayHubPickerFlowEvent<Exchange, Latest, LatestFlow, Status, Templates>
typealias PayHubPickerFlowEffect = PayHub.PayHubPickerFlowEffect<Latest>

typealias PayHubPickerFlowReducer = PayHub.PayHubPickerFlowReducer<Exchange, Latest, LatestFlow, Status, Templates>
typealias PayHubPickerFlowEffectHandler = PayHub.PayHubPickerFlowEffectHandler<Exchange, Latest, LatestFlow, Templates>

typealias PayHubPickerFlow = RxViewModel<PayHubPickerFlowState, PayHubPickerFlowEvent, PayHubPickerFlowEffect>
