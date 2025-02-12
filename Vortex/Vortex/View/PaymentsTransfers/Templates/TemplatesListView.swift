//
//  TemplatesListView.swift
//  Vortex
//
//  Created by Mikhail on 19.01.2022.
//  Full refactored by Dmitry Martynov 15.05.2023
//

import SwiftUI
import UIPrimitives

struct TemplatesListViewFactory {
    
    let makeOptionSelectorView: MakeOptionSelectorView
    let makePaymentsMeToMeView: MakePaymentsMeToMeView
    let makePaymentsSuccessView: MakePaymentsSuccessView
    let makePaymentsView: MakePaymentsView
}

struct TemplatesListView: View {
    
    @ObservedObject var viewModel: TemplatesListViewModel
    
    let viewFactory: TemplatesListViewFactory
    
    @State private var height: CGFloat = .zero
    
    private let columns = [GridItem(.flexible(), spacing: 16), GridItem(.flexible())]
    
    var body: some View {
        
        GeometryReader { geo in
            
            mainVStack()
                .ignoresSafeArea(.container, edges: .bottom)
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarBackButtonHidden(true)
                .toolbar(content: toolbar)
                .modal(
                    modal: viewModel.route.modal,
                    dismiss: { viewModel.route.modal = nil },
                    bottomSheetContent: bottomSheetContent
                )
                .onAppear { height = geo.size.height }
                .onChange(of: geo.size.height) { height = $0 }
        }
    }
}

private extension View {
    
    @ViewBuilder
    func modal(
        modal: TemplatesListViewModel.Modal?,
        dismiss: @escaping () -> Void,
        bottomSheetContent: @escaping (TemplatesListViewModel.Sheet) -> some View
    ) -> some View {
        
        switch modal {
        case .none:
            self
            
        case let .alert(alertViewModel):
            alert(item: alertViewModel, content: Alert.init(with:))
            
        case let .sheet(sheet):
            bottomSheet(
                item: .init(
                    get: { sheet },
                    set: { if $0 == nil { dismiss() }}
                ),
                content: bottomSheetContent
            )
        }
    }
}

private extension TemplatesListView {
    
    func mainVStack() -> some View {
        
        VStack {
            
            switch viewModel.state {
            case .loading:
                // TODO: improve with factory helper
                 ProgressView()
                    .offset(y: -44)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                // SpinnerRefreshView(icon: .init("Logo Vortex"))
//                RoundedRectangle(cornerRadius: 24)
//                    .foregroundColor(.mainColorsGray)
//                    .frame(height: 56)
//                    .frame(maxWidth: .infinity)
//                    .padding()
//                    .shimmering()
//                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                
            case .normal, .select:
                
                categorySelector()
                
                switch viewModel.style {
                case .list:
                    list()
                    
                case .tiles:
                    tiles()
                }
                
                viewModel.deletePanel.map(DeletePannelView.init)
                
            case let .emptyList(emptyTemplateListViewModel):
                EmptyTemplateListView(viewModel: emptyTemplateListViewModel)
                
            case .placeholder:
                PlaceholderView(style: viewModel.style)
            }
            
            NavigationLink("", isActive: $viewModel.isLinkActive) {
                
                viewModel.link.map(destinationView)
            }
        }
    }
    
    @ViewBuilder
    func categorySelector() -> some View {
        
        viewModel.categorySelector.map {
            
            viewFactory.makeOptionSelectorView($0)
                .frame(height: 32)
                .padding(.top, 16)
                .padding(.horizontal)
        }
    }
    
    func list() -> some View {
        
        List {
            
            ForEach(viewModel.items, content: itemView)
                .onMove { indexes, destination in
                    
                    guard let first = indexes.first else { return }
                    
                    viewModel.action.send(TemplatesListViewModelAction.ReorderItems.ItemMoved
                        .init(move: (first, destination)))
                }
                .moveDisabled(viewModel.editModeState != .active)
        }
        .listStyle(.plain)
        .environment(\.editMode, $viewModel.editModeState)
        .padding(.horizontal)
        .id(viewModel.idList) //FIXME: - Принудительное обновление вью в ЕдитМоде для показа блинчиков после снятия запрета на перемещение в 16 оси
    }
    
    @ViewBuilder
    func itemView(
        item: TemplatesListViewModel.ItemViewModel
    ) -> some View {
        
        switch item.kind {
        case .regular, .deleting:
            TemplateItemView(
                viewModel: item,
                style: .constant(.list),
                editMode: $viewModel.editModeState
            )
            .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
            .listRowBackground(BackgroundListView())
            .modifier(Self.listRowSeparatorTint())
            .modifier(Self.trailingSwipeAction(
                viewModel: viewModel.getItemsMenuViewModel(),
                item: item))
            
        case .add:
            AddNewItemView(viewModel: item, style: .constant(.list))
                .listRowInsets(EdgeInsets(top: 6, leading: 0, bottom: 6, trailing: 0))
                .listRowBackground(BackgroundListView())
                .modifier(Self.listRowSeparatorTint())
            
        case .placeholder:
            PlaceholderItemView(style: .constant(.list))
                .listRowInsets(EdgeInsets(top: 6, leading: 0, bottom: 6, trailing: 0))
                .shimmering(bounce: true)
        }
    }
    
    func tiles() -> some View {
        
        ScrollView {
            
            LazyVGrid(columns: columns, spacing: 16) {
                
                ForEach(viewModel.items, content: tileView)
            }
            .padding(.horizontal)
            .padding(.top)
        }
    }
    
    @ViewBuilder
    func tileView(
        item: TemplatesListViewModel.ItemViewModel
    ) -> some View {
        
        switch item.kind {
            
        case .regular, .deleting:
            TemplateItemView(
                viewModel: item,
                style: .constant(.tiles),
                editMode: $viewModel.editModeState
            )
            .contextMenu {
                
                if let itemsMenuViewModel = viewModel.getItemsMenuViewModel(),
                   !item.state.isProcessing {
                    
                    ForEach(itemsMenuViewModel) { button in
                        
                        Button(action: { button.action(item.id) }) {
                            
                            Text(button.subTitle)
                            button.icon.renderingMode(.original)
                        }
                    }
                }
            }
            
        case .add:
            AddNewItemView(viewModel: item, style: .constant(.tiles))
            
        case .placeholder:
            PlaceholderItemView(style: .constant(.tiles))
                .shimmering(bounce: true)
        }
    }
    
    @ViewBuilder
    func destinationView(
        link: TemplatesListViewModel.Link
    ) -> some View {
        
        switch link {
        case let .payment(paymentsViewModel):
            viewFactory.makePaymentsView(paymentsViewModel)
        }
    }
    
    @ToolbarContentBuilder
    func toolbar() -> some ToolbarContent {
        
        ToolbarItem(placement: .principal) {
            
            switch viewModel.navBarState {
            case let .regular(regViewModel):
                RegularNavBarView(viewModel: regViewModel)
                
            case let .search(searchViewModel):
                SearchNavBarView(viewModel: searchViewModel)
                
            case let .delete(deleteViewModel):
                TwoButtonsNavBarView(viewModel: deleteViewModel)
                
            case let .reorder(reorderViewModel):
                TwoButtonsNavBarView(viewModel: reorderViewModel)
            }
        }
    }
    
    @ViewBuilder
    func bottomSheetContent(
        sheet: TemplatesListViewModel.Sheet
    ) -> some View {
        
        switch sheet.type {
        case let .meToMe(viewModel):
            viewFactory.makePaymentsMeToMeView(viewModel)
                .fullScreenCover(
                    item: $viewModel.success,
                    content: viewFactory.makePaymentsSuccessView
                )
                .transaction { $0.disablesAnimations = false }
            
        case let .renameItem(renameViewModel):
            RenameTemplateItemView(viewModel: renameViewModel)
            
        case let .productList(productListViewModel):
            ProductListView(viewModel: productListViewModel, parentHeight: height)
        }
    }
}

extension TemplatesListView {
    
    struct RenameTemplateItemView: View {
        
        @ObservedObject var viewModel: TemplatesListViewModel.RenameTemplateItemViewModel
        
        var body: some View {
            
            VStack() {
                
                HStack {
                    
                    TemplatesListView.SearchTextField(text: $viewModel.text)
                    
                    if let clearButton = viewModel.clearButton {
                        
                        Spacer()
                        Button(action: clearButton.action, label: { clearButton.icon })
                            .foregroundColor(.black)
                    }
                }
                .overlay13 {
                    
                    VStack(alignment: .leading, spacing: 41) {
                        
                        Text(viewModel.textFieldLabel)
                            .font(.textBodyMR14180())
                            .foregroundColor(.textPlaceholder)
                        
                        Rectangle().frame(height: 1)
                    }
                    .offset(y: -8)
                }
                
                Spacer()
                
                Button(action: viewModel.saveButtonAction) {
                    RoundedRectangle(cornerRadius: 12)
                        .frame(height: 56)
                        .foregroundColor(viewModel.isNameNotValid ? Color.buttonPrimaryDisabled
                                         : Color.buttonPrimary)
                        .overlay13 {
                            Text(viewModel.saveButtonText)
                                .font(.textH3Sb18240())
                                .foregroundColor(.textWhite)
                        }
                }
                .disabled(viewModel.isNameNotValid)
            }
            .frame(height: 210)
            .padding()
        }
    }
    
    struct ProductListView: View {
        
        @ObservedObject var viewModel: TemplatesListViewModel.ProductListViewModel
        
        let parentHeight: CGFloat
        
        private var height: CGFloat {
            
            max(0, min(viewModel.containerHeight, parentHeight - 70))
        }
        
        var body: some View {
            
            VStack(alignment: .leading, spacing: 15) {
                
                Text(viewModel.title)
                    .font(.textH3Sb18240())
                    .foregroundColor(.textSecondary)
                    .padding(.leading)
                
                ScrollView {
                    
                    VStack(spacing: 16) {
                        
                        ForEach(viewModel.sections) { sectionVM in
                            
                            MyProductsSectionView(
                                viewModel: sectionVM,
                                editMode: .constant(.inactive)
                            )
                            .onAppear {
                                
                                if ProductType(rawValue: sectionVM.id) == .card {
                                    sectionVM.isCollapsed = false
                                }
                            }
                        }
                    }
                }
                .frame(height: height)
            } //VStack section
            .padding(.bottom, 16)
        }
    }
    
    struct EmptyTemplateListView: View {
        
        let viewModel: TemplatesListViewModel.EmptyTemplateListViewModel
        
        var body: some View {
            
            VStack(spacing: 0) {
                
                viewModel.icon
                    .resizable()
                    .renderingMode(.original)
                    .frame(width: 64, height: 64)
                    .background(Circle().foregroundColor(.gray))
                
                Text(viewModel.title)
                    .font(.textH2Sb20282())
                    .foregroundColor(.textSecondary)
                    .padding(.top, 20)
                
                Text(viewModel.message)
                    .multilineTextAlignment(.center)
                    .font(.textH4R16240())
                    .foregroundColor(.textPlaceholder)
                    .lineSpacing(6)
                    .padding(.top, 16)
                    .padding(.horizontal, 50)
                
                Button {
                    
                    viewModel.button.action()
                    
                } label: {
                    
                    ZStack {
                        
                        Color.buttonSecondary
                            .cornerRadius(8)
                        
                        Text(viewModel.button.title)
                            .font(.textH3Sb18240())
                            .foregroundColor(.textSecondary)
                    }
                }
                .frame(height: 48)
                .padding(.top, 24)
            }
            .padding()
        }
    }
    
    struct PlaceholderView: View {
        
        let style: TemplatesListViewModel.Style
        let columns = [GridItem(.flexible(), spacing: 16), GridItem(.flexible())]
        
        var body: some View {
            
            VStack(alignment: .leading, spacing: 0) {
                
                HStack(spacing: 8) {
                    
                    ForEach(0..<3) { _ in
                        
                        RoundedRectangle(cornerRadius: 90)
                            .frame(width: 100, height: 32)
                            .shimmering(bounce: true)
                    }
                }
                .padding(.bottom, 20)
                
                switch style {
                case .list:
                    
                    ForEach(0..<3) { _ in
                        
                        RoundedRectangle(cornerRadius: 12)
                            .frame(height: 72)
                            .padding(.bottom, 12)
                            .shimmering(bounce: true)
                    }
                    
                case .tiles:
                    
                    LazyVGrid(columns: columns, spacing: 16) {
                        
                        ForEach(0..<3) { _ in
                            
                            RoundedRectangle(cornerRadius: 12)
                                .frame(height: 188)
                                .shimmering(bounce: true)
                        }
                    }
                }
                
                Spacer()
            }
            .foregroundColor(.mainColorsGrayMedium.opacity(0.9))
            .padding()
        }
    }
    
    struct DeletePannelView: View {
        
        let viewModel: TemplatesListViewModel.DeletePannelViewModel
        
        var body: some View {
            
            ZStack(alignment: .bottom) {
                
                Color.barsBars.opacity(0.82)
                    .edgesIgnoringSafeArea(.bottom)
                
                HStack {
                    
                    Text(viewModel.description)
                        .font(.textH4M16240())
                        .padding(.leading, 20)
                    
                    Spacer()
                    
                    TemplatesListView
                        .PanelButtonView(viewModel: viewModel.selectAllButton)
                    
                    Spacer()
                    
                    TemplatesListView
                        .PanelButtonView(viewModel: viewModel.deleteButton)
                        .padding(.trailing, 30)
                    
                }
                .background(Color.barsBars.opacity(0.82))
            }
            .frame(height: 56)
        }
    }
    
    struct PanelButtonView: View {
        
        let viewModel: TemplatesListViewModel.PanelButtonViewModel
        
        var body: some View {
            
            Button(action: viewModel.action) {
                
                VStack(spacing: 4) {
                    
                    viewModel.icon
                        .resizable()
                        .renderingMode(.template)
                        .frame(width: 24, height: 24)
                    
                    Text(viewModel.title)
                        .font(.textBodyMR14180())
                }
                .foregroundColor(.black)
            }
            .disabled(viewModel.isDisable)
            .opacity(viewModel.isDisable ? 0.5 : 1.0)
        }
    }
    
    struct BackgroundListView: View {
        
        var body: some View {
            
            Color.mainColorsGrayLightest
                .cornerRadius(16)
                .padding(.vertical, 6)
                .background(Color.white)
        }
    }
}

//MARK: - Helpers

extension TemplatesListView {
    
    struct listRowSeparatorTint: ViewModifier {
        
        func body(content: Content) -> some View {
            
            if #available(iOS 15.0, *) {
                content
                    .listRowSeparatorTint(.white)
            } else { //iOS14
                content
            }
        }
    }
    
    struct trailingSwipeAction: ViewModifier {
        
        let viewModel: [TemplatesListViewModel.ItemViewModel.ItemActionViewModel]?
        let item: TemplatesListViewModel.ItemViewModel
        
        func body(content: Content) -> some View {
            
            if #available(iOS 15.0, *) {
                content
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        
                        if let viewModel, !item.state.isProcessing {
                            
                            ForEach(viewModel) { button in
                                
                                Button(action: { button.action(item.id) }) {
                                    
                                    button.icon
                                        .renderingMode(.original)
                                        .tint(.black)
                                }
                                .tint(.white)
                            }
                            
                        } else {
                            
                            EmptyView()
                        }
                    }
                
            } else { //iOS14
                content //TODO: Swipe
            }
        }
    }
}

// MARK: - Previews

struct TemplatesListView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        Group {
            
            TemplatesListView
                .ProductListView(viewModel: .init(sections: [.sample2]), parentHeight: 500)
                .previewDisplayName("Product List View")
            
            TemplatesListView
                .RenameTemplateItemView(viewModel: .init(oldName: "Old Name", templateID: 1))
                .previewDisplayName("Rename View")
            
            NavigationView {
                TemplatesListView(viewModel: .sampleComplete, viewFactory: .preview)
                    .environment(\.mainViewSize, CGSize(width: 414, height: 800))
                
            }
            .previewDisplayName("TemplatesView List")
            
            NavigationView {
                TemplatesListView(viewModel: .sampleTiles, viewFactory: .preview)
            }
            .previewDisplayName("TemplatesView Tiles")
            
            NavigationView {
                TemplatesListView(viewModel: .sampleDeleting, viewFactory: .preview)
            }
            
            TemplatesListView.EmptyTemplateListView(viewModel: .sample)
                .previewDisplayName("Empty State")
            
            TemplatesListView.PlaceholderView(style: .tiles)
                .previewDisplayName("Placeholder")
        }
    }
}

extension TemplatesListViewFactory {
    
    static let preview: Self = .init(
        makeOptionSelectorView: {_ in fatalError() },
        makePaymentsMeToMeView: {_ in fatalError() },
        makePaymentsSuccessView: {_ in fatalError() },
        makePaymentsView: {_ in fatalError() }
    )
}
