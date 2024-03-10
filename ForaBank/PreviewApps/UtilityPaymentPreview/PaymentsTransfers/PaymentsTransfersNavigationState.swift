//
//  PaymentsTransfersNavigationState.swift
//  UtilityPaymentPreview
//
//  Created by Igor Malyarov on 03.03.2024.
//

extension PaymentsTransfersState {
    
    var navigationState: NavigationState? {
        
        switch route {            
        case .none:
            return .none
            
        case let .utilityPayment(utilityPaymentState):
            switch utilityPaymentState.current {
            case .none:
                return .none
                
            case let .prePaymentOptions(prePaymentOptions):
                return .prePaymentOptions(.success)
                
            case let .prePaymentState(prePaymentState):
                return .prePayment(.success)
            }
        }
    }
    
    var prePaymentNavigationState: PrePaymentNavigationState? {
        
        switch route {
        case let .utilityPayment(utilityPaymentState):
            return .utilityPayment

        default:
            return .none
        }
    }
}

extension PaymentsTransfersState {
    
    enum NavigationState: Identifiable {
        
        case prePaymentOptions(PrePaymentOptions)
        case prePayment(PrePayment)
        
        var id: ID {
            
            switch self {
            case .prePaymentOptions:
                return .prePaymentOptions
                
            case .prePayment:
                return .prePayment
            }
        }
        
        enum ID {
            
            case prePaymentOptions
            case prePayment
        }
    }
    
    enum PrePaymentNavigationState: Identifiable {
        
        case utilityPayment
        
        var id: ID {
            
            switch self {
            case .utilityPayment:
                return .utilityPayment
            }
        }
        
        enum ID {
            
            case utilityPayment
        }
    }
}

extension PaymentsTransfersState.NavigationState {
    
    enum PrePaymentOptions {

        case failure
        case success
    }
    
    enum PrePayment {

        case failure
        case success
    }
}
