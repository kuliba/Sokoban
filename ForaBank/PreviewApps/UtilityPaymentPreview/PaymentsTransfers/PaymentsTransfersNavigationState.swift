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
            
        case let .prePayment(prePayment):
            switch prePayment {
            case .failure:
                return .prePayment(.failure)
                
            case .success:
                return .prePayment(.success)
            }
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
}

extension PaymentsTransfersState.NavigationState {
    
    enum PrePayment {

        case failure
        case success
    }
}
