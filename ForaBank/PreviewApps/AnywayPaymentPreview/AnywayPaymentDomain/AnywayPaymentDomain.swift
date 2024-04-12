//
//  AnywayPaymentDomain.swift
//  ForaBank
//
//  Created by Igor Malyarov on 12.04.2024.
//

enum AnywayEvent: Equatable {
    
    case otp(String)
}

typealias AnywayEffect = Never
