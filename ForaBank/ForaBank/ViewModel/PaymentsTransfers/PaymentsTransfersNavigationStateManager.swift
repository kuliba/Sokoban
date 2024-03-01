//
//  PaymentsTransfersNavigationStateManager.swift
//  ForaBank
//
//  Created by Igor Malyarov on 27.02.2024.
//

import Foundation

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

enum PaymentsTransfersEvent: Equatable {
    
    case addCompany
    case latestPaymentTapped(UtilitiesViewModel.LatestPayment)
    case loaded(GetOperatorsListByParamResponse, for: UtilitiesViewModel.Operator)
    case operatorTapped(UtilitiesViewModel.Operator)
    case payByRequisites
    case paymentStarted(PaymentStarted)
    case resetDestination
    case resetModal
    case resetUtilityDestination
    case utilityPayment(UtilityPaymentEvent)
    case utilityServiceTap(UtilitiesViewModel.Operator, UtilityService)
}

extension PaymentsTransfersEvent {
    
    enum GetOperatorsListByParamResponse: Equatable {
        
        // `d3/d4/d5`
        case failure
        // `d1` TODO: replace with NonEmpty
        case list([UtilityService])
        // `d2` https://shorturl.at/csvCT
        case single(UtilityService)
    }
    
    enum PaymentStarted: Equatable {
        
        // `e1` https://shorturl.at/jlmJ9
        case details(PaymentDetails)
        // `e3`, `e4`
        case failure
        // `e2`
        case serverError(String)
        
        struct PaymentDetails: Equatable {
            
            let value: String
            
            init(value: String = UUID().uuidString) {
             
                self.value = value
            }
        }
    }
}

enum PaymentsTransfersEffect: Equatable {
    
    case getServicesFor(UtilitiesViewModel.Operator)
    case utilityPayment(UtilityPaymentEffect)
    case startPayment(StartPaymentPayload)
}

extension PaymentsTransfersEffect {
    
    enum StartPaymentPayload: Equatable {
        
        case latestPayment(UtilitiesViewModel.LatestPayment)
        case service(UtilitiesViewModel.Operator, UtilityService)
    }
}

// MARK: - Preview Content

extension PaymentsTransfersNavigationStateManager {
    
    static let preview: Self = .init(
        utilityPaymentReduce: { state, _ in (state, nil) },
        reduce: { state, _ in (state, nil) },
        handleEffect: { _,_ in }
    )
}
