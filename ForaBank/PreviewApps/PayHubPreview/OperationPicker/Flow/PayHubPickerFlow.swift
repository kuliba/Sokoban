//
//  PayHubPickerFlow.swift
//  PayHubPreview
//
//  Created by Igor Malyarov on 21.08.2024.
//

import PayHub
import RxViewModel

typealias PayHubPickerFlowState = PayHub.OperationPickerFlowState<Exchange, LatestFlow, Status, Templates>
typealias PayHubPickerFlowEvent = PayHub.OperationPickerFlowEvent<Exchange, Latest, LatestFlow, Status, Templates>
typealias PayHubPickerFlowEffect = PayHub.OperationPickerFlowEffect<Latest>

typealias PayHubPickerFlowReducer = PayHub.OperationPickerFlowReducer<Exchange, Latest, LatestFlow, Status, Templates>
typealias PayHubPickerFlowEffectHandler = PayHub.OperationPickerFlowEffectHandler<Exchange, Latest, LatestFlow, Templates>

typealias PayHubPickerFlow = RxViewModel<PayHubPickerFlowState, PayHubPickerFlowEvent, PayHubPickerFlowEffect>
