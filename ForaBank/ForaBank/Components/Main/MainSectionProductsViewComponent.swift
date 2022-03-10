//
//  MainSectionProductsViewComponent.swift
//  ForaBank
//
//  Created by Max Gribov on 21.02.2022.
//

import Foundation
import SwiftUI
import Combine
import ScrollViewProxy

//MARK: - ViewModel

extension MainSectionProductsView {
    
    class ViewModel: MainSectionCollapsableViewModel {
        
        override var type: MainSectionType { .products }
        @Published var typeSelector: OptionSelectorViewModel?
        @Published var selectedTypeId: Option.ID = ""
        @Published var items: [MainSectionProductsListItemViewModel]
        let moreButton: MoreButtonViewModel
        
        private var productsViewModels: CurrentValueSubject<[ProductType: [ProductView.ViewModel]], Never> = .init([:])
        private var productsGroupsState: CurrentValueSubject<[ProductType: Bool], Never> = .init([:])
        private let model: Model
        private var bindings = Set<AnyCancellable>()
        
        internal init(productsTypeSelector: OptionSelectorViewModel?, products: [MainSectionProductsListItemViewModel], moreButton: MoreButtonViewModel, model: Model = .emptyMock, isCollapsed: Bool) {
            
            self.typeSelector = productsTypeSelector
            self.items = products
            self.moreButton = moreButton
            self.model = model
            super.init(isCollapsed: isCollapsed)
            
            bind()
            
            if let typeSelector = typeSelector {
                
                bind(typeSelector: typeSelector)
            }
        }
        
        init(_ model: Model) {
            
            self.typeSelector = nil
            self.items = []
            self.moreButton = .init(icon: .ic24MoreHorizontal, action: {})
            self.model = model
            super.init(isCollapsed: false)
            
            bind()
        }
        
        private func bind() {
            
            model.products
                .receive(on: DispatchQueue.main)
                .sink {[unowned self] products in
                    
                    //TODO: update products view models
                    
                }.store(in: &bindings)
            
            $isCollapsed
                .receive(on: DispatchQueue.main)
                .sink {[unowned self] isCollapsed in
                    
                    if let typeSelector = typeSelector {
                        
                        selectedTypeId = typeSelector.selected
                    }
                    
                }.store(in: &bindings)
        }
        
        private func bind(typeSelector: OptionSelectorViewModel) {
            
            typeSelector.$selected
                .receive(on: DispatchQueue.main)
                .sink {[unowned self] selectedId in
                    
                    selectedTypeId = selectedId
                    
                }.store(in: &bindings)
        }

        func updateSelector(with offset: CGFloat) {
            
            //TODO: implementation required
        }
        
        struct MoreButtonViewModel {
            
            let icon: Image
            let action: () -> Void
        }
    }
}

//MARK: - View

struct MainSectionProductsView: View {
    
    @ObservedObject var viewModel: ViewModel

    var body: some View {
        
        MainSectionCollapsableView(title: viewModel.title, isCollapsed: $viewModel.isCollapsed) {
            
            VStack(spacing: 16) {
                
                if let productSelectorViewModel = viewModel.typeSelector {
                    
                    OptionSelectorView(viewModel: productSelectorViewModel)
                        .frame(height: 24)
                }
                
                ScrollView(.horizontal, showsIndicators: false) {
                    
                    ScrollViewReader { proxy in
                        
                        ContentView(items: viewModel.items)
                            .frame(height: 104)
                            .onReceive(viewModel.$selectedTypeId) { selectedId in

                                proxy.scrollTo(selectedId, alignment: .leading, animated: true)
                                
                            }
                            .onReceive(proxy.offset) { offset in
                                
                                viewModel.updateSelector(with: offset.x)
                            }
                    }
                }
            }
        }
        .overlay(MoreButtonView(viewModel: viewModel.moreButton))
    }
}

//MARK: - Views

extension MainSectionProductsView {
    
    struct ContentView: View {
        
        let items: [MainSectionProductsListItemViewModel]
        
        var body: some View {
            
            HStack(spacing: 8) {
                
                ForEach(items) { itemViewModel in
                    
                    switch itemViewModel {
                    case let cardViewModel as ProductView.ViewModel:
                        ProductView(viewModel: cardViewModel)
                            .frame(width: 164)
                            .scrollId(itemViewModel.id)
   
                    case let expandButtonViewModel as ExpandButtonViewModel:
                        MainSectionProductsView.ExpandButtonView(viewModel: expandButtonViewModel)
                        
                    case let separatorViewModel as SeparatorViewModel:
                        MainSectionProductsView.SeparatorView(viewModel: separatorViewModel)
                        
                    default:
                        EmptyView()
                    }
                }
            }
        }
    }
    
    struct MoreButtonView: View {
        
        let viewModel: ViewModel.MoreButtonViewModel
        
        var body: some View {
            
            VStack {
                
                HStack {
                    
                    Spacer()
                    
                    Button(action: viewModel.action){
                        
                        ZStack{
                            
                            Circle()
                                .frame(width: 32, height: 32, alignment: .center)
                                .foregroundColor(.mainColorsGrayLightest)
                            
                            viewModel.icon
                                .renderingMode(.original)
                        }
                    }
                }
                
                Spacer()
            }
        }
    }
}

//MARK: - Expand Button View

extension MainSectionProductsView {
    
    class ExpandButtonViewModel: MainSectionProductsListItemViewModel, ObservableObject {
    
        @Published var title: String
        
        internal init(id: String = UUID().uuidString, title: String) {
            
            self.title = title
            super.init(id: id)
        }
    }
    
    struct ExpandButtonView: View {
        
        @ObservedObject var viewModel: ExpandButtonViewModel
        
        var body: some View {
            
            Button {
                
            } label: {
                
                VStack(alignment: .center) {
                    
                    Spacer()
                    
                    Text(viewModel.title)
                        .font(.system(size: 14))
                    
                    Spacer()
                }
                .padding(12)
                .foregroundColor(.black)
                .background(Color.mainColorsGrayLightest
                                .cornerRadius(12))
                .frame(width: 48)
            }
        }
    }
}

//MARK: - Separator View

extension MainSectionProductsView {
    
    class SeparatorViewModel: MainSectionProductsListItemViewModel {}
    
    struct SeparatorView: View {
        
        let viewModel: SeparatorViewModel
        
        var body: some View {
            
            Capsule()
                .frame(width: 1, height: 60)
                .foregroundColor(.mainColorsGrayLightest)
        }
    }
}

//MARK: - Preview

struct MainSectionProductsView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        MainSectionProductsView(viewModel: .sample)
            .previewLayout(.fixed(width: 375, height: 300))
    }
}

//MARK: - Preview Content

extension MainSectionProductsView.ViewModel {
    
    static let sample = MainSectionProductsView.ViewModel(productsTypeSelector: .init(options: [.init(id: "0", name: "Карты"), .init(id: "1", name: "Счета"), .init(id: "2", name: "Вклады")], selected: "0", style: .products), products: [ProductView.ViewModel.updating, MainSectionProductsView.ExpandButtonViewModel(title: "+5"), ProductView.ViewModel.blocked, ProductView.ViewModel.account, ProductView.ViewModel.account, MainSectionProductsView.SeparatorViewModel(), ProductView.ViewModel.classic], moreButton: .init(icon: .ic24MoreHorizontal, action: {}), isCollapsed: false)
    
}


