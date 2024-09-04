//
//  ComposedPaymentsTransfersPersonalView.swift
//  PayHubPreview
//
//  Created by Igor Malyarov on 26.08.2024.
//

import PayHub
import PayHubUI
import SwiftUI

struct ComposedPaymentsTransfersPersonalView<CategoryPickerView, OperationPickerView, ToolbarView>: View
where CategoryPickerView: View,
      OperationPickerView: View,
      ToolbarView: View {
    
    let personal: PaymentsTransfersPersonal
    let factory: Factory
    
    var body: some View {
        
        PaymentsTransfersFlowWrapperView(
            model: personal.flow,
            makeContentView: {
                
                PaymentsTransfersFlowView(
                    state: $0,
                    event: $1,
                    factory: .init(
                        makeContentView: {
                            
                            PaymentsTransfersView(
                                model: personal.content,
                                factory: factory,
                                config: .preview
                            )
                        }
                    )
                )
            }
        )
    }
}

extension ComposedPaymentsTransfersPersonalView {
    
    typealias Factory = PaymentsTransfersViewFactory<CategoryPickerSectionBinder, CategoryPickerView, OperationPickerBinder, OperationPickerView, PaymentsTransfersToolbarBinder, ToolbarView>
}
