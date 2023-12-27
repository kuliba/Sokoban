//
//  FastPaymentsServices.swift
//  ForaBank
//
//  Created by Igor Malyarov on 26.12.2023.
//

import Combine
import Tagged

struct FastPaymentsServices {
    
    typealias FPSCFLResponsePublisher = AnyPublisher<FPSCFLResponse, Never>
    typealias GetFastPaymentContractFindList = () -> FPSCFLResponsePublisher
    
    let getFastPaymentContractFindList: GetFastPaymentContractFindList
}

extension FastPaymentsServices {
    
    typealias Phone = Tagged<_Phone, String>
    enum _Phone {}
    
    /// `FPSCFL` stands for `FastPaymentContractFindList`
    enum FPSCFLResponse: Equatable {
        
        case active(Phone)
        case inactive, missing
        case error(String)
    }
}
