//
//  FlowEffect.swift
//
//
//  Created by Igor Malyarov on 14.03.2024.
//

public enum FlowEffect<PushEffect, UpdateEffect> {
    
    case push(PushEffect)
    case update(UpdateEffect)
}

extension FlowEffect: Equatable where PushEffect: Equatable, UpdateEffect: Equatable {}
