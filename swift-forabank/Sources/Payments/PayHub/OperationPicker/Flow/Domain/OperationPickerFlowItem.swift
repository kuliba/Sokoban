//
//  OperationPickerFlowItem.swift
//
//
//  Created by Igor Malyarov on 15.08.2024.
//

public enum OperationPickerFlowItem<Exchange, Latest, Templates> {
    
    case exchange(Node<Exchange>)
    case latest(Node<Latest>)
    case templates(Node<Templates>)
}

extension OperationPickerFlowItem: Equatable where Exchange: Equatable, Latest: Equatable, Templates: Equatable {}
