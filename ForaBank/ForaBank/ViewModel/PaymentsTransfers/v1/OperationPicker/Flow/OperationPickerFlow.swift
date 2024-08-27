//
//  OperationPickerFlow.swift
//  ForaBank
//
//  Created by Igor Malyarov on 22.08.2024.
//

import PayHubUI

typealias OperationPickerFlow = PayHubUI.OperationPickerFlow<ExchangeStub, Latest, LatestFlowStub, OperationPickerFlowStatus, TemplatesStub>

final class ExchangeStub {}
final class LatestFlowStub {}
final class TemplatesStub {}

enum OperationPickerFlowStatus: Equatable {
    
    case main
}
