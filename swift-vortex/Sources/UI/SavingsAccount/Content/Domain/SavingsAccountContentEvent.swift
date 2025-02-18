//
//  SavingsAccountContentEvent.swift
//  
//
//  Created by Andryusina Nataly on 03.12.2024.
//

import Foundation

public enum SavingsAccountContentEvent<Landing, InformerPayload> {
    
    case failure(BackendFailure<InformerPayload>)
    case hideInformer
    case load
    case loaded(Landing)
    case offset(CGFloat)
}

extension SavingsAccountContentEvent: Equatable where Landing: Equatable, InformerPayload: Equatable {}
