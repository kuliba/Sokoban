//
//  SavingsAccountContentEvent.swift
//  
//
//  Created by Andryusina Nataly on 03.12.2024.
//

import Foundation

public enum SavingsAccountContentEvent<Landing, InformerPayload> {
    
    case delayLoad // TODO: remove
    case dismissInformer
    case load
    case offset(CGFloat) // TODO: remove
    case result(Result<Landing, BackendFailure<InformerPayload>>)
}

extension SavingsAccountContentEvent: Equatable where Landing: Equatable, InformerPayload: Equatable {}
