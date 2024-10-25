//
//  PaymentsTransfersPersonalTransfersView.swift
//  ForaBank
//
//  Created by Igor Malyarov on 23.10.2024.
//

import RxViewModel
import SwiftUI

struct PaymentsTransfersPersonalTransfersFlowView<ContentView>: View
where ContentView: View {
    
    let state: Domain.FlowState
    let event: (Domain.FlowEvent) -> Void
    let contentView: () -> ContentView
    
    var body: some View {
        
        contentView()
            .bottomSheet(
                sheet: state.bottomSheet,
                dismiss: {},
                content: makeBottomSheetView
            )
            .navigationDestination(
                destination: state.destination,
                dismiss: {},
                content: makeDestinationView
            )
            .sheet(
                modal: state.sheet,
                dismiss: {},
                content: makeSheetView
            )
    }
}

extension PaymentsTransfersPersonalTransfersFlowView {
    
    typealias Domain = PaymentsTransfersPersonalTransfersDomain
}

private extension PaymentsTransfersPersonalTransfersFlowView {
    
    @ViewBuilder
    func makeBottomSheetView(
        bottomSheet: PaymentsTransfersPersonalTransfersDomain.BottomSheet
    ) -> some View {
        
        switch bottomSheet {
        case let .meToMe(meToMe):
            PaymentsMeToMeView(viewModel: meToMe.model)
            //                .fullScreenCover(
            //                    cover: state.fullCover,
            //                    content: { fullCover in
            //
            //                        switch fullCover.type {
            //                        case let .successMeToMe(successMeToMeViewModel):
            //                            PaymentsSuccessView(viewModel: successMeToMeViewModel)
            //                        }
            //                    }
            //                )
                .transaction { $0.disablesAnimations = false }
        }
    }
    
    @ViewBuilder
    func makeDestinationView(
        destination: PaymentsTransfersPersonalTransfersDomain.Destination
    ) -> some View {
        
        switch destination {
        case let .payments(node):
            PaymentsView(viewModel: node.model.paymentsViewModel)
        }
    }
    
    @ViewBuilder
    func makeSheetView(
        sheet: PaymentsTransfersPersonalTransfersDomain.Sheet
    ) -> some View {
        
        switch sheet {
        case let .contacts(node):
            ContactsView(viewModel: node.model)
        }
    }
}

extension PaymentsTransfersPersonalTransfersDomain.FlowState {
    
    var bottomSheet: PaymentsTransfersPersonalTransfersDomain.BottomSheet? {
        
        switch navigation {
            
        case let .meToMe(meToMe):
            return .meToMe(meToMe)
            
        case .none, .alert, .contacts, .payments, .paymentsViewModel, .successMeToMe:
            return nil
        }
    }
    
    var destination: PaymentsTransfersPersonalTransfersDomain.Destination? {
        
        switch navigation {
            //    case let .anotherCard(anotherCard):
            //        return .anotherCard(anotherCard)
            
        case let .payments(payments):
            return .payments(payments)
            
        case .none, .alert, .contacts, .meToMe, .paymentsViewModel, .successMeToMe:
            return nil
        }
    }
    
    var sheet: PaymentsTransfersPersonalTransfersDomain.Sheet? {
        
        switch navigation {
        case let .contacts(contacts):
            return .contacts(contacts)
            
        case .none, .alert, .meToMe, .payments, .paymentsViewModel, .successMeToMe:
            return nil
        }
    }
}

extension PaymentsTransfersPersonalTransfersDomain {
    
    enum BottomSheet: BottomSheetCustomizable {
        
        case meToMe(Node<PaymentsMeToMeViewModel>)
    }
    
    enum Destination {
        
        case payments(Node<ClosePaymentsViewModelWrapper>)
    }
    
    enum Sheet {
        
        case contacts(Node<ContactsViewModel>)
    }
}

extension PaymentsTransfersPersonalTransfersDomain.BottomSheet: Identifiable {
    
    var id: ID {
        
        switch self {
        case let .meToMe(node):
            return .meToMe(.init(node.model))
        }
    }
    
    enum ID: Hashable {
        
        case meToMe(ObjectIdentifier)
    }
}

extension PaymentsTransfersPersonalTransfersDomain.Destination: Identifiable {
    
    var id: ID {
        
        switch self {
        case let .payments(node):
            return .payments(.init(node.model))
        }
    }
    
    enum ID: Hashable {
        
        case payments(ObjectIdentifier)
    }
}

extension PaymentsTransfersPersonalTransfersDomain.Sheet: Identifiable {
    
    var id: ID {
        
        switch self {
        case let .contacts(node):
            return .contacts(.init(node.model))
        }
    }
    
    enum ID: Hashable {
        
        case contacts(ObjectIdentifier)
    }
}

