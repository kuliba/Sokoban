//
//  FastPaymentsSettingsEffectHandler+preview.swift
//  
//
//  Created by Igor Malyarov on 18.01.2024.
//

import C2BSubscriptionUI

extension FastPaymentsSettingsEffectHandler {
    
    static var preview: FastPaymentsSettingsEffectHandler {
        
        let consentListEffectHandler = ConsentListRxEffectHandler(
            changeConsentList: { _, completion in completion(.success(.init())) }
        )
        let contractEffectHandler = ContractEffectHandler(
            createContract: { _, completion in completion(.success(.active)) },
            updateContract: { _, completion in completion(.success(.active)) }
        )

        return .init(
            handleConsentListEffect: consentListEffectHandler.handleEffect(_:_:),
            handleContractEffect: contractEffectHandler.handleEffect(_:_:),
            getC2BSub: { $0(.success(.control)) },
            getSettings: { $0(.success(.active())) },
            prepareSetBankDefault: { $0(.success(())) },
            updateProduct: { _, completion in completion(.success(())) }
        )
    }
}
