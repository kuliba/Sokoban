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

private typealias PPOReducer = PrePaymentOptionsReducer<LastPayment, Operator>
private typealias FlowReducer = UtilityPaymentFlowReducer<LastPayment, Operator, StartPayment, UtilityService>
private typealias UtilityReducer = UtilityFlowReducer<LastPayment, Operator, UtilityService, StartPayment>
private typealias Reducer = PaymentsTransfersReducer<LastPayment, Operator, UtilityService, StartPayment>

private typealias PPOEffectHandler = PrePaymentOptionsEffectHandler<LastPayment, Operator>
private typealias PPEffectHandler = PrePaymentEffectHandler<LastPayment, Operator, StartPayment, UtilityService>
private typealias UtilityEffectHandler = UtilityFlowEffectHandler<LastPayment, Operator, UtilityService, StartPayment>
private typealias EffectHandler = PaymentsTransfersEffectHandler<LastPayment, Operator, UtilityService, StartPayment>

extension PaymentsTransfersViewModel {
    
    static func `default`(
        initialState: PaymentsTransfersState = .init(),
        flowSettings: FlowSettings = .happy,
        debounce: DispatchTimeInterval = .milliseconds(300),
        scheduler: AnySchedulerOf<DispatchQueue> = .main
    ) -> PaymentsTransfersViewModel {
        
        let prePaymentOptionsReducer = PPOReducer(observeLast: 3, pageSize: 10)
        
        let utilityPaymentFlowReducer = FlowReducer(
            prePaymentOptionsReduce: prePaymentOptionsReducer.reduce
        )
        
        let utilityReducer = UtilityReducer()
        
        let reducer = Reducer(
            utilityReduce: utilityReducer.reduce
        )
        
        let loadLastPayments: PPOEffectHandler.LoadLastPayments = { completion in
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                
                completion(flowSettings.loadLastPayments.result)
            }
        }
        
        let loadOperators: PPOEffectHandler.LoadOperators = { payload, completion in
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                
                completion(flowSettings.loadOperators.result)
            }
        }
        
        let ppoEffectHandler = PPOEffectHandler(
            debounce: debounce,
            loadLastPayments: loadLastPayments,
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
        
        let ppEffectHandler = PPEffectHandler(
            loadServices: loadServices,
            startPayment: startPayment
        )
                
        let loadOptions: UtilityEffectHandler.LoadOptions = { completion in
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                
                completion(flowSettings.loadOptions.result)
            }
        }
        
        let startPayment2: UtilityEffectHandler.StartPayment = { payload, completion in
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                
                completion(payload.response)
            }
        }
        
        let utilityFlowEffectHandler = UtilityEffectHandler(
            loadOptions: loadOptions,
            loadServices: loadServices,
            startPayment: startPayment2
        )
        
        let effectHandler = PaymentsTransfersEffectHandler(
            utilityFlowHandleEffect: utilityFlowEffectHandler.handleEffect
        )
        
        return .init(
            initialState: initialState,
            paymentsTransfersReduce: reducer.reduce,
            paymentsTransfersHandleEffect: effectHandler.handleEffect,
            scheduler: scheduler
        )
    }
}

private extension FlowSettings.LoadLastPayments {
    
    var result: PPOEffectHandler.LoadLastPaymentsResult {
        
        switch self {
        case .failure:
            return .failure(.connectivityError)
            
        case .success:
            return .success(.init())
        }
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

private extension FlowSettings.LoadOptions {
    
    var result: UtilityEffectHandler.LoadOptionsResult {
        
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
