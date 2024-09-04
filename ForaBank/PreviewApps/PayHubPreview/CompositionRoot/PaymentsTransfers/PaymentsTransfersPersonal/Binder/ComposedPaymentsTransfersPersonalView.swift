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
    let config: Config
    
    var body: some View {
        
        PaymentsTransfersPersonalFlowWrapperView(
            model: personal.flow,
            makeContentView: {
                
                PaymentsTransfersPersonalFlowView(
                    state: $0,
                    event: $1,
                    factory: .init(
                        makeContentView: {
                            
                            PaymentsTransfersPersonalContentView(
                                content: personal.content,
                                factory: factory,
                                config: config
                            )
                        }
                    )
                )
            }
        )
    }
}

extension ComposedPaymentsTransfersPersonalView {
    
    typealias Personal = PaymentsTransfersPersonal
    typealias Factory = PaymentsTransfersPersonalViewFactory<CategoryPickerSectionBinder, CategoryPickerView, OperationPickerBinder, OperationPickerView, PaymentsTransfersToolbarBinder, ToolbarView>
    typealias Config = PaymentsTransfersPersonalViewConfig
}
