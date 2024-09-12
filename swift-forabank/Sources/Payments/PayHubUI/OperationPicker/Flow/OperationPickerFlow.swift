//
//  OperationPickerFlow.swift
//
//
//  Created by Igor Malyarov on 26.08.2024.
//

import PayHub
import RxViewModel

public typealias OperationPickerFlow<Exchange, Latest, LatestFlow, Status, Templates> = RxViewModel<OperationPickerFlowState<Exchange, LatestFlow, Status, Templates>, OperationPickerFlowEvent<Exchange, Latest, LatestFlow, Status, Templates>, OperationPickerFlowEffect<Latest>>
