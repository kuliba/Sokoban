//
//  MyProductsSectionViewModel.swift
//  ForaBank
//
//  Created by Pavel Samsonov on 12.04.2022.
//  Full refactored by Dmitry Martynov on 18.09.2022
//

import Foundation
import SwiftUI
import Combine

class MyProductsSectionViewModel: ObservableObject, Identifiable {

    let action: PassthroughSubject<Action, Never> = .init()
    
    @Published var items: [ItemViewModel]
    @Published var isCollapsed: Bool
    @Published var idList: UUID = UUID()

    let id: String
    let title: String
    
    let model: Model
    private var bindings = Set<AnyCancellable>()
    
    var groupingCards: Array.Products = [:]

    enum ItemViewModel: Identifiable {
        case item(MyProductsSectionItemViewModel)
        case placeholder(Int)
        
        var itemVM: MyProductsSectionItemViewModel? {
            switch self {
            case let .item(viewModel): return viewModel
            default: return nil
            }
        }
        
        var id: ProductData.ID  {
            switch self {
            case let .item(viewModel): return viewModel.id
            case let .placeholder(id): return id
            }
        }
    }
    
    var itemsId: [ProductData.ID] {
        
        items.map {
            let id = $0.itemVM?.parentID == -1 ? $0.id : $0.itemVM?.parentID
            return id ?? $0.id
        }.uniqued()
    }
    
    init(
        id: String,
        title: String,
        items: [ItemViewModel],
        groupingCards: Array.Products = [:],
        isCollapsed: Bool,
        model: Model
    ) {

        self.id = id
        self.title = title
        self.isCollapsed = isCollapsed
        self.items = items
        self.model = model
        self.groupingCards = groupingCards
    }
    
    convenience init?(
        productType: ProductType,
        products: [ProductData]?,
        settings: ProductsSectionsSettings,
        model: Model
    ) {
     
        var itemsVM: [ItemViewModel] = []
        var groupingCards : Array.Products = [:]
        if let products = products {
            itemsVM = products.map { .item(.init(productData: $0, model: model)) }
            if productType == .card { groupingCards = products.groupingCards() }
        }
        
        if model.productsOpening.value.contains(productType) {
            itemsVM.append(.placeholder(Int.random(in: Int.min..<0)))
        }
        
        guard !itemsVM.isEmpty else { return nil }
        
        self.init(id: productType.rawValue,
                  title: productType.pluralName,
                  items: itemsVM,
                  groupingCards: groupingCards,
                  isCollapsed: settings.collapsed[productType.rawValue] ?? false,
                  model: model)
        
        bind()
    }
    
    private func bind() {
        
        action
            .receive(on: DispatchQueue.main)
            .sink { [unowned self]  action in
                
                switch action {
                case let payload as MyProductsSectionViewModelAction.Events.ItemMoved:
                    if payload.sectionId == id {
                        self.items = Self.reduce(items: self.items, move: payload.move)
                    } else {
                        // TODO: add reduce for additional

                    }
                    
                default: break
                }
       
        }.store(in: &bindings)
        
        $isCollapsed
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] isCollapsed in
        
                var settings = model.settingsProductsSections
                settings.update(sectionType: self.id, isCollapsed: isCollapsed)
                model.settingsProductsSectionsUpdate(settings)
                
                self.items
                    .compactMap { $0.itemVM }
                    .forEach { item in
                            item.dismissSideButton()
                    }
        
        }.store(in: &bindings)
        
        
        $items
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] items in
                
                let itemsViewModel = items.compactMap {$0.itemVM}
                
                for item in itemsViewModel {
                    
                    item.action
                        .receive(on: DispatchQueue.main)
                        .sink { [unowned self] action in

                            switch action {
                            case let payload as MyProductsSectionItemAction.Swiped:

                                guard item.isSwipeAvailable(direction: payload.direction),
                                      payload.editMode != .active
                                else { return }
                                
                                if item.sideButton != nil {
                                    
                                    withAnimation {
                                        item.sideButton = nil
                                    }
                                    
                                } else {
                                    
                                    guard let actionButton = item.actionButton(for: payload.direction)
                                    else { return }
                                    
                                    itemsViewModel.forEach { $0.dismissSideButton() }
                                    
                                    switch payload.direction {
                                    case .right:
                                        withAnimation {
                                            item.sideButton = .right(actionButton)
                                        }
               
                                    case .left:
                                        withAnimation {
                                            item.sideButton = .left(actionButton)
                                        }
                                    }
                                }
                                
                            default: break
                            }
                    }.store(in: &bindings)
                } //for items
                
        }.store(in: &bindings)
        
    }
    
    static func reduce(items: [ItemViewModel], move: (from: IndexSet.Element, to: Int)) -> [ItemViewModel] {
        
        var updatedItems = items
        let removed = updatedItems.remove(at: move.from)

        if move.from < move.to {
            updatedItems.insert(removed, at: move.to != 0 ? move.to - 1 : 0)
        
        } else {
            updatedItems.insert(removed, at: move.to)
        }
        
        return updatedItems
        
    }
    
    static func reduce(items: [ItemViewModel],
                       products: [ProductData]?,
                       model: Model) -> [ItemViewModel] {
        
        guard let products = products else { return [] }
        
        var updatedItems: [ItemViewModel] = []
            
        for product in products {
            
            if let item = items.first(where: { $0.itemVM?.id == product.id }),
               let itemVM = item.itemVM {
                
                itemVM.update(with: product)
                updatedItems.append(.item(itemVM))
                
            } else {
                
                let itemVM = MyProductsSectionItemViewModel(productData: product, model: model)
                updatedItems.append(.item(itemVM))
            }
        }
        
        return updatedItems
    }
    
    static func reduce(sectionId: MyProductsSectionViewModel.ID,
                       items: [ItemViewModel],
                       productsOpening: Set<ProductType>) -> [ItemViewModel] {
        
        var updatedItems = [ItemViewModel]()
        
        guard let productType = ProductType(rawValue: sectionId),
              productsOpening.contains(productType)
        else { return [] }
        
        if let placeholder = items.first(where: { $0.itemVM == nil }) {
            updatedItems.append(placeholder)
                    
        } else {
            updatedItems.append(.placeholder(Int.random(in: Int.min..<0)))
        }
        
        return updatedItems
    }
    
    func update(with products: [ProductData]?, productsOpening: Set<ProductType>) {
    
        let updatedItems = Self.reduce(sectionId: self.id, items: self.items, productsOpening: productsOpening)
                         + Self.reduce(items: self.items, products: products, model: model)
        
        withAnimation {
            self.items = updatedItems
        }
    }
    
    func openProfile(productID: ProductData.ID) {
        
        self.action.send(MyProductsSectionViewModelAction.Events.ItemTapped(productId: productID))
    }
}

enum MyProductsSectionViewModelAction {
    
    enum Events {
        
        struct ItemMoved: Action {
            let sectionId: MyProductsSectionViewModel.ID
            let move: (from: IndexSet.Element, to: Int)
        }
        
        struct ItemTapped: Action {
            let productId: ProductData.ID
        }
    }
}


extension MyProductsSectionViewModel {
    
    static let sample2 = MyProductsSectionViewModel(
        id: "CARD", title: "Карты",
        items: [.item(.sample7), .item(.sample8)],
        isCollapsed: false, model: .emptyMock)
    
    static let sample3 = MyProductsSectionViewModel(
        id: UUID().uuidString, title: "Вклады",
        items: [.item(.sample9)],
        isCollapsed: true, model: .emptyMock)
    
    static let sample4 = MyProductsSectionViewModel(
        id: UUID().uuidString, title: "Кредиты",
        items: [],
        isCollapsed: false, model: .emptyMock)
    
    static let sample5 = MyProductsSectionViewModel(
        id: UUID().uuidString, title: "Инвестиции",
        items: [],
        isCollapsed: false, model: .emptyMock)
    
    static let sample6 = MyProductsSectionViewModel(
        id: UUID().uuidString, title: "Страховка",
        items: [],
        isCollapsed: false, model: .emptyMock)
}
