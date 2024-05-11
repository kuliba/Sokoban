//
//  PaymentsTransfersNavigationStateManager.swift
//  ForaBank
//
//  Created by Igor Malyarov on 27.02.2024.
//

import Foundation
import OperatorsListComponents
#warning("remove file")
struct PaymentsTransfersNavigationStateManager {
    
    // TODO: - move into reduce in the Composition
    let utilityPaymentReduce: UtilityPaymentReduce
    
    let reduce: Reduce
    let handleEffect: HandleEffect
}

extension PaymentsTransfersNavigationStateManager {
    
    typealias UtilityPaymentDispatch = (UtilityPaymentEvent) -> Void
    
    typealias UtilityPaymentReduce = (UtilityPaymentState, UtilityPaymentEvent) -> (UtilityPaymentState, UtilityPaymentEffect?)
    typealias UtilityPaymentEffectHandler = (UtilityPaymentEffect, @escaping UtilityPaymentDispatch) -> Void
    
    typealias Dispatch = (Event) -> Void
    
    typealias Reduce = (State, Event) -> (State, Effect?)
    typealias HandleEffect = (Effect, @escaping Dispatch) -> Void
}

extension PaymentsTransfersNavigationStateManager {
    
    typealias State = PaymentsTransfersViewModel.Route
    typealias Event = PaymentsTransfersEvent
    typealias Effect = PaymentsTransfersEffect
}

// MARK: - Event

enum PaymentsTransfersEvent: Equatable {
    
    case addCompany
    case resetDestination
    case resetModal
    case resetUtilityDestination
    case resetUtilityListDestination
    case utilityPayment(UtilityPaymentEvent)
    case utilityFlow(UtilityServicePaymentFlowEvent)
}

extension PaymentsTransfersEvent {
    
    enum UtilityServicePaymentFlowEvent: Equatable {
        
        case loaded(GetOperatorsListByParamResponse, for: Operator)
        case payByInstructions
        case paymentStarted(PaymentStarted)
        case select(Select<LatestPayment, Operator>)
    }
}

extension PaymentsTransfersEvent.UtilityServicePaymentFlowEvent {
    
    enum GetOperatorsListByParamResponse: Equatable {
        
        // `d3/d4/d5`
        case failure
        // `d1` TODO: replace with NonEmpty
        case list([UtilityService])
        // `d2` https://shorturl.at/csvCT
        case single(UtilityService)
    }
    
    typealias LatestPayment = OperatorsListComponents.LastPayment
    typealias Operator = OperatorsListComponents.Operator
    
    enum PaymentStarted: Equatable {
        
        // `e1` https://shorturl.at/jlmJ9
        case details(PaymentDetails)
        // `e3`, `e4`
        case failure
        // `e2`
        case serverError(String)
    }
    
    enum Select<LatestPayment, Operator> {
        
        case latestPayment(LatestPayment)
        case `operator`(Operator)
        case service(UtilityService, for: Operator)
    }
}

extension PaymentsTransfersEvent.UtilityServicePaymentFlowEvent.PaymentStarted {
    
    struct PaymentDetails: Equatable {
        
        let value: String
        
        init(value: String = UUID().uuidString) {
            
            self.value = value
        }
    }
}

extension PaymentsTransfersEvent.UtilityServicePaymentFlowEvent.Select: Equatable where LatestPayment: Equatable, Operator: Equatable {}


// MARK: - Effect

enum PaymentsTransfersEffect: Equatable {
    
    case utilityFlow(UtilityServicePaymentFlowEffect)
    case utilityPayment(UtilityPaymentEffect)
}

extension PaymentsTransfersEffect {
    
    enum UtilityServicePaymentFlowEffect: Equatable {
        
        case getServicesFor(Operator)
        case startPayment(StartPaymentPayload<LatestPayment, Operator>)
    }
}

extension PaymentsTransfersEffect.UtilityServicePaymentFlowEffect {
    
    typealias LatestPayment = OperatorsListComponents.LastPayment
    typealias Operator = OperatorsListComponents.Operator
    
    enum StartPaymentPayload<LatestPayment, Operator> {
        
        case latestPayment(LatestPayment)
        case service(Operator, UtilityService)
    }
}

extension PaymentsTransfersEffect.UtilityServicePaymentFlowEffect.StartPaymentPayload: Equatable where LatestPayment: Equatable, Operator: Equatable {}

// MARK: - Preview Content

extension PaymentsTransfersNavigationStateManager {
    
    static let preview: Self = .init(
        utilityPaymentReduce: { state, _ in (state, nil) },
        reduce: { state, _ in (state, nil) },
        handleEffect: { _,_ in }
    )
}
