//
//  PaymentsTransfersNavigationState.swift
//  UtilityPaymentPreview
//
//  Created by Igor Malyarov on 03.03.2024.
//

extension PaymentsTransfersState {
    
    var navigationState: NavigationState? {
        
        switch route {
        case let .prePayment(prePayment):
            switch prePayment {
            case .failure:
                return .prePayment(.failure)
                
            case .success:
                return .prePayment(.success)
            }
            
        case let .utilityPayment(utilityPaymentState):
            return .prePayment(.success)
            
        default:
            return .none
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
        
        case prePayment(PrePayment)
        
        var id: ID {
            
            switch self {
            case .prePayment:
                return .prePayment
            }
        }
        
        enum ID {
            
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
    
    enum PrePayment {

        case failure
        case success
    }
}
