//
//  OperationPickerFlow.swift
//  ForaBank
//
//  Created by Igor Malyarov on 22.08.2024.
//

import PayHub
import PayHubUI

typealias OperationPickerFlowState = PayHub.OperationPickerFlowState<ExchangeStub, LatestFlowStub, OperationPickerFlowStatus, TemplatesStub>
typealias OperationPickerFlowEvent = PayHub.OperationPickerFlowEvent<ExchangeStub, Latest, LatestFlowStub, OperationPickerFlowStatus, TemplatesStub>
typealias OperationPickerFlowEffect = PayHub.OperationPickerFlowEffect<Latest>

typealias OperationPickerElement = PayHub.OperationPickerElement<Latest>
typealias OperationPickerNavigation = PayHub.OperationPickerNavigation<ExchangeStub, LatestFlowStub, OperationPickerFlowStatus, TemplatesStub>

typealias OperationPickerFlowReducer = PayHub.PickerFlowReducer<OperationPickerElement, OperationPickerNavigation>
typealias OperationPickerFlowEffectHandler = PayHub.PickerFlowEffectHandler<OperationPickerElement, OperationPickerNavigation>

typealias OperationPickerFlow = PayHubUI.OperationPickerFlow<ExchangeStub, Latest, LatestFlowStub, OperationPickerFlowStatus, TemplatesStub>

final class ExchangeStub {}

final class LatestFlowStub {
    
    let latest: Latest
    
    init(latest: Latest) {
 
        self.latest = latest
    }
}

final class TemplatesStub {}

enum OperationPickerFlowStatus: Equatable {
    
    case main
}
