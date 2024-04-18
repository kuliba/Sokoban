//
//  PaymentsTransfersViewModel+ext.swift
//  UtilityPaymentPreview
//
//  Created by Igor Malyarov on 03.03.2024.
//

import CombineSchedulers
import Foundation
import PrePaymentPicker
import UtilityPayment

private typealias PPOReducer = PrepaymentOptionsReducer<LastPayment, Operator>
private typealias UtilityReducer = UtilityFlowReducer<LastPayment, Operator, UtilityService, StartPayment>
private typealias FlowReducer = PaymentsTransfersFlowReducer<LastPayment, Operator, UtilityService, StartPayment>

private typealias PPOEffectHandler = PrepaymentOptionsEffectHandler<LastPayment, Operator>
private typealias PPEffectHandler = PrePaymentEffectHandler<LastPayment, Operator, StartPayment, UtilityService>
private typealias UtilityEffectHandler = UtilityFlowEffectHandler<LastPayment, Operator, UtilityService, StartPayment>
private typealias FlowEffectHandler = PaymentsTransfersFlowEffectHandler<LastPayment, Operator, UtilityService, StartPayment>

extension PaymentsTransfersViewModel {
    
    static func `default`(
        initialState: PaymentsTransfersState = .init(),
        flowSettings: FlowSettings = .happy,
        debounce: DispatchTimeInterval = .milliseconds(300),
        scheduler: AnySchedulerOf<DispatchQueue> = .main
    ) -> PaymentsTransfersViewModel {
        
        let prepaymentOptionsReducer = PPOReducer(observeLast: 3, pageSize: 10)
        
        let utilityReducer = UtilityReducer(
            ppoReduce: prepaymentOptionsReducer.reduce(_:_:)
        )
        
        let flowReducer = FlowReducer(
            utilityReduce: utilityReducer.reduce
        )
        
        let loadOperators: PPOEffectHandler.LoadOperators = { payload, completion in
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                
                completion(flowSettings.loadOperators.result)
            }
        }
        
        let optionsEffectHandler = PPOEffectHandler(
            debounce: debounce,
            loadOperators: loadOperators,
            scheduler: scheduler
        )
        
        let loadServices: PPEffectHandler.LoadServices = { payload, completion in
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                
                completion(payload.response)
            }
        }
        
        let startPayment: PPEffectHandler.StartPayment = { payload, completion in
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                
                completion(payload.response)
            }
        }
        
        let loadPrepayment: UtilityEffectHandler.LoadPrepaymentOptions = { completion in
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                
                completion(flowSettings.loadPrepayment.result)
            }
        }
        
        let startPayment2: UtilityEffectHandler.StartPayment = { payload, completion in
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                
                completion(payload.response)
            }
        }
        
        let utilityFlowEffectHandler = UtilityEffectHandler(
            loadPrepaymentOptions: loadPrepayment,
            loadServices: loadServices,
            optionsEffectHandle: optionsEffectHandler.handleEffect,
            startPayment: startPayment2
        )
        
        let flowEffectHandler = FlowEffectHandler(
            utilityFlowHandleEffect: utilityFlowEffectHandler.handleEffect
        )
        
        return .init(
            initialState: initialState,
            flowReduce: flowReducer.reduce,
            flowHandleEffect: flowEffectHandler.handleEffect,
            scheduler: scheduler
        )
    }
}

private extension FlowSettings.LoadOperators {
    
    var result: PPOEffectHandler.LoadOperatorsResult {
        
        switch self {
        case .failure:
            return .failure(.connectivityError)
            
        case .success:
            return .success(.init())
        }
    }
}

private extension FlowSettings.LoadPrepayment {
    
    var result: UtilityEffectHandler.LoadPrepaymentOptionsResult {
        
        switch self {
        case .failure:
            return .failure(LoadOptionsError())
            
        case .success:
            return .success(([.init()], [.init()]))
        }
    }
    
    struct LoadOptionsError: Error {}
}

private extension PPEffectHandler.StartPaymentPayload {
    
    var response: PPEffectHandler.StartPaymentResult {
        
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

private extension UtilityEffectHandler.StartPaymentPayload {
    
    var response: PPEffectHandler.StartPaymentResult {
        
        switch self {
        case let .withLastPayment(lastPayment):
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
            
        case let .withService(`operator`, utilityService):
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
    
    var response: PPEffectHandler.LoadServicesResult {
        
        switch id {
        case "failure":
            return .failure(LoadServicesError())
            
        case "empty":
            return .success([.init()])
            
        case "list":
            return .success([.init(), .init(), .init()])
            
        case "single":
            return .success([.init()])
            
        default:
            return .success([.init()])
        }
    }
    
    struct LoadServicesError: Error {}
}
