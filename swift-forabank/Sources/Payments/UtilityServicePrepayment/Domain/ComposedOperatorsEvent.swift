//
//  ComposedOperatorsEvent.swift
//
//
//  Created by Дмитрий Савушкин on 19.02.2024.
//

public enum ComposedOperatorsEvent<OperatorID> {
    
    case didScrollTo(OperatorID)
}

extension ComposedOperatorsEvent: Equatable where OperatorID: Equatable {}
