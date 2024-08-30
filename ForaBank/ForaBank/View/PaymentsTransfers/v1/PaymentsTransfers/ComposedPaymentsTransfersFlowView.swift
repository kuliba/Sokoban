//
//  ComposedPaymentsTransfersFlowView.swift
//  ForaBank
//
//  Created by Igor Malyarov on 26.08.2024.
//

import PayHub
import PayHubUI
import SwiftUI

struct ComposedPaymentsTransfersFlowView<CategoryPickerView, OperationPickerView, ToolbarView>: View
where CategoryPickerView: View,
      OperationPickerView: View,
      ToolbarView: View {
    
    let binder: PaymentsTransfersBinder
    let factory: Factory
    
    var body: some View {
        
        PaymentsTransfersFlowWrapperView(
            model: binder.flow,
            makeContentView: {
                
                PaymentsTransfersFlowView(
                    state: $0,
                    event: $1,
                    factory: .init(
                        makeContentView: {
                            
                            PayHubUI.PaymentsTransfersView(
                                model: binder.content,
                                factory: factory
                            )
                        }
                    )
                )
            }
        )
    }
}

extension ComposedPaymentsTransfersFlowView {
    
    typealias Factory = PayHubUI.PaymentsTransfersViewFactory<CategoryPickerSectionBinder, CategoryPickerView, OperationPickerBinder, OperationPickerView, PaymentsTransfersToolbarBinder, ToolbarView>
}
