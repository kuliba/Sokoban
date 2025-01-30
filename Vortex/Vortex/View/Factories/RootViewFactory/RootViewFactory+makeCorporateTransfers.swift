//
//  RootViewFactory+makeCorporateTransfersView.swift
//  Vortex
//
//  Created by Igor Malyarov on 30.01.2025.
//

import PayHubUI
import RxViewModel
import SwiftUI

extension RootViewFactory {
    
    @ViewBuilder
    func makeCorporateTransfersView(
        corporateTransfers: any CorporateTransfersProtocol
    ) -> some View {
        
        if let binder = corporateTransfers.corporateTransfersBinder {
            
            makeCorporateTransfersView(binder: binder)
            
        } else {
            
            Text("Unexpected corporateTransfers type \(String(describing: corporateTransfers))")
                .foregroundColor(.red)
        }
    }
    
    @inlinable
    func makeCorporateTransfersView(
        binder: PaymentsTransfersCorporateTransfersDomain.Binder
    ) -> some View {
        
        RxWrapperView(model: binder.flow) { state, event in
            
            VStack {
                
                Color.clear.frame(height: 16)
                
                HStack {
                    
                    PTSectionTransfersView.TransfersButtonView(viewModel: .init(
                        type: .betweenSelf,
                        action: { event(.select(.meToMe)) }
                    ))
                    
                    Spacer()
                }
            }
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
        bottomSheet: PaymentsTransfersCorporateTransfersDomain.Navigation.BottomSheet
    ) -> some View {
        
        switch bottomSheet {
        case let .meToMe(meToMe):
            components.makePaymentsMeToMeView(meToMe)
        }
    }
    
    @inlinable
    @ViewBuilder
    func makeCorporateTransfersDestinationView(
        destination: PaymentsTransfersCorporateTransfersDomain.Navigation.Destination
    ) -> some View {
        
        switch destination {
        case let .successMeToMe(successMeToMe):
            components.makePaymentsSuccessView(successMeToMe)
        }
    }
}

extension PaymentsTransfersCorporateTransfersDomain.Navigation {
    
    var bottomSheet: BottomSheet? {
        
        switch self {
        case .alert:
            return nil
            
        case let .meToMe(node):
            return .meToMe(node.model)
            
        case let .openProduct(string):
            return nil
            
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
            
        case let .openProduct(openProduct):
            return nil
            
        case let .successMeToMe(node):
            return .successMeToMe(node.model)
        }
    }
    
    enum Destination {
        
        case successMeToMe(PaymentsSuccessViewModel)
    }
}

extension PaymentsTransfersCorporateTransfersDomain.Navigation.BottomSheet: Identifiable {
    
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

extension PaymentsTransfersCorporateTransfersDomain.Navigation.BottomSheet: BottomSheetCustomizable {}

extension PaymentsTransfersCorporateTransfersDomain.Navigation.Destination: Identifiable {
    
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
