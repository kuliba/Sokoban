//
//  PaymentsTransfersSwitcherView.swift
//  ForaBank
//
//  Created by Igor Malyarov on 29.08.2024.
//

import SwiftUI
import PayHubUI

struct PaymentsTransfersSwitcherView<CorporateView, PersonalView, UndefinedView>: View
where CorporateView: View,
      PersonalView: View,
      UndefinedView: View {
    
    @ObservedObject var model: PaymentsTransfersSwitcher
    
    let corporateView: (PaymentsTransfersCorporate) -> CorporateView
    let personalView: (PaymentsTransfersPersonal) -> PersonalView
    let undefinedView: () -> UndefinedView
    
    var body: some View {
        
        Group {
            
            switch model.state {
            case .none:
                undefinedView()
                
            case let .corporate(corporate):
                corporateView(corporate)
                
            case let .personal(personal):
                personalView(personal)
            }
        }
        .transition(.slide.combined(with: .opacity))
        .animation(.easeInOut, value: model.state.id)
    }
}

private extension Optional
where Wrapped == ProfileState<PaymentsTransfersCorporate, PaymentsTransfersPersonal> {
    
    var id: ID {
        
        switch self {
        case .none:      return .undefined
        case .corporate: return .corporate
        case .personal:  return .personal
        }
    }
    
    enum ID: Hashable {
        
        case corporate, personal, undefined
    }
}
