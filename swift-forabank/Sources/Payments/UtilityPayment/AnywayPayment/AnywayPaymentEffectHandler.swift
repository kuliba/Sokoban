//
//  AnywayPaymentEffectHandler.swift
//
//
//  Created by Igor Malyarov on 02.03.2024.
//

public final class AnywayPaymentEffectHandler<Payload, Response>
where Payload: Equatable,
      Response: Equatable {
    
    private let createAnywayTransfer: CreateAnywayTransfer
    private let makeTransfer: MakeTransfer
    
    public init(
        createAnywayTransfer: @escaping CreateAnywayTransfer,
        makeTransfer: @escaping MakeTransfer
    ) {
        self.createAnywayTransfer = createAnywayTransfer
        self.makeTransfer = makeTransfer
    }
}

public extension AnywayPaymentEffectHandler {
    
    func handleEffect(
        _ effect: Effect,
        _ dispatch: @escaping Dispatch
    ) {
        switch effect {
        case let .createAnywayTransfer(utilityPayment):
            createAnywayTransfer(utilityPayment) {
                
                dispatch(.receivedAnywayResult($0))
            }
            
        case let .makeTransfer(verificationCode):
            makeTransfer(verificationCode) {
                
                dispatch(.receivedTransferResult(
                    $0.mapError { _ in TransactionFailure.transferError }
                ))
            }
        }
    }
}

public extension AnywayPaymentEffectHandler {
    
    typealias CreateAnywayTransferPayload = Payload
    typealias CreateAnywayTransferResult = Event.AnywayResult
    typealias CreateAnywayTransferCompletion = (CreateAnywayTransferResult) -> Void
    typealias CreateAnywayTransfer = (CreateAnywayTransferPayload, @escaping CreateAnywayTransferCompletion) -> Void
    
    typealias MakeTransferPayload = VerificationCode
    typealias MakeTransferResult = Result<Transaction, Error>
    typealias MakeTransferCompletion = (MakeTransferResult) -> Void
    typealias MakeTransfer = (MakeTransferPayload, @escaping MakeTransferCompletion) -> Void
    
    typealias Dispatch = (Event) -> Void
    
    typealias Event = AnywayPaymentEvent<Response>
    typealias Effect = AnywayPaymentEffect<Payload>
}
