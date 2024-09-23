//
//  OperationPickerNavigation.swift
//
//
//  Created by Igor Malyarov on 15.08.2024.
//

public enum OperationPickerNavigation<Exchange, Latest, Status, Templates> {
    
    case exchange(Exchange)
    case latest(Latest)
    case status(Status)
    case templates(Templates)
}

extension OperationPickerNavigation: Equatable where Exchange: Equatable, Latest: Equatable, Status: Equatable, Templates: Equatable {}
