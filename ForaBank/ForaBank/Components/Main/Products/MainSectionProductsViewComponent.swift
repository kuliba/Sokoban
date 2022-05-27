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
        
        @Published var groups: [MainSectionProductsGroupView.ViewModel]
        @Published var selector: OptionSelectorView.ViewModel?
        @Published var moreButton: MoreButtonViewModel?
        
        private var products: CurrentValueSubject<[ProductType: [ProductView.ViewModel]], Never> = .init([:])

        private let model: Model
        private var bindings = Set<AnyCancellable>()
        
        internal init(groups: [MainSectionProductsGroupView.ViewModel], selector: OptionSelectorView.ViewModel?, moreButton: MoreButtonViewModel?, model: Model = .emptyMock, isCollapsed: Bool) {
            
            self.groups = groups
            self.selector = selector
            self.moreButton = moreButton
            self.model = model
            super.init(isCollapsed: isCollapsed)
        }
        
        init(_ model: Model) {
            
            self.groups = []
            self.selector = nil
            self.moreButton = nil
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
                                    guard let productViewModel = ProductView.ViewModel(with: product, action: { [weak self] in  self?.action.send(MainSectionViewModelAction.Products.ProductDidTapped(productId: product.id)) }) else {
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
                    
                    bind(groups)
                    
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
                                
                                selector = OptionSelectorView.ViewModel(options: options, selected: options[0].id, style: .products, mode: .action)
                            }
  
                            bind(selector)
                        }
                        
                    } else {
                        
                        withAnimation {
                            
                            selector = nil
                        }
                    }
                    
                }.store(in: &bindings)
            
            model.productsUpdating
                .receive(on: DispatchQueue.main)
                .sink {[unowned self] productsUpdating in
                     
                    for productType in ProductType.allCases {
                        
                        guard let group = groups.first(where: { $0.productType == productType}) else {
                            continue
                        }
                        
                        let isUpdating = productsUpdating.contains(productType) ? true : false
                        
                        guard group.isUpdating != isUpdating else {
                            continue
                        }
                        
                        group.isUpdating = isUpdating
                    }
       
                }.store(in: &bindings)
            
            action
                .receive(on: DispatchQueue.main)
                .sink {[unowned self] action in
                    
                    switch action {
                    case let payload as MainSectionViewModelAction.Products.HorizontalOffsetDidChanged:
                        updateSelector(with: payload.offset)
                        
                    default:
                        break
                    }
                    
                }.store(in: &bindings)
            
            $isCollapsed
                .receive(on: DispatchQueue.main)
                .sink {[unowned self] isCollapsed in
                    
                    withAnimation {
                        
                        if isCollapsed == true {
                            
                            moreButton = nil
                            
                        } else {
                            
                            moreButton = MoreButtonViewModel(icon: .ic24MoreHorizontal, action: {[weak self] in self?.action.send(MainSectionViewModelAction.Products.MoreButtonTapped())})
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
                                  let group = groups.first(where: { $0.productType == productType}) else {
                                return
                            }
                            
                            self.action.send(MainSectionViewModelAction.Products.ScrollToGroup(groupId: group.id))
                            
                        default:
                            break
                        }
                        
                    }.store(in: &bindings)
            }
        }
        
        private func bind(_ groups: [MainSectionProductsGroupView.ViewModel]) {
            
            for group in groups {
                
                group.action
                    .receive(on: DispatchQueue.main)
                    .sink {[unowned self] action in
                        
                        switch action {
                        case _ as MainSectionProductsGroupAction.Group.Collapsed:
                            self.action.send(MainSectionViewModelAction.Products.ScrollToGroup(groupId: group.id))
                            
                        default:
                            break
                        }
                        
                    }.store(in: &bindings)
                    
            }
            
        }

        private func updateSelector(with offset: CGFloat) {
            
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

//MARK: - View

struct MainSectionProductsView: View {
    
    @ObservedObject var viewModel: ViewModel
    @State private var scrollView: UIScrollView? = nil

    var body: some View {
        
        CollapsableSectionView(title: viewModel.title, edges: .horizontal, padding: 20, isCollapsed: $viewModel.isCollapsed) {
            
            VStack(spacing: 16) {
                
                if let selectorViewModel = viewModel.selector {
                    
                    OptionSelectorView(viewModel: selectorViewModel)
                        .frame(height: 24)
                        .padding(.leading, 20)
                }
                
                ScrollView(.horizontal, showsIndicators: false) {
                    
                    ScrollViewReader { proxy in
                        
                        HStack(spacing: 8) {
    
                            ForEach(viewModel.groups) { groupViewModel in
                                
                                MainSectionProductsGroupView(viewModel: groupViewModel)
                            }
                        }
                        .padding(.horizontal, 20)
                        .introspectScrollView(customize: { scrollView in
                            
                            self.scrollView = scrollView
                        })
                        .onReceive(viewModel.action) { action in
                            
                            switch action {
                            case let payload as MainSectionViewModelAction.Products.ScrollToGroup:
                                scrollToGroup(groupId: payload.groupId)

                            default:
                                break
                            }
                        }
                        .onReceive(proxy.offset) { offset in
                            
                            viewModel.action.send( MainSectionViewModelAction.Products.HorizontalOffsetDidChanged(offset: offset.x))
                        }
                    }
                }
            }
        }
        .overlay(MoreButtonView(viewModel: viewModel.moreButton).padding(.trailing, 20))
    }
    
    func scrollToGroup(groupId: MainSectionProductsGroupView.ViewModel.ID) {
        
        guard let scrollView = scrollView else {
            return
        }
        
        var offset: CGFloat = 0
        for group in viewModel.groups {
            
            guard group.id != groupId else {
                break
            }
            
            offset += group.width
            offset += 8
        }
        
        let targetRect = CGRect(x: offset, y: 0, width: scrollView.bounds.width , height: scrollView.bounds.height)
        scrollView.scrollRectToVisible(targetRect, animated: true)
    }
}

//MARK: - Views

extension MainSectionProductsView {
    
    struct MoreButtonView: View {
        
        let viewModel: ViewModel.MoreButtonViewModel?
        
        var body: some View {
            
            if let viewModel = viewModel {
                
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
                
            } else {
                
                Color.clear
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
    
    static let sample = MainSectionProductsView.ViewModel(groups: [.sampleWant], selector: nil, moreButton: nil, isCollapsed: false)
}


