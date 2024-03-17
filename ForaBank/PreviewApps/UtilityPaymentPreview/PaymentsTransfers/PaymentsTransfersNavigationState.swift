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
                
            case let .prepayment(prepayment):
                switch prepayment {
                case .failure:
                    return .prePaymentOptions(.failure)
                    
                case let .options(options):
                    switch options.operators {
                    case .none:
                        return .prePaymentOptions(.failure)
                        
                    case let .some(operators):
                        return .prePaymentOptions(.success)
                    }
                }
                
            default:
                fatalError()
            }
        }
    }
}

extension PaymentsTransfersState {
    
    enum NavigationState: Identifiable {
        
        case payingByInstruction
        case prePaymentOptions(PrepaymentOptions)
        case prePayment(Prepayment)
        case scanning
        
        var id: ID {
            
            switch self {
            case .payingByInstruction:
                return .payingByInstruction
                
            case .prePaymentOptions:
                return .prepaymentOptions
                
            case .prePayment:
                return .prepayment
                
            case .scanning:
                return .scanning
            }
        }
        
        enum ID {
            
            case payingByInstruction
            case prepaymentOptions
            case prepayment
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
    
    enum PrepaymentOptions {
        
        case failure
        case success
    }
    
    enum Prepayment {
        
        case failure
        case success
    }
}
