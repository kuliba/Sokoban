//
//  PaymentsTransfersSwitcherView.swift
//  ForaBank
//
//  Created by Igor Malyarov on 29.08.2024.
//

import SwiftUI
import PayHubUI

struct PaymentsTransfersSwitcherView<CorporateView, PersonalView>: View
where CorporateView: View,
      PersonalView: View {
    
    @ObservedObject var model: PaymentsTransfersSwitcher
    
    let corporateView: (PaymentsTransfersCorporate) -> CorporateView
    let personalView: (PaymentsTransfersBinder) -> PersonalView
    
    var body: some View {
        
        Group {
            
            switch model.state {
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

private extension ProfileState where Corporate == PaymentsTransfersCorporate, Personal == PaymentsTransfersBinder {
    
    var id: ID {
        
        switch self {
        case .corporate: return .corporate
        case .personal:  return .personal
        }
    }
    
    enum ID: Hashable {
        
        case corporate, personal
    }
}
