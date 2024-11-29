//
//  RootViewFactory+makePaymentsTransfersPersonalView.swift
//  ForaBank
//
//  Created by Igor Malyarov on 29.11.2024.
//

import PayHubUI
import SwiftUI

extension RootViewFactory {
    
    func makePaymentsTransfersPersonalView(
        _ personal: PaymentsTransfersPersonal
    ) -> some View {
        
        ComposedPaymentsTransfersPersonalView(
            personal: personal,
            factory: .init(
                makeContentView: {
                    
                    PaymentsTransfersPersonalContentView(
                        content: personal.content,
                        factory: .init(
                            makeCategoryPickerView: makeCategoryPickerSectionView,
                            makeOperationPickerView: makeOperationPickerView,
                            makeToolbarView: makePaymentsTransfersToolbarView,
                            makeTransfersView: makePaymentsTransfersTransfersView
                        ),
                        config: .iFora
                    )
                },
                makeFullScreenCoverView: { _ in
                    
                    Text("TBD: FullScreenCoverView")
                },
                makeDestinationView: { _ in
                    
                    Text("TBD: DestinationView")
                }
            )
        )
    }
}
