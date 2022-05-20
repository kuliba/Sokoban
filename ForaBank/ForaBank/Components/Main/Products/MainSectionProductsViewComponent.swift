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
        
        let action: PassthroughSubject<Action, Never> = .init()
        
        override var type: MainSectionType { .products }
        
        @Published var groups: [MainSectionProductsGroupView.ViewModel]
        @Published var selector: OptionSelectorView.ViewModel?
        
        lazy var moreButton: MoreButtonViewModel = MoreButtonViewModel(icon: .ic24MoreHorizontal, action: {[weak self] in self?.action.send(MainSectionProductsViewModelAction.MoreButtonTapped())})
        
        private var products: CurrentValueSubject<[ProductType: [ProductView.ViewModel]], Never> = .init([:])

        private let model: Model
        private var bindings = Set<AnyCancellable>()
        
        internal init(groups: [MainSectionProductsGroupView.ViewModel], selector: OptionSelectorView.ViewModel?, model: Model = .emptyMock, isCollapsed: Bool) {
            
            self.groups = groups
            self.selector = selector
            self.model = model
            super.init(isCollapsed: isCollapsed)
        }
        
        init(_ model: Model) {
            
            self.groups = []
            self.selector = nil
            self.model = model
            super.init(isCollapsed: false)
            
            bind()
        }
        
        private func bind() {
            
            model.products
                .receive(on: DispatchQueue.main)
                .sink {[unowned self] products in
                    
                    for productType in ProductType.allCases {
                        
                        if let productTypeItems = products[productType], productTypeItems.count > 0 {
                            
                            var productsViewModelsForType = [ProductView.ViewModel]()
                            for product in productTypeItems {
                                
                                //TODO: update product view model if exists
                                guard let productViewModel = ProductView.ViewModel(with: product, action: { [weak self] in  self?.action.send(MainSectionProductsViewModelAction.ProductDidTapped(productId: product.id)) }) else {
                                    continue
                                }
                                productsViewModelsForType.append(productViewModel)
                            }
                            
                            self.products.value[productType] = productsViewModelsForType
                            
                        } else {
                            
                            self.products.value[productType] = nil
                        }
                    }
                    
                }.store(in: &bindings)
            
            products
                .receive(on: DispatchQueue.main)
                .sink {[unowned self] products in
                    
                    var groupsUpdated = [MainSectionProductsGroupView.ViewModel]()
                    
                    for productType in ProductType.allCases {
                        
                        guard let productsForType = products[productType] else {
                            continue
                        }
                        
                        if let groupForType = groups.first(where: { $0.productType == productType}) {
                            
                            groupForType.update(with: productsForType)
                            groupForType.isSeparator = true
                            groupsUpdated.append(groupForType)
                            
                        } else {
                            
                            let group = MainSectionProductsGroupView.ViewModel(productType: productType, products: productsForType)
                            group.isSeparator = true
                            groupsUpdated.append(group)
                        }
                    }
                    
                    groupsUpdated.last?.isSeparator = false
                    groups = groupsUpdated
                    
                    if groups.count > 1 {
                        
                        let options = groups.map{ Option(id: $0.id, name: $0.productType.pluralName)}
                        let selector = OptionSelectorView.ViewModel(options: options, selected: options[0].id, style: .products)
                        bind(typeSelector: selector)
                        self.selector = selector
                    }
                    
                }.store(in: &bindings)
        }
        
        private func bind(typeSelector: OptionSelectorView.ViewModel) {
            
            typeSelector.action
                .receive(on: DispatchQueue.main)
                .sink {[unowned self] action in
                    
                    switch action {
                    case let payload as OptionSelectorAction.OptionDidSelected:
                        self.action.send(MainSectionProductsViewModelAction.ScrollToGroup(groupId: payload.optionId))
                        
                    default:
                        break
                    }
                    
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

//MARK: - Action

enum MainSectionProductsViewModelAction {
    
    struct ProductDidTapped: Action {
        
        let productId: ProductData.ID
    }
    
    struct ScrollToGroup: Action {
        
        let groupId: MainSectionProductsGroupView.ViewModel.ID
    }
    
    struct MoreButtonTapped: Action {}
}

//MARK: - View

struct MainSectionProductsView: View {
    
    @ObservedObject var viewModel: ViewModel

    var body: some View {
        
        CollapsableSectionView(title: viewModel.title, isCollapsed: $viewModel.isCollapsed) {
            
            VStack(spacing: 16) {
                
                if let selectorViewModel = viewModel.selector {
                    
                    OptionSelectorView(viewModel: selectorViewModel)
                        .frame(height: 24)
                }
                
                ScrollView(.horizontal, showsIndicators: false) {
                    
                    ScrollViewReader { proxy in
                        
                        HStack(spacing: 8) {
                            
                            ForEach(viewModel.groups) { groupViewModel in
                                
                                MainSectionProductsGroupView(viewModel: groupViewModel)
                                    .scrollId(groupViewModel.id)
                                    
                            }
                        }
                        .onReceive(viewModel.action) { action in
                            
                            switch action {
                            case let payload as MainSectionProductsViewModelAction.ScrollToGroup:
                                proxy.scrollTo(payload.groupId, alignment: .leading, animated: true)
                                
                            default:
                                break
                            }
                        }
                       
                        
                        /*
                        
                        ContentView(items: viewModel.items)
                            .frame(height: 104)
                            .onReceive(viewModel.$selectedTypeId) { selectedId in

                                proxy.scrollTo(selectedId, alignment: .leading, animated: true)
                                
                            }
                            .onReceive(proxy.offset) { offset in
                                
                                viewModel.updateSelector(with: offset.x)
                            }
                         */
                    }
                }
            }
        }
        .overlay(MoreButtonView(viewModel: viewModel.moreButton))
    }
}

//MARK: - Views

extension MainSectionProductsView {
    
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

//MARK: - Preview

struct MainSectionProductsView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        MainSectionProductsView(viewModel: .sample)
            .previewLayout(.fixed(width: 375, height: 300))
    }
}

//MARK: - Preview Content

extension MainSectionProductsView.ViewModel {
    
    static let sample = MainSectionProductsView.ViewModel(groups: [.sampleWant], selector: nil, isCollapsed: false)
}


