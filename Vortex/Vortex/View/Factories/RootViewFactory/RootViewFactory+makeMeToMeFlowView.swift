//
//  RootViewFactory+makeMeToMeFlowView.swift
//  Vortex
//
//  Created by Igor Malyarov on 30.01.2025.
//

import RxViewModel
import SwiftUI

extension ViewComponents {
    
    @inlinable
    func makeMeToMeFlowView(
        _ flow: MeToMeDomain.Flow
    ) -> some View {
        
        RxWrapperView(model: flow) { state, event in
            
            Color.clear
                .bottomSheet(
                    sheet: state.navigation?.bottomSheet,
                    dismiss: { event(.dismiss) },
                    content: makeCorporateTransfersBottomSheetView
                )
                .navigationDestination(
                    destination: state.navigation?.destination,
                    content: makeCorporateTransfersDestinationView
                )
        }
    }
    
    @inlinable
    @ViewBuilder
    func makeCorporateTransfersBottomSheetView(
        bottomSheet: MeToMeDomain.Navigation.BottomSheet
    ) -> some View {
        
        switch bottomSheet {
        case let .meToMe(meToMe):
            makePaymentsMeToMeView(meToMe)
        }
    }
    
    @inlinable
    @ViewBuilder
    func makeCorporateTransfersDestinationView(
        destination: MeToMeDomain.Navigation.Destination
    ) -> some View {
        
        switch destination {
        case let .successMeToMe(successMeToMe):
            makePaymentsSuccessView(successMeToMe)
        }
    }
}

extension MeToMeDomain.Navigation {
    
    var bottomSheet: BottomSheet? {
        
        switch self {
        case .alert:
            return nil
            
        case let .meToMe(node):
            return .meToMe(node.model)
            
        case let .successMeToMe(node):
            return nil
        }
    }
    
    enum BottomSheet {
        
        case meToMe(PaymentsMeToMeViewModel)
    }
    
    var destination: Destination? {
        
        switch self {
        case .alert:
            return nil
            
        case .meToMe:
            return nil
            
        case let .successMeToMe(node):
            return .successMeToMe(node.model)
        }
    }
    
    enum Destination {
        
        case successMeToMe(PaymentsSuccessViewModel)
    }
}

extension MeToMeDomain.Navigation.BottomSheet: Identifiable {
    
    var id: ID {
        
        switch self {
        case let .meToMe(meToMe):
            return .meToMe(.init(meToMe))
        }
    }
    
    enum ID: Hashable {
        
        case meToMe(ObjectIdentifier)
    }
}

extension MeToMeDomain.Navigation.BottomSheet: BottomSheetCustomizable {}

extension MeToMeDomain.Navigation.Destination: Identifiable {
    
    var id: ID {
        
        switch self {
        case let .successMeToMe(successMeToMe):
            return .successMeToMe(.init(successMeToMe))
        }
    }
    
    enum ID: Hashable {
        
        case successMeToMe(ObjectIdentifier)
    }
}
