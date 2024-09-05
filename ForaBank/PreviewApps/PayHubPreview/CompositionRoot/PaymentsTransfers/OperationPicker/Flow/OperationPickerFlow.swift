//
//  OperationPickerFlow.swift
//  PayHubPreview
//
//  Created by Igor Malyarov on 21.08.2024.
//

import PayHub
import PayHubUI
import RxViewModel

typealias OperationPickerFlowState = PayHub.OperationPickerFlowState<Exchange, LatestFlow, Status, Templates>
typealias OperationPickerFlowEvent = PayHub.OperationPickerFlowEvent<Exchange, Latest, LatestFlow, Status, Templates>
typealias OperationPickerFlowEffect = PayHub.OperationPickerFlowEffect<Latest>

typealias OperationPickerFlowReducer = PayHub.OperationPickerFlowReducer<Exchange, Latest, LatestFlow, Status, Templates>
typealias OperationPickerFlowEffectHandler = PayHub.OperationPickerFlowEffectHandler<Exchange, Latest, LatestFlow, Templates>

typealias OperationPickerFlow = PayHubUI.OperationPickerFlow<Exchange, Latest, LatestFlow, Status, Templates>
