//
//  MyProductsSectionView+itemsView.swift
//  ForaBank
//
//  Created by Andryusina Nataly on 13.05.2024.
//

import SwiftUI

extension MyProductsSectionView {
    
    func itemsList(
        _ items: [MyProductsSectionViewModel.ItemViewModel]
    ) -> some View {
        
        List {
            ForEach(items) { item in
                switch item {
                case let .item(itemVM):
                    itemView(itemVM)
                case .placeholder:
                    placeholderView()
                }
            }
            .onMove { indexes, destination in
                guard let first = indexes.first else { return }
                
                viewModel.action.send(MyProductsSectionViewModelAction
                    .Events.ItemMoved(sectionId: viewModel.id, move: (first, destination)))
            }
            .moveDisabled(editMode != .active)
        }
        .frame(height: viewModel.isCollapsed ? 0 : 72 * CGFloat(viewModel.items.count) + 0)
        .listStyle(.plain)
        .environment(\.editMode, $editMode)
        .opacity(viewModel.isCollapsed ? 0 : 1)
        .id(viewModel.idList)
    }
    
    func itemsList(
        _ items: [ProductData.ID]
    ) -> some View {
        
        List {
            ForEach(items, id: \.self) { id in
                                
                if let products = viewModel.groupingCards[id] {
                    
                    if products.count == 1, let productData = products.first {
                        itemView(viewModel.createSectionItemViewModel(productData))
                    } else {
                        _itemsList(products.compactMap {
                            if $0.id != id {
                                return viewModel.createSectionItemViewModel($0)
                            } else { return nil}
                        }, id)
                        .listRowInsets(EdgeInsets())
                    }
                }
            }
            .onMove { indexes, destination in
                guard let first = indexes.first else { return }
                
                viewModel.action.send(MyProductsSectionViewModelAction
                    .Events.ItemMoved(sectionId: viewModel.id, move: (first, destination)))
            }
            .moveDisabled(editMode != .active)
        }
        .frame(height: viewModel.isCollapsed ? 0 : 72 * CGFloat(viewModel.items.count) + 0)
        .listStyle(.plain)
        .environment(\.editMode, $editMode)
        .opacity(viewModel.isCollapsed ? 0 : 1)
        .id(viewModel.idList)
    }
    
    func _itemsList(
        _ items: [MyProductsSectionItemViewModel],
        _ mainProductID: ProductData.ID
    ) -> some View {
        
        List {
            mainCardView(mainProductID)
            
            ForEach(items, id: \.id) { item in
                itemView(item)
                    .listRowInsets(EdgeInsets())
            }
            .onMove { indexes, destination in
                guard let first = indexes.first else { return }
                
                viewModel.action.send(MyProductsSectionViewModelAction
                    .Events.ItemMoved(sectionId: "\(mainProductID)", move: (first, destination)))
            }
            .moveDisabled(editMode != .active)
        }
        .frame(height: 72 * CGFloat(items.count + 1))
        .listStyle(.plain)
        .environment(\.editMode, $editMode)
        .id(mainProductID)
        .listRowBackground(Color.barsBars)
    }
    
    func itemView(
        _ itemModel: MyProductsSectionItemViewModel
    ) -> some View {
        
        return MyProductsSectionItemView(viewModel: itemModel, editMode: $editMode, openProfile: { viewModel.openProfile(productID: itemModel.id)})
            .modifier(ItemModifier(viewModel: itemModel, editMode: editMode))
    }
    
    private func placeholderView() -> some View {
        
        return MyProductsSectionItemView.PlaceholderItemView(editMode: $editMode)
            .modifier(PlaceholderItemModifier())
    }
}

private extension MyProductsSectionView {
    
    struct ItemModifier : ViewModifier {
        
        let viewModel: MyProductsSectionItemViewModel
        let editMode: EditMode
        
        func body(content: Content) -> some View {
            
            if #available(iOS 15.0, *) {
                content
                    .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                    .listSectionSeparator(.hidden, edges: .bottom)
                    .listRowSeparatorTint(.mainColorsGrayMedium.opacity(0.6))
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        
                        if let actionButtonViewModel = viewModel.actionButton(for: .init(with: .trailing)) {
                            
                            Button(action: actionButtonViewModel.action) {
                                
                                Text(actionButtonViewModel.type.title)
                                
                            }.tint(actionButtonViewModel.type.color)
                            
                        } else {
                            
                            EmptyView()
                        }
                    } //swipe
                    .frame(height: 72, alignment: .leading)
                    .listRowBackground(Color.barsBars)
            } else {
                content
                    .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                    .frame(height: 72, alignment: .bottomLeading)
                    .listRowBackground(Color.barsBars)
                    .modifier(
                        SwipeSidesModifier(
                            leftAction: {
                                
                                viewModel.action.send(MyProductsSectionItemAction.Swiped(
                                    direction: .left, editMode: editMode))
                            }, rightAction: {
                                
                                viewModel.action.send(MyProductsSectionItemAction.Swiped(
                                    direction: .right, editMode: editMode))
                            })
                    )
            }
        }
    }
}

private extension MyProductsSectionView {
    
    struct PlaceholderItemModifier : ViewModifier {
        
        func body(content: Content) -> some View {
            
            if #available(iOS 15.0, *) {
                content
                    .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                    .listSectionSeparator(.hidden, edges: .bottom)
                    .listRowSeparatorTint(.mainColorsGrayMedium.opacity(0.6))
                    .listRowBackground(Color.barsBars)
            } else {
                content
                    .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                    .listRowBackground(Color.barsBars)
            }
        }
    }
}
