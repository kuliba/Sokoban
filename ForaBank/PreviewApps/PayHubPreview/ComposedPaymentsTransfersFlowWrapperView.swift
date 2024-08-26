//
//  ComposedPaymentsTransfersFlowWrapperView.swift
//  PayHubPreview
//
//  Created by Igor Malyarov on 26.08.2024.
//

import PayHubUI
import SwiftUI

struct ComposedPaymentsTransfersFlowWrapperView<CategoryIcon>: View
where CategoryIcon: View {
    
    let binder: PaymentsTransfersBinder
    let categoryIcon: (ServiceCategory) -> CategoryIcon
    
    var body: some View {
        
        PaymentsTransfersFlowWrapperView(
            model: binder.flow,
            makeContentView: {
                
                PaymentsTransfersFlowView(
                    state: $0,
                    event: $1,
                    factory: .init(
                        makeContentView: {
                            
                            makePaymentsTransfersContent(binder.content)
                        }
                    )
                )
            }
        )
    }
}

private extension ComposedPaymentsTransfersFlowWrapperView {
    
    func makePaymentsTransfersContent(
        _ content: PaymentsTransfersContent
    ) -> some View {
        
        PaymentsTransfersView(
            model: content,
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
                    itemLabel: {
                        
                        CategoryPickerSectionStateItemLabel(
                            item: $0,
                            config: .preview,
                            categoryIcon: categoryIcon,
                            placeholderView: { PlaceholderView(opacity: 0.5) }
                        )
                    }
                )
            }
        )
    }
}
