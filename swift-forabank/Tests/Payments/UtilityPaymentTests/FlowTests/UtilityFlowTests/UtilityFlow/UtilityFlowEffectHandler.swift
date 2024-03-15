//
//  UtilityFlowEffectHandler.swift
//  
//
//  Created by Igor Malyarov on 15.03.2024.
//

import UtilityPayment

final class UtilityFlowEffectHandler<LastPayment, Operator, StartPaymentResponse> {
    
    private let load: Load
    private let startPayment: StartPayment
    
    init(
        load: @escaping Load,
        startPayment: @escaping StartPayment
    ) {
        self.load = load
        self.startPayment = startPayment
    }
}

extension UtilityFlowEffectHandler {
    
    func handleEffect(
        _ effect: Effect,
        _ dispatch: @escaping Dispatch
    ) {
        switch effect {
        case .initiate:
            load {
                
                switch $0 {
                case .failure:
                    dispatch(.loaded(.failure))
                    
                case let .success((lastPayments, operators)):
                    if operators.isEmpty {
                        dispatch(.loaded(.failure))
                    } else {
                        dispatch(.loaded(.success(lastPayments, operators)))
                    }
                }
            }
            
        case let .startPayment(payload):
            startPayment(.init(payload)) {
                
                dispatch(.paymentStarted($0))
            }
        }
    }
}

private extension UtilityFlowEffectHandler.StartPaymentPayload {
    
    init(_ payload: UtilityFlowEffect<LastPayment, Operator>.StartPayment) {
        
        switch payload {
        case let .last(lastPayment):
            self = .last(lastPayment)
            
        case let .operator(`operator`):
            self = .operator(`operator`)
        }
    }
}

extension UtilityFlowEffectHandler {
    
    typealias LoadResponse = ([LastPayment], [Operator])
    typealias LoadResult = Result<LoadResponse, Error>
    typealias LoadCompletion = (LoadResult) -> Void
    typealias Load = (@escaping LoadCompletion) -> Void
    
    enum StartPaymentPayload {
        
        case last(LastPayment)
        case `operator`(Operator)
    }
    
    typealias StartPaymentResult = Result<StartPaymentResponse, ServiceFailure>
    typealias StartPaymentCompletion = (StartPaymentResult) -> Void
    typealias StartPayment = (StartPaymentPayload, @escaping StartPaymentCompletion) -> Void
    
    typealias Dispatch = (Event) -> Void
    
    typealias Event = UtilityFlowEvent<LastPayment, Operator, StartPaymentResponse>
    typealias Effect = UtilityFlowEffect<LastPayment, Operator>
}

extension UtilityFlowEffectHandler.StartPaymentPayload: Equatable where LastPayment: Equatable, Operator: Equatable {}
