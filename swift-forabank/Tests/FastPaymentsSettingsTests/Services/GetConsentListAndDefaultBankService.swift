//
//  GetConsentListAndDefaultBankService.swift
//  
//
//  Created by Igor Malyarov on 30.12.2023.
//

protocol GetConsentListAndDefaultBankService {
    
    typealias Completion = (GetConsentListAndDefaultBankResults) -> Void
    
    func process(
        _ payload: PhoneNumber,
        completion: @escaping Completion
    )
}
