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
                .sink {[unowned self] productsUpdate in
                    
                    // all existing products view models list
                    let currentProductsViewModels = products.value.values.flatMap{ $0 }
                    
                    for productType in ProductType.allCases {
                        
                        if let productForType = productsUpdate[productType], productForType.count > 0 {
                            
                            var productsViewModelsUpdated = [ProductView.ViewModel]()
                            for product in productForType {
                                
                                // check if we alredy have view model for product data
                                if let currentProductViewModel = currentProductsViewModels.first(where: { $0.id == product.id }) {
                                    
                                    // just update existing view model with product data
                                    currentProductViewModel.update(with: product)
                                    productsViewModelsUpdated.append(currentProductViewModel)
                                    
                                } else {
                                    
                                    // try to create new product view model
                                    guard let productViewModel = ProductView.ViewModel(with: product, action: { [weak self] in  self?.action.send(MainSectionProductsViewModelAction.ProductDidTapped(productId: product.id)) }) else {
                                        continue
                                    }
                                    productsViewModelsUpdated.append(productViewModel)
                                }
                            }
                            
                            self.products.value[productType] = productsViewModelsUpdated
                            
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
                    
                    withAnimation {
                        
                        groups = groupsUpdated
                    }
                    
                    // create product type selector
                    if groups.count > 1 {
                        
                        let options = groups.map{ Option(id: $0.id, name: $0.productType.pluralName)}
                        
                        if let currentSelector = selector {
                            
                            let optionsIds = options.map{ $0.id }
                            let selected = optionsIds.contains(currentSelector.selected) ? currentSelector.selected : options[0].id
                            
                            withAnimation {
                                
                                currentSelector.update(options: options, selected: selected)
                            }
                            
                        } else {
                            
                            withAnimation {
                                
                                selector = OptionSelectorView.ViewModel(options: options, selected: options[0].id, style: .products)
                            }
  
                            bind(selector)
                        }
                        
                    } else {
                        
                        withAnimation {
                            
                            selector = nil
                        }
                    }
                    
                }.store(in: &bindings)
            
            //FIXME: breaks product type selector
            model.productsUpdating
                .receive(on: DispatchQueue.main)
                .sink {[unowned self] productsUpdating in
                    
                    print("Updating: \(productsUpdating)")
                    
                    withAnimation {
                        
                        for productType in ProductType.allCases {
                            
                            guard let productsForType = self.products.value[productType] else {
                                continue
                            }
                            
                            for product in productsForType {
                                
                                product.isUpdating = productsUpdating.contains(productType) ? true : false
                            }
                        }
                    }
       
                }.store(in: &bindings)
        }
        
        private func bind(_ selector: OptionSelectorView.ViewModel?) {
            
            if let selector = selector {
                
                selector.action
                    .receive(on: DispatchQueue.main)
                    .sink {[unowned self] action in
                        
                        switch action {
                        case let payload as OptionSelectorAction.OptionDidSelected:
                            guard let productType = ProductType(rawValue: payload.optionId),
                                  let group = groups.first(where: { $0.productType == productType}),
                                  let product = group.presented.first else {
                                return
                            }
                            
                            self.action.send(MainSectionProductsViewModelAction.ScrollToProduct(productId: product.id))
                            
                        default:
                            break
                        }
                        
                    }.store(in: &bindings)
            }
        }

        func updateSelector(with offset: CGFloat) {
            
            guard let selector = selector, let productType = productType(with: offset) else {
                return
            }
            
            if selector.selected != productType.rawValue {
                
                withAnimation {
                    
                    self.selector?.selected = productType.rawValue
                }
            }
        }
        
        private func productType(with offset: CGFloat) -> ProductType? {
            
            guard groups.count > 0 else {
                return nil
            }
            
            var currentLength: CGFloat = 0
            for group in groups {
                
                currentLength += group.width
                guard currentLength >= offset else {
                    continue
                }
                
                return group.productType
            }
            
            return groups.last?.productType
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
    
    struct ScrollToProduct: Action {
        
        let productId: ProductView.ViewModel.ID
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
                            case let payload as MainSectionProductsViewModelAction.ScrollToProduct:
                                proxy.scrollTo(payload.productId, alignment: .leading, animated: true)
                                
                            default:
                                break
                            }
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


