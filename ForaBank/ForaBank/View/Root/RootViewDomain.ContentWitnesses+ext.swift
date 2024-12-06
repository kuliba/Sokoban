//
//  RootViewDomain.ContentWitnesses+ext.swift
//  Vortex
//
//  Created by Igor Malyarov on 18.11.2024.
//

import Combine

extension RootViewDomain.ContentWitnesses {
    
    init(isFlagActive: Bool) {
        
        self.init(
            emitting: {
                
                if isFlagActive {
                    $0.rootEventPublisher
                } else {
                    Empty().eraseToAnyPublisher()
                }
            },
            dismissing: { content in { content.dismiss() }}
        )
    }
}

private extension RootViewModel {
    
    func dismiss() {
        
        tabsViewModel.mainViewModel.dismiss()
        tabsViewModel.paymentsModel.dismiss()
        tabsViewModel.chatViewModel.dismiss()
        tabsViewModel.marketShowcaseBinder.dismiss()
    }
}

private extension MainViewModel {
    
    func dismiss() {
        
        resetDestination()
        resetModal()
    }
}

private extension RootViewModel.PaymentsModel {
    
    func dismiss() {
        
        switch self {
        case let .legacy(paymentsTransfersViewModel):
            paymentsTransfersViewModel.dismiss()
            
        case let .v1(switcher):
            switcher.dismiss()
        }
    }
}

private extension PaymentsTransfersSwitcherProtocol {
    
    func dismiss() {
        
        switch self as? PaymentsTransfersSwitcher {
        case .none:
            return
            
        case let .some(switcher):
            switcher.dismiss()
        }
    }
}

private extension PaymentsTransfersSwitcher {
    
    func dismiss() {
        
        switch state {
        case let .corporate(corporate):
            corporate.flow.event(.dismiss)
            
        case let .personal(personal):
            personal.flow.event(.dismiss)
            
        case .none:
            return
        }
    }
}

private extension ChatViewModel {
    
    func dismiss() {
        
    }
}

private extension MarketShowcaseDomain.Binder {
    
    func dismiss() {
        
        flow.event(.reset)
    }
}
