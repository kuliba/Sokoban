//
//  FastPaymentsSettingsEffectHandler+preview.swift
//  FastPaymentsSettingsPreview
//
//  Created by Igor Malyarov on 18.01.2024.
//

import FastPaymentsSettings

extension FastPaymentsSettingsEffectHandler {
    
    static var preview: FastPaymentsSettingsEffectHandler {
        
        let consentListEffectHandler = ConsentListRxEffectHandler(
            changeConsentList: { _, completion in completion(.success) }
        )
        let contractEffectHandler = ContractEffectHandler(
            createContract: { _, completion in completion(.success(.active)) },
            updateContract: { _, completion in completion(.success(.active)) }
        )

        return .init(
            handleConsentListEffect: consentListEffectHandler.handleEffect(_:_:),
            handleContractEffect: contractEffectHandler.handleEffect(_:_:),
            getSettings: { $0(.active()) },
            prepareSetBankDefault: { $0(.success(())) },
            updateProduct: { _, completion in completion(.success(())) }
        )
    }
}
