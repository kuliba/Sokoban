//
//  FlowEffect.swift
//
//
//  Created by Igor Malyarov on 23.08.2024.
//

public enum FlowEffect<Select> {
    
    case select(Select)
}

extension FlowEffect: Equatable where Select: Equatable {}
