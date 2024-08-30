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

typealias PaymentsTransfersTabState = TabState<PaymentsTransfersSwitcher>

final class ContentViewModel: ObservableObject {
    
    @Published var hasCorporateCardsOnly = false
    
}

struct ContentView: View {
    
    @StateObject private var contentModel: ContentViewModel
    
    private let model: TabModel<PaymentsTransfersSwitcher>
    
    init(
        selected: PaymentsTransfersTabState.Selected = .ok
    ) {
        let contentModel = ContentViewModel()
        let tabComposer = TabModelComposer(
            hasCorporateCardsOnly: contentModel.$hasCorporateCardsOnly.eraseToAnyPublisher(),
            scheduler: .main
        )
        self._contentModel = .init(wrappedValue: contentModel)
        self.model = tabComposer.compose(selected: selected)
    }
    
    var body: some View {
        
        TabStateWrapperView(
            model: model,
            makeContent: { state, event in
                
                TabView(
                    state: state,
                    event: event,
                    factory: .init(makeContentView: makeSwitcherView)
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
    
    func makeSwitcherView(
        switcher: PaymentsTransfersSwitcher
    ) -> some View {
        
        ZStack(alignment: .top) {
            
            ComposedProfileSwitcherView(
                model: switcher,
                corporateView: corporateView,
                personalView: personalView,
                undefinedView: undefinedView
            )
            
            Button(contentModel.hasCorporateCardsOnly ? "Corporate" : "Personal") {
                
                contentModel.hasCorporateCardsOnly.toggle()
            }
            .foregroundColor(contentModel.hasCorporateCardsOnly ? .orange : .green)
            .padding(.horizontal)
            .offset(y: -8)
        }
    }
    
    func corporateView(
        corporate: PaymentsTransfersCorporate
    ) -> some View {
        
        Text(String(describing: corporate))
            .frame(maxHeight: .infinity)
            .toolbar {
                
                ToolbarItem(placement: .topBarLeading) {
                    
                    Text("TBD: Profile without QR")
                }
            }
    }
    
    func personalView(
        personal: PaymentsTransfersPersonal
    ) -> some View {
        
        ComposedPaymentsTransfersPersonalFlowView(
            personal: personal,
            factory: .init(
                makeCategoryPickerView: {
                    
                    ComposedCategoryPickerSectionFlowView(
                        binder: $0,
                        config: .preview,
                        itemLabel: itemLabel,
                        makeDestinationView: makeCategoryPickerSectionDestinationView
                    )
                },
                makeOperationPickerView: {
                    
                    ComposedOperationPickerFlowView(
                        binder: $0,
                        factory: .init(
                            makeDestinationView: {
                                
                                Text("TBD: destination " + String(describing: $0))
                            },
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
    
    @ViewBuilder
    func makeCategoryPickerSectionDestinationView(
        destination: CategoryPickerSectionDestination
    ) -> some View {
        
        switch destination {
        case let .category(categoryModelStub):
            Text("TBD: CategoryPickerSectionDestinationView for \(String(describing: categoryModelStub))")
            
        case let .list(plainCategoryPickerBinder):
            ComposedPlainPickerView(
                binder: plainCategoryPickerBinder,
                makeContentView: { state, event in
                
                    List {
                        
                        ForEach(state.elements) { category in
                            
                            Button(category.name) { event(.select(category)) }
                        }
                    }
                    .listStyle(.plain)
                },
                makeDestinationView: {
                
                    Text("TBD: destination view for \(String(describing: $0))")
                        .padding()
                }
            )
        }
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
    
    private func undefinedView(
    ) -> some View {
        
        Text("TBD: products not loaded")
    }
}

extension Latest: Named {
    
    var name: String { .init(id.prefix(12)) }
}

#Preview {
    ContentView()
}
