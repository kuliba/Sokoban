//
//  SavingsAccountContentEvent.swift
//  
//
//  Created by Andryusina Nataly on 03.12.2024.
//

import Foundation

public enum SavingsAccountContentEvent<Landing, InformerPayload> {
    
    case failure(Failure)
    case load
    case loaded(Landing)
    case offset(CGFloat)
    
    public enum Failure {
        case alert(String)
        case informer(InformerPayload)
    }
}

extension SavingsAccountContentEvent: Equatable where Landing: Equatable, InformerPayload: Equatable {}

extension SavingsAccountContentEvent.Failure: Equatable where InformerPayload: Equatable {}
