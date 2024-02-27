//
//  PaymentsTransfersNavigationStateManager.swift
//  ForaBank
//
//  Created by Igor Malyarov on 27.02.2024.
//

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

enum PaymentsTransfersEvent {
    
    case addCompany
    case latestPaymentTap(UtilitiesViewModel.LatestPayment)
    case loaded(GetOperatorsListByParamResponse, for: UtilitiesViewModel.Operator)
    case operatorTap(UtilitiesViewModel.Operator)
    case payByRequisites
    case paymentStarted(PaymentStarted)
    case resetUtilityDestination
    case utilityServiceTap(UtilitiesViewModel.Operator, UtilityService)
}

extension PaymentsTransfersEvent {
    
    enum GetOperatorsListByParamResponse {
        
        // `d3/d4/d5`
        case failure
        // `d1` TODO: replace with NonEmpty
        case list([UtilityService])
        // `d2` https://shorturl.at/csvCT
        case single(UtilityService)
    }
    
    enum PaymentStarted {
        
        // `e1` https://shorturl.at/jlmJ9
        case details(PaymentDetails)
        // `e2`
        case serverError(String)
        // `e3`, `e4`
        case failure
        
        struct PaymentDetails {
            
            #warning("TBD")
        }
    }
}

enum PaymentsTransfersEffect {
    
    case getServicesFor(UtilitiesViewModel.Operator)
    case startPayment(UtilitiesViewModel.Operator, UtilityService)
}

// MARK: - Preview Content

extension PaymentsTransfersNavigationStateManager {
    
    static let preview: Self = .init(
        reduce: { state, _ in (state, nil) },
        handleEffect: { _,_ in }
    )
}
