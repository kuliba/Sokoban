//
//  PaymentsTransfersNavigationStateManager.swift
//  ForaBank
//
//  Created by Igor Malyarov on 27.02.2024.
//

import Foundation

struct PaymentsTransfersNavigationStateManager {
    
    let reduce: Reduce
    let handleEffect: HandleEffect
}

extension PaymentsTransfersNavigationStateManager {
    
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
        reduce: { state, _ in (state, nil) },
        handleEffect: { _,_ in }
    )
}
