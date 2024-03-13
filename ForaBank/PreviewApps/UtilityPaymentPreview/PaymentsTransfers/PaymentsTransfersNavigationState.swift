//
//  PaymentsTransfersNavigationState.swift
//  UtilityPaymentPreview
//
//  Created by Igor Malyarov on 03.03.2024.
//

extension PaymentsTransfersState {
    
    var navigationState: NavigationState? {
        
        let state = getNavigationState()
        // dump(state)
        
        return state
    }
    
    private func getNavigationState() -> NavigationState? {
        
        switch route {
        case .none:
            return .none
            
        case let .utilityFlow(utilityFlow):
            switch utilityFlow.current {
            case .none:
                return .none
                
            case let .prePaymentOptions(prePaymentOptions):
                switch prePaymentOptions.operators {
                case .none:
                    return .prePaymentOptions(.failure)
                    
                default:
                    return .prePaymentOptions(.success)
                }
                
            case let .prePaymentState(prePaymentState):
                switch prePaymentState {
                case .payingByInstruction:
                    return .payingByInstruction
                    
                case .scanning:
                    return .scanning
                    
                case .selected:
                    return nil
                    
                case let .services(services):
                    return nil
                }
                
            case .payment:
                fatalError()
            }
        }
    }
    
    var prePaymentNavigationState: PrePaymentNavigationState? {
        
        switch route {
        case let .utilityFlow(utilityPaymentState):
            return .utilityPayment
            
        default:
            return .none
        }
    }
}

extension PaymentsTransfersState {
    
    enum NavigationState: Identifiable {
        
        case payingByInstruction
        case prePaymentOptions(PrePaymentOptions)
        case prePayment(PrePayment)
        case scanning
        
        var id: ID {
            
            switch self {
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
