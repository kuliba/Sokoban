//
//  TransactionEffectHandlerNanoServicesComposer.swift
//  TransactionPreview
//
//  Created by Igor Malyarov on 19.05.2024.
//

import AnywayPaymentDomain

final class TransactionEffectHandlerNanoServicesComposer {}

extension TransactionEffectHandlerNanoServicesComposer {
    
    func compose() -> NanoServices {
        
        return .init(getDetails: getDetails, makeTransfer: makeTransfer)
    }
}

extension TransactionEffectHandlerNanoServicesComposer {
    
    typealias NanoServices = TransactionEffectHandlerNanoServices
}

extension TransactionEffectHandlerNanoServicesComposer {
    
    func getDetails(
        _ id: OperationDetailID,
        _ completion: @escaping NanoServices.GetDetailsCompletion
    ) {
#warning("FIXME")
    }
    
    func makeTransfer(
        _ code: VerificationCode,
        completion: @escaping NanoServices.MakeTransferCompletion
    ) {
#warning("FIXME")
    }
}
