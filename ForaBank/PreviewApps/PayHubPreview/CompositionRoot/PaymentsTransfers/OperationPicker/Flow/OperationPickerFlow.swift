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

typealias OperationPickerElement = PayHub.OperationPickerElement<Latest>
typealias OperationPickerNavigation = PayHub.OperationPickerNavigation<Exchange, LatestFlow, Status, Templates>

typealias OperationPickerFlowReducer = PayHub.PickerFlowReducer<OperationPickerElement, OperationPickerNavigation>
typealias OperationPickerFlowEffectHandler = PayHub.PickerFlowEffectHandler<OperationPickerElement, OperationPickerNavigation>

typealias OperationPickerFlow = PayHubUI.OperationPickerFlow<Exchange, Latest, LatestFlow, Status, Templates>
