//
//  ComposedPaymentsTransfersFlowWrapperView.swift
//  PayHubPreview
//
//  Created by Igor Malyarov on 26.08.2024.
//

import PayHub
import PayHubUI
import SwiftUI

struct ComposedPaymentsTransfersFlowWrapperView<CategoryPickerItemLabel>: View
where CategoryPickerItemLabel: View {
    
    let binder: PaymentsTransfersBinder
    let itemLabel: (CategoryPickerItem) -> CategoryPickerItemLabel
    
    var body: some View {
        
        PaymentsTransfersFlowWrapperView(
            model: binder.flow,
            makeContentView: {
                
                PaymentsTransfersFlowView(
                    state: $0,
                    event: $1,
                    factory: .init(
                        makeContentView: makeContentView
                    )
                )
            }
        )
    }
}

private extension ComposedPaymentsTransfersFlowWrapperView {
    
    func makeContentView(
    ) -> some View {
        
        PaymentsTransfersView(
            model: binder.content,
            factory: .init(
                makeCategoryPickerView: makeCategoryPickerView,
                makeOperationPickerView: OperationPickerBinderView.init,
                makeToolbarView: PaymentsTransfersToolbarBinderView.init
            )
        )
    }
    
    private func makeCategoryPickerView(
        _ binder: CategoryPickerSectionBinder
    ) -> some View {
        
        CategoryPickerSectionBinderView(
            binder: binder,
            factory: .init(
                makeContentView: makeCategoryPickerSectionContentView,
                makeDestinationView: EmptyView.init
            )
        )
    }
    
    private func makeCategoryPickerSectionContentView(
        content: CategoryPickerSectionContent
    ) -> some View {
        
        CategoryPickerSectionContentWrapperView(
            model: content,
            makeContentView: { state, event in
                
                CategoryPickerSectionContentView(
                    state: state,
                    event: event,
                    config: .preview,
                    itemLabel: itemLabel
                )
            }
        )
    }
}
