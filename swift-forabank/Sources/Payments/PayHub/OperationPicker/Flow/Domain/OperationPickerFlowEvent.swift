//
//  OperationPickerFlowEvent.swift
//
//
//  Created by Igor Malyarov on 05.09.2024.
//

public typealias OperationPickerFlowEvent<Exchange, Latest, LatestFlow, Status, Templates> = PickerFlowEvent<OperationPickerElement<Latest>, OperationPickerNavigation<Exchange, LatestFlow, Status, Templates>>
