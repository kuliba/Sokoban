//
//  UtilityPayment.swift
//
//
//  Created by Igor Malyarov on 04.03.2024.
//

public struct UtilityPayment: Equatable {
    
#warning("TBD")
    // snapshots stack
    // fields
    
    public var isFinalStep: Bool
    public var verificationCode: VerificationCode?
    public var status: Status?
    
    public init(
        isFinalStep: Bool = false,
        verificationCode: VerificationCode? = nil,
        status: Status? = nil
    ) {
        self.isFinalStep = isFinalStep
        self.verificationCode = verificationCode
        self.status = status
    }
}

public extension UtilityPayment {
    
    enum Status {
        
        case inflight
    }
}
