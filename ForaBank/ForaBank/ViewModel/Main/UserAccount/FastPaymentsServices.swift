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
    let getConsentAndDefault: GetConsentAndDefault
}

extension FastPaymentsServices {
    
    typealias FPSCFLResponsePublisher = AnyPublisher<FPSCFLResponse, Never>
    typealias GetFastPaymentContractFindList = () -> FPSCFLResponsePublisher
    
#warning("change to typed Error")
    typealias GetConsentAndDefaultResult = Result<ConsentAndDefault, Error>
    typealias GetConsentAndDefaultCompletion = (GetConsentAndDefaultResult) -> Void
    typealias GetConsentAndDefault = (Phone, @escaping GetConsentAndDefaultCompletion) -> Void
    
    typealias Phone = Tagged<_Phone, String>
    enum _Phone {}
    
    typealias DefaultForaBank = Tagged<_DefaultForaBank, Bool>
    enum _DefaultForaBank {}
    
    /// `FPSCFL` stands for `FastPaymentContractFindList`
    enum FPSCFLResponse: Equatable {
        
        case contract(Contract)
        case noContract
        case error(String)
        
        struct Contract: Equatable {
 
            let phone: Phone
            let status: Status
            
            enum Status: Equatable {
                
                case active
                case inactive
            }
        }
    }
    
    struct ConsentAndDefault {
        
        let consentList: [BankID]
        let defaultForaBank: DefaultForaBank
        
        typealias BankID = Tagged<_BankID, String>
        enum _BankID {}
    }
}
