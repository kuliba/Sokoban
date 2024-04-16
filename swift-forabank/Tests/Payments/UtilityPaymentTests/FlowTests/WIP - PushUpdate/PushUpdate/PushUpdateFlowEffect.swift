//
//  PushUpdateFlowEffect.swift
//
//
//  Created by Igor Malyarov on 14.03.2024.
//

public enum PushUpdateFlowEffect<PushEffect, UpdateEffect> {
    
    case push(PushEffect)
    case update(UpdateEffect)
}

extension PushUpdateFlowEffect: Equatable where PushEffect: Equatable, UpdateEffect: Equatable {}
