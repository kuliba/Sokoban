//
//  PaymentsTransfersNavigationState.swift
//  UtilityPaymentPreview
//
//  Created by Igor Malyarov on 03.03.2024.
//

import ForaTools

extension PaymentsTransfersViewModel {
    
    var navState: [State.Route.Destination] {
        
        getNavState()
    }
    
    private func getNavState() -> [State.Route.Destination] {
        
        switch state.route {
        case .none:
            return []
            
        case let .utilityFlow(utilityFlow):
            return utilityFlow.stack.elements
            
        case .other:
            return []
        }
    }
}

extension PaymentsTransfersState {
    
    var uiState: UIState? { getUIState() }
    
    private func getUIState() -> UIState? {
        
        switch route {
        case .none:
            return .none
            
        case let .utilityFlow(utilityFlow):
            switch utilityFlow.current {
            case .none:
                return .none
                
            case let .failure(serviceFailure):
                switch serviceFailure {
                case .connectivityError:
                    return .failure(.connectivityError)
                    
                case let .serverError(message):
                    return .failure(.serverError(message))
                }
                
            case .payment:
                return .payment
                
            case .payByInstruction:
                return .payByInstruction
                
            case let .prepayment(prepayment):
                return .prepayment
                
            case .scan:
                return .scan
                
            case let .selectFailure(`operator`):
                return .selectFailure
                
            case let .services(services):
                return .services
            }
            
        case .other:
            return .other
        }
    }
    
    enum UIState {
        
        case failure(ServiceFailure)
        case payment
        case payByInstruction
        case prepayment
        case other
        case scan
        case selectFailure
        case services
    }
}

extension PaymentsTransfersState {
    
    var navigationState: NavigationState? {
        
        let state = getNavigationState()
        
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
                    return .prePaymentOptions(.success)
                }
                
            default:
                fatalError()
            }
            
        case .other:
            return .other
        }
    }
}

extension PaymentsTransfersState {
    
    enum NavigationState: Identifiable {
        
        case payingByInstruction
        case prePaymentOptions(PrepaymentOptions)
        case prePayment(Prepayment)
        case scanning
        case other
        
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
                
            case .other:
                return .other
            }
        }
        
        enum ID {
            
            case payingByInstruction
            case prepaymentOptions
            case prepayment
            case scanning
            case other
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
