//
//  OperationPickerElement.swift
//
//
//  Created by Igor Malyarov on 15.08.2024.
//

public enum OperationPickerElement<Latest> {
    
    case exchange
    case latest(Latest)
    case templates
}

extension OperationPickerElement: Equatable where Latest: Equatable {}
