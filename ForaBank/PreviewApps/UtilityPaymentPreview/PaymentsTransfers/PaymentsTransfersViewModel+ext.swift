//
//  PaymentsTransfersViewModel+ext.swift
//  UtilityPaymentPreview
//
//  Created by Igor Malyarov on 03.03.2024.
//

import Foundation
import UtilityPayment

extension PaymentsTransfersViewModel {
    
    static func `default`(
        initialState: PaymentsTransfersState = .init(),
        flow: Flow = .happy
    ) -> PaymentsTransfersViewModel {
        
        let prePaymentReducer = PrePaymentReducer<LastPayment, Operator, PaymentsTransfersEvent.LoadServicesResponse, UtilityService>()
        
        let reducer = PaymentsTransfersReducer(
            prePaymentReduce: prePaymentReducer.reduce
        )
        
        let loadPrePayment: PaymentsTransfersEffectHandler.LoadPrePayment = { completion in
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                
                completion(flow.loadPrePayment.result)
            }
        }
        
        let loadServices: PaymentsTransfersEffectHandler.LoadServices = { payload, completion in
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                
                completion(payload.response)
            }
        }
        
        let startPayment: PaymentsTransfersEffectHandler.StartPayment = { payload, completion in
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                
                completion(payload.response)
            }
        }
        
        let effectHandler = PaymentsTransfersEffectHandler(
            loadPrePayment: loadPrePayment,
            loadServices: loadServices,
            startPayment: startPayment
        )
        
        return .init(
            initialState: initialState,
            reduce: reducer.reduce,
            handleEffect: effectHandler.handleEffect
        )
    }
}

private extension Flow.LoadPrePayment {
    
    var result: Result<PaymentsTransfersEvent.PrePayment, SimpleServiceFailure> {
        
        switch self {
        case .success:
            return .success(.init())
            
        case .failure:
            return .failure(.init())
        }
    }
}

private extension PaymentsTransfersEffect.StartPaymentPayload {
    
    var response: PaymentsTransfersEffectHandler.Event.StartPaymentResponse {
        
        switch self {
        case let .last(lastPayment):
            switch lastPayment.id {
            case "error":
                return .failure(.serverError("Error #12345"))
                
            case "failure":
                return .failure(.connectivityError)
                
            case "success":
                return .success(.init())
                
            default:
                return .success(.init())
            }
            
        case let .service(`operator`, utilityService):
            switch utilityService.id {
            case "error":
                return .failure(.serverError("Error #12345"))
                
            case "failure":
                return .failure(.connectivityError)
                
            case "success":
                return .success(.init())
                
            default:
                return .success(.init())
            }
        }
    }
}

private extension Operator {
    
    var response: PaymentsTransfersEvent.LoadServicesResponse {
        
        switch id {
        case "list":
            return .list([.init(), .init(), .init()])
            
        case "single":
            return .single(.init())
            
        case "failure":
            return .failure
            
        default:
            return .single(.init())
        }
    }
}
