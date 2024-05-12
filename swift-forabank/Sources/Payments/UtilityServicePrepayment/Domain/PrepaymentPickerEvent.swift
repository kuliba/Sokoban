//
//  PrepaymentPickerEvent.swift
//
//
//  Created by Дмитрий Савушкин on 19.02.2024.
//

public enum PrepaymentPickerEvent<Operator>
where Operator: Identifiable {
    
    case didScrollTo(Operator.ID)
    case page([Operator])
}

extension PrepaymentPickerEvent: Equatable where Operator: Equatable {}
