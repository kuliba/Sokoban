//
//  RootViewFactory+makePaymentsTransfersPersonalView.swift
//  ForaBank
//
//  Created by Igor Malyarov on 29.11.2024.
//

import PayHubUI
import RxViewModel
import SwiftUI

extension RootViewFactory {
    
    func makePaymentsTransfersPersonalView(
        _ binder: PaymentsTransfersPersonalDomain.Binder
    ) -> some View {
        
        RxWrapperView(
            model: binder.flow,
            makeContentView: {
                
                PaymentsTransfersPersonalFlowView(
                    state: $0,
                    event: $1,
                    factory: .init(
                        makeContentView: {
                            
                            makePaymentsTransfersPersonalContentView(binder)
                        },
                        makeFullScreenCoverView: makeFullScreenCoverView,
                        makeDestinationView: makeDestinationView
                    )
                )
            }
        )
    }
    
    private func makePaymentsTransfersPersonalContentView(
        _ binder: PaymentsTransfersPersonalDomain.Binder
    ) -> some View {
        
        PaymentsTransfersPersonalContentView(
            content: binder.content,
            factory: .init(
                makeCategoryPickerView: makeCategoryPickerSectionView,
                makeOperationPickerView: makeOperationPickerView,
                makeToolbar: {
                    
                    makePaymentsTransfersToolbar(binder: binder)
                },
                makeTransfersView: makePaymentsTransfersTransfersView
            ),
            config: .iFora
        )
    }
    
    private func makeDestinationView(
        destination: PaymentsTransfersPersonalNavigation.Destination
    ) -> some View {
        
        Text("TBD: DestinationView")
    }
    
    private func makeFullScreenCoverView(
        fullScreenCover: PaymentsTransfersPersonalNavigation.FullScreenCover
    ) -> some View {
        
        Text("TBD: FullScreenCoverView")
    }
}
