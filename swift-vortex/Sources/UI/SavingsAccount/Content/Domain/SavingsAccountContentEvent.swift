//
//  SavingsAccountContentEvent.swift
//  
//
//  Created by Andryusina Nataly on 03.12.2024.
//

import Foundation

public enum SavingsAccountContentEvent<Landing, InformerPayload> {
    
    case dismissInformer(Landing?)
    case getVerificationCode
    case verificationCode(GetVerificationCodeResult)
    case failure(BackendFailure<InformerPayload>)
    case load
    case loaded(Landing)
    case offset(CGFloat)
}

public extension SavingsAccountContentEvent {
    
    typealias GetVerificationCodeResult = Result<Int, BackendFailure<InformerPayload>>
}

extension SavingsAccountContentEvent: Equatable where Landing: Equatable, InformerPayload: Equatable {}
