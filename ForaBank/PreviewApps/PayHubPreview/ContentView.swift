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
import RxViewModel

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
                    factory: .init(
                        makeContentView: makeBinderView)
                )
            }
        )
    }
}

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
    
    func makeBinderView(
        binder: PaymentsTransfersBinder
    ) -> some View {
        
        ComposedPaymentsTransfersFlowView(
            binder: binder,
            factory: .init(
                makeCategoryPickerView: {
                    
                    ComposedCategoryPickerSectionFlowView(
                        binder: $0,
                        config: .preview,
                        itemLabel: itemLabel
                    )
                },
                makeOperationPickerView: {
                    
                    ComposedOperationPickerFlowView(
                        binder: $0,
                        factory: .init(
                            makeItemLabel: itemLabel
                        )
                    )
                },
                makeToolbarView: {
                    
                    ComposedPaymentsTransfersToolbarView(
                        binder: $0,
                        factory: .init(
                            makeDestinationView: {
                                
                                switch $0 {
                                case let .profile(profileModel):
                                    Text(String(describing: profileModel))
                                }
                            },
                            makeFullScreenView: {
                                
                                switch $0 {
                                case let .qr(qrModel):
                                    VStack(spacing: 32) {
                                        
                                        Text(String(describing: qrModel))
                                    }
                                }
                            },
                            makeProfileLabel: {
                                
                                HStack {
                                    Image(systemName: "person.circle")
                                    Text("Profile")
                                }
                            },
                            makeQRLabel: {
                                
                                Image(systemName: "qrcode")
                            }
                        )
                    )
                }
            )
        )
    }
    
    private func itemLabel(
        item: CategoryPickerSectionState.Item
    ) -> some View {
        
        CategoryPickerSectionStateItemLabel(
            item: item,
            config: .preview,
            categoryIcon: categoryIcon,
            placeholderView: { PlaceholderView(opacity: 0.5) }
        )
    }
    
    private func itemLabel(
        item: OperationPickerState.Item
    ) -> some View {
        
        OperationPickerStateItemLabel(
            item: item,
            config: .preview,
            placeholderView:  {
                
                LatestPlaceholder(
                    opacity: 1,
                    config: OperationPickerStateItemLabelConfig.preview.latestPlaceholder
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
