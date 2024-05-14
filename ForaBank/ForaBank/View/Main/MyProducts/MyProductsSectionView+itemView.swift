//
//  MyProductsSectionView+itemView.swift
//  ForaBank
//
//  Created by Andryusina Nataly on 13.05.2024.
//

import SwiftUI

extension MyProductsSectionView {
    
    func itemView(
        _ itemVM: MyProductsSectionItemViewModel
    ) -> some View {
        
        return MyProductsSectionItemView(viewModel: itemVM, editMode: $editMode)
            .modifier(ItemModifier(itemVM: itemVM, editMode: editMode))
    }
}

private extension MyProductsSectionView {
    
    struct ItemModifier : ViewModifier {
        
        let itemVM: MyProductsSectionItemViewModel
        let editMode: EditMode
        
        func body(content: Content) -> some View {
            
            if #available(iOS 15.0, *) {
                content
                    .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                    .listSectionSeparator(.hidden, edges: .bottom)
                    .listRowSeparatorTint(.mainColorsGrayMedium.opacity(0.6))
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        
                        if let actionButtonViewModel = itemVM.actionButton(for: .init(with: .trailing)) {
                            
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
                                
                                itemVM.action.send(MyProductsSectionItemAction.Swiped(
                                    direction: .left, editMode: editMode))
                            }, rightAction: {
                                
                                itemVM.action.send(MyProductsSectionItemAction.Swiped(
                                    direction: .right, editMode: editMode))
                            })
                    )
            }
        }
    }
}
