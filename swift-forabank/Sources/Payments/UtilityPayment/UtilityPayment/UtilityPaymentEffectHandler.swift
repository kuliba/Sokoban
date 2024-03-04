//
//  UtilityPaymentEffectHandler.swift
//
//
//  Created by Igor Malyarov on 02.03.2024.
//

public final class UtilityPaymentEffectHandler {
    
    private let makeTransfer: MakeTransfer
    
    public init(
        makeTransfer: @escaping MakeTransfer
    ) {
        self.makeTransfer = makeTransfer
    }
}

public extension UtilityPaymentEffectHandler {
    
    func handleEffect(
        _ effect: Effect,
        _ dispatch: @escaping Dispatch
    ) {
        switch effect {
        case let .makeTransfer(verificationCode):
            makeTransfer(verificationCode) {
                
                dispatch(.receivedTransferResult(
                    $0.mapError { _ in
                        
                        TransactionFailure.transferError
                    }
                ))
            }
        }
    }
}

public extension UtilityPaymentEffectHandler {
    
    typealias MakeTransferPayload = VerificationCode
    typealias MakeTransferResult = Result<Transaction, Error>
    typealias MakeTransferCompletion = (MakeTransferResult) -> Void
    typealias MakeTransfer = (MakeTransferPayload, @escaping MakeTransferCompletion) -> Void
    
    typealias Dispatch = (Event) -> Void
    
    typealias Event = UtilityPaymentEvent
    typealias Effect = UtilityPaymentEffect
}
