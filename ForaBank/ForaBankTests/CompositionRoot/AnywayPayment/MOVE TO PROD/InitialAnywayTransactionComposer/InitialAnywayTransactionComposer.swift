//
//  InitialAnywayTransactionComposer.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 11.08.2024.
//

import AnywayPaymentDomain
import RemoteServices
#warning("REMOVE AFTER MOVING TO PROD")
@testable import ForaBank

final class InitialAnywayTransactionComposer {
    
    private let isValid: IsValid
    
    init(
        isValid: @escaping IsValid
    ) {
        self.isValid = isValid
    }
    
    typealias IsValid = (AnywayPaymentContext) -> Bool
}

extension InitialAnywayTransactionComposer {
    
    struct Input: Equatable {
        
        let outline: AnywayPaymentOutline
        let firstField: AnywayElement.Field?
    }
    
    typealias Response = RemoteServices.ResponseMapper.CreateAnywayTransferResponse
    typealias Transaction = AnywayTransactionState.Transaction
    
    func compose(
        with input: Input,
        and response: Response
    ) -> Transaction? {
        
        guard let update = AnywayPaymentUpdate(response)
        else { return nil }
        
        let context = AnywayPaymentContext(
            update: update,
            outline: input.outline,
            firstField: input.firstField
        )
        
        return .init(
            context: context,
            isValid: isValid(context)
        )
    }
}
