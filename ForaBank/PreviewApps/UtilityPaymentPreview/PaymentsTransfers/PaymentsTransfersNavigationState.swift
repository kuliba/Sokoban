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
                switch prePaymentOptions {
                case .init():
                    return .prePaymentOptions(.failure)
                    
                default:
                    return .prePaymentOptions(.success)
                }
                
            case let .prePaymentState(prePaymentState):
                switch prePaymentState {
                case .addingCompany:
                    return .addingCompany
                    
                case .payingByInstruction:
                    return .payingByInstruction
                    
                case .scanning:
                    return .scanning
                    
                case .selected:
                    return nil
                    
                case .selecting:
                    return nil
                }
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
        
        case addingCompany
        case payingByInstruction
        case prePaymentOptions(PrePaymentOptions)
        case prePayment(PrePayment)
        case scanning
        
        var id: ID {
            
            switch self {
            case .addingCompany:
                return .addingCompany
                
            case .payingByInstruction:
                return .payingByInstruction
                
            case .prePaymentOptions:
                return .prePaymentOptions
                
            case .prePayment:
                return .prePayment
                
            case .scanning:
                return .scanning
            }
        }
        
        enum ID {
            
            case addingCompany
            case payingByInstruction
            case prePaymentOptions
            case prePayment
            case scanning
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
