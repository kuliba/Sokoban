//
//  SavingsAccountContentEvent.swift
//  
//
//  Created by Andryusina Nataly on 03.12.2024.
//

import Foundation

public enum SavingsAccountContentEvent<Landing, InformerPayload> {
    
    case dismissInformer(Landing?)
    case failure(BackendFailure<InformerPayload>)
    case load
    case delayLoad
    case loaded(Landing)
    case offset(CGFloat)
}

extension SavingsAccountContentEvent: Equatable where Landing: Equatable, InformerPayload: Equatable {}
