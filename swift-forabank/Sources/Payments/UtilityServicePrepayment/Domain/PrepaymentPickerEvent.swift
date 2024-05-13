//
//  PrepaymentPickerEvent.swift
//
//
//  Created by Дмитрий Савушкин on 19.02.2024.
//

public enum PrepaymentPickerEvent<OperatorID> {
    
    case didScrollTo(OperatorID)
}

extension PrepaymentPickerEvent: Equatable where OperatorID: Equatable {}
