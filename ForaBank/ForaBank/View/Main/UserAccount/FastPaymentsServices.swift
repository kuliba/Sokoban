//
//  FastPaymentsServices.swift
//  ForaBank
//
//  Created by Igor Malyarov on 26.12.2023.
//

import Combine

struct FastPaymentsServices {
    
    typealias FPSCFLResponsePublisher = AnyPublisher<FPSCFLResponse, Never>
    typealias GetFastPaymentContractFindList = () -> FPSCFLResponsePublisher
    
    let getFastPaymentContractFindList: GetFastPaymentContractFindList
}

extension FastPaymentsServices {
    
    /// `FPSCFL` stands for `FastPaymentContractFindList`
    enum FPSCFLResponse {
        
        case active, inactive, missing, error
    }
}
