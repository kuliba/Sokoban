//
//  MyProductsSectionView+itemView.swift
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
                    MyProductsSectionItemView.PlaceholderItemView(editMode: $editMode)
                        .modifier(PlaceholderItemModifier())
                } //switch
            } //for
            .onMove { indexes, destination in
                guard let first = indexes.first else { return }
                
                viewModel.action.send(MyProductsSectionViewModelAction
                    .Events.ItemMoved(sectionId: viewModel.id, move: (first, destination)))
            }
            .moveDisabled(editMode != .active)
        } //List
        .frame(height: viewModel.isCollapsed ? 0 : 72 * CGFloat(viewModel.items.count) + 0)
        .listStyle(.plain)
        .environment(\.editMode, $editMode)
        .opacity(viewModel.isCollapsed ? 0 : 1)
        .id(viewModel.idList)
    }
    
    private func itemView(
        _ viewModel: MyProductsSectionItemViewModel
    ) -> some View {
        
        return MyProductsSectionItemView(viewModel: viewModel, editMode: $editMode)
            .modifier(ItemModifier(viewModel: viewModel, editMode: editMode))
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
