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
                corporateView: paymentsTransfersCorporateView,
                personalView: paymentsTransfersPersonalView,
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
    
    func paymentsTransfersCorporateView(
        corporate: PaymentsTransfersCorporate
    ) -> some View {
        
        ComposedPaymentsTransfersCorporateView(
            corporate: corporate,
            makeContentView: {
                
                PaymentsTransfersCorporateContentView(
                    content: corporate,
                    factory: .init(
                        makeBannerSectionView: makeBannerSectionView,
                        makeRestrictionNoticeView: makeRestrictionNoticeView,
                        makeToolbarView: makePaymentsTransfersCorporateToolbarView,
                        makeTransfersSectionView: makeTransfersSectionView
                    ),
                    config: .preview
                )
            }
        )
    }
    
    func makeBannerSectionView() -> some View {
        
        ZStack {
            
            Color.orange.opacity(0.5)
            
            Text("Banners")
                .foregroundColor(.white)
                .font(.title3.bold())
        }
    }
    
    func makeRestrictionNoticeView() -> some View {
        
        Label("App functionality is restricted", systemImage: "info.bubble")
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.gray.opacity(0.2))
            .clipShape(Capsule())
    }
    
    func makePaymentsTransfersCorporateToolbarView() -> some ToolbarContent {
        
        ToolbarItem(placement: .topBarLeading) {
            
            HStack {
                
                Image(systemName: "person")
                Text("TBD: Profile without QR")
            }
        }
    }
    
    func makeTransfersSectionView() -> some View {
        
        ZStack {
            
            Color.green.opacity(0.5)
            
            Text("Transfers")
                .foregroundColor(.white)
                .font(.title3.bold())
        }
    }
    
    func paymentsTransfersPersonalView(
        personal: PaymentsTransfersPersonal
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
                            makeToolbarView: makePaymentsTransfersPersonalToolbarView
                        ),
                        config: .preview
                    )
                }
            )
        )
    }
    
    func makeCategoryPickerSectionView(
        binder: CategoryPickerSectionBinder
    ) -> some View {
        
        ComposedCategoryPickerSectionFlowView(
            binder: binder,
            config: .preview,
            itemLabel: itemLabel,
            makeDestinationView: makeCategoryPickerSectionDestinationView
        )
    }
    
    @ViewBuilder
    func makeCategoryPickerSectionDestinationView(
        destination: CategoryPickerSectionDestination
    ) -> some View {
        
        switch destination {
        case let .category(selected):
            selectedCategoryView(selected)
            
        case let .list(plainCategoryPickerBinder):
            categoryListView(plainCategoryPickerBinder)
        }
    }
    
    func selectedCategoryView(
        _ selected: SelectedCategoryDestination
    ) -> some View {
        
        Text("TBD: CategoryPickerSectionDestinationView for \(String(describing: selected))")
    }
    
    func categoryListView(
        _ plainCategoryPickerBinder: PlainCategoryPickerBinder
    ) -> some View {
        
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

    func makeOperationPickerView(
        binder: OperationPickerBinder
    ) -> some View {
        
        ComposedOperationPickerFlowView(
            binder: binder,
            factory: .init(
                makeDestinationView: {
                    
                    Text("TBD: destination " + String(describing: $0))
                },
                makeItemLabel: itemLabel
            )
        )
    }
    
    func makePaymentsTransfersPersonalToolbarView(
        binder: PaymentsTransfersToolbarBinder
    ) -> some View {
        
        ComposedPaymentsTransfersToolbarView(
            binder: binder,
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
