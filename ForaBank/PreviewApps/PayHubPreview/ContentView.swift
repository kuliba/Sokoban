//
//  ContentView.swift
//  PayHubPreview
//
//  Created by Igor Malyarov on 14.08.2024.
//

import PayHub
import PayHubUI
import SwiftUI
import UIPrimitives

typealias PaymentsTransfersTabState = TabState<PaymentsTransfersBinder>

struct ContentView: View {
    
    private let model: TabModel<PaymentsTransfersBinder>
    
    init(
        selected: PaymentsTransfersTabState.Selected = .ok
    ) {
        let tabComposer = TabModelComposer(scheduler: .main)
        self.model = tabComposer.compose(selected: selected)
    }
    
    var body: some View {
        
        if #available(iOS 15.0, *) {
            let _ = Self._printChanges()
        }
        
        TabStateWrapperView(
            model: model,
            makeContent: { state, event in
                
                TabView(
                    state: state,
                    event: event,
                    factory: .init(makeContentView: makeBinderView)
                )
            }
        )
    }
}

#warning("move to factory")
private typealias ProfileFlowButtonReducer = FlowButtonReducer<DestinationWrapper<ProfileModel>>
private typealias ProfileFlowButtonEffectHandler = FlowButtonEffectHandler<DestinationWrapper<ProfileModel>>

enum DestinationWrapper<Destination>: Identifiable {
    
    case destination(Destination)
    
    var id: ID {
        
        switch self {
        case .destination: return .destination
        }
    }
    
    enum ID: Hashable {
        
        case destination
    }
}

private extension ContentView {
    
    @ViewBuilder
    func makeBinderView(
        binder: PaymentsTransfersBinder
    ) -> some View {
        
        PaymentsTransfersFlowWrapperView(
            model: binder.flow,
            makeFlowView: {
                
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
    
    @ViewBuilder
    private func makePaymentsTransfersContent(
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
    
    private func categoryIcon(
        category: ServiceCategory
    ) -> some View {
        
        Color.blue.opacity(0.1)
    }
}

extension Latest: Named {
    
    var name: String { .init(id.prefix(12)) }
}

#Preview {
    ContentView()
}
