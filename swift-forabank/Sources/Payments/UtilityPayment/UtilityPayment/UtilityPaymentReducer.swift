//
//  UtilityPaymentReducer.swift
//
//
//  Created by Igor Malyarov on 02.03.2024.
//

public final class UtilityPaymentReducer<UtilityPayment, CreateAnywayTransferResponse>
where UtilityPayment: Payment,
      CreateAnywayTransferResponse: Equatable {
    
    private let update: Update
    
    public init(update: @escaping Update) {
        
        self.update = update
    }
}

public extension UtilityPaymentReducer {
    
    func reduce(
        _ state: State,
        _ event: Event
    ) -> (State, Effect?) {
        
        var state = state
        var effect: Effect?
        
        switch (state, event) {
        case let (.payment(utilityPayment), _):
            (state, effect) = reduce(utilityPayment, event)
            
        case (.result, _):
            break
        }
        
        return (state, effect)
    }
}

public protocol Payment: Equatable {
    
    var isFinalStep: Bool { get }
    var verificationCode: VerificationCode? { get }
    var status: PaymentStatus? { get set }
}

public enum PaymentStatus {
    
    case inflight
}

public extension UtilityPaymentReducer {
    
    typealias Update = (inout UtilityPayment, CreateAnywayTransferResponse) -> Void
    
    typealias State = UtilityPaymentState<UtilityPayment>
    typealias Event = UtilityPaymentEvent<CreateAnywayTransferResponse>
    typealias Effect = UtilityPaymentEffect<UtilityPayment>
}

private extension UtilityPaymentReducer {
    
    func reduce(
        _ utilityPayment: UtilityPayment,
        _ event: Event
    ) -> (State, Effect?) {
        
        var state: State = .payment(utilityPayment)
        var utilityPayment = utilityPayment
        var effect: Effect?
        
        switch event {
        case .continue:
            if utilityPayment.isFinalStep {
                if let verificationCode = utilityPayment.verificationCode {
                    utilityPayment.status = .inflight
                    state = .payment(utilityPayment)
                    effect = .makeTransfer(verificationCode)
                }
            } else {
                utilityPayment.status = .inflight
                state = .payment(utilityPayment)
                effect = .createAnywayTransfer(utilityPayment)
            }
            
        case let .fraud(fraudEvent):
            switch fraudEvent {
            case .cancelled:
                state = .result(.failure(.fraud(.cancelled)))
            case .expired:
                state = .result(.failure(.fraud(.expired)))
            }
            
        case let .receivedAnywayResult(anywayResult):
            switch anywayResult {
            case .failure(.connectivityError):
                state = .result(.failure(.transferError))
                
            case let .failure(.serverError(message)):
                state = .result(.failure(.serverError(message)))
                
            case let .success(response):
                update(&utilityPayment, response)
                utilityPayment.status = .none
                state = .payment(utilityPayment)
            }
            
        case let .receivedTransferResult(transferResult):
            state = .result(transferResult)
        }
        
        return (state, effect)
    }
}
