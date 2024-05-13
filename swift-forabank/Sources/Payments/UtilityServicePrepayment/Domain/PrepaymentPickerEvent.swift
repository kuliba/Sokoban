//
//  PrepaymentPickerEvent.swift
//
//
//  Created by Дмитрий Савушкин on 19.02.2024.
//

public enum PrepaymentPickerEvent<Operator>
where Operator: Identifiable {
    
    case didScrollTo(Operator.ID)
    case load([Operator])
    case page([Operator])
    case search(String)
}

extension PrepaymentPickerEvent: Equatable where Operator: Equatable {}
