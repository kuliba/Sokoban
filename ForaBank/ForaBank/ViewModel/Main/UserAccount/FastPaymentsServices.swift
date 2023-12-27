//
//  FastPaymentsServices.swift
//  ForaBank
//
//  Created by Igor Malyarov on 26.12.2023.
//

import Combine
import Tagged

struct FastPaymentsServices {
    
    let getFastPaymentContractFindList: GetFastPaymentContractFindList
    let getDefaultAndConsent: GetDefaultAndConsent
}

extension FastPaymentsServices {
    
    typealias FPSCFLResponsePublisher = AnyPublisher<FPSCFLResponse, Never>
    typealias GetFastPaymentContractFindList = () -> FPSCFLResponsePublisher
    
    #warning("change to typed Error")
    typealias GetDefaultAndConsentResult = Result<DefaultForaBank, Error>
    typealias GetDefaultAndConsentCompletion = (GetDefaultAndConsentResult) -> Void
    typealias GetDefaultAndConsent = (Phone, @escaping GetDefaultAndConsentCompletion) -> Void
    
    typealias Phone = Tagged<_Phone, String>
    enum _Phone {}
    
    typealias DefaultForaBank = Tagged<_DefaultForaBank, Bool>
    enum _DefaultForaBank {}
    
    /// `FPSCFL` stands for `FastPaymentContractFindList`
    enum FPSCFLResponse: Equatable {
        
        case active(Phone)
        case inactive(Phone)
        case missing
        case error(String)
    }
}
