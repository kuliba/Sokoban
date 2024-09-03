//
//  ComposedCategoryPickerSectionFlowView.swift
//  ForaBank
//
//  Created by Igor Malyarov on 26.08.2024.
//

import PayHub
import PayHubUI
import SwiftUI

struct ComposedCategoryPickerSectionFlowView<CategoryPickerItemLabel>: View
where CategoryPickerItemLabel: View {
    
    let binder: CategoryPickerSectionBinder
    let config: Config
    let itemLabel: (CategoryPickerSectionState.Item) -> CategoryPickerItemLabel
    
    var body: some View {
        
        CategoryPickerSectionFlowWrapperView(
            model: binder.flow,
            makeContentView: {
                
                CategoryPickerSectionFlowView(
                    state: $0,
                    event: $1,
                    factory: .init(
                        makeContentView: makeContentView,
                        makeDestinationView: makeDestinationView
                    )
                )
            }
        )
    }
}

extension ComposedCategoryPickerSectionFlowView {

    typealias Config = CategoryPickerSectionContentViewConfig
}

private extension ComposedCategoryPickerSectionFlowView {
    
    func makeContentView() -> some View {
        
        CategoryPickerSectionContentWrapperView(
            model: binder.content,
            makeContentView: { state, event in
                
                CategoryPickerSectionContentView(
                    state: state,
                    event: event,
                    config: config,
                    itemLabel: itemLabel
                )
            }
        )
    }
    
    private func makeDestinationView(
        destination: CategoryPickerSectionDestination<CategoryModelStub, CategoryListModelStub>
    ) -> some View {
        
        Text("TBD: CategoryPickerSectionDestinationView for \(String(describing: destination))")
    }
}
