//
//  OperationPickerItem.swift
//
//
//  Created by Igor Malyarov on 15.08.2024.
//

public enum OperationPickerItem<Latest> {
    
    case exchange
    case latest(Latest)
    case templates
}

extension OperationPickerItem: Equatable where Latest: Equatable {}
