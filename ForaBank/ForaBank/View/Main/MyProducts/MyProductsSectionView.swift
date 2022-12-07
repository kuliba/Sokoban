//
//  MyProductsSectionView.swift
//  ForaBank
//
//  Created by Pavel Samsonov on 12.04.2022.
//  Full refactored by Dmitry Martynov on 18.09.2022
//

import SwiftUI

struct MyProductsSectionView: View {
    
    @ObservedObject var viewModel: MyProductsSectionViewModel
    @Binding var editMode: EditMode
    
    var body: some View {
        
        VStack(spacing: 0) {

            HStack(alignment: .center) {

                Text(viewModel.title)
                    .font(.textH3SB18240())
                    .foregroundColor(.textSecondary)

                Color.barsTabbar

                Image.ic24ChevronDown
                    .rotationEffect(viewModel.isCollapsed ? .degrees(0) : .degrees(-180))
                    .foregroundColor(.iconGray)
            }
            .padding(.horizontal, 12)
            .frame(height: 48)
            .onTapGesture {

                withAnimation { viewModel.isCollapsed.toggle() }
            }

            List {
                ForEach($viewModel.items) { $item in
                    
                    switch item {
                        
                    case let .item(itemVM):
                    
                    if #available(iOS 15.0, *) {
                        
                        MyProductsSectionItemView.BaseItemView(viewModel: itemVM, editMode: $editMode)
                            .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                            .listRowSeparator(separatorVisibility(item: item), edges: .bottom)
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
                            .listRowBackground(Color.barsTabbar)
                        
                    } else { //iOS 14
                        
                        MyProductsSectionItemView(viewModel: itemVM, editMode: $editMode)
                            .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                            .frame(height: 72, alignment: .bottomLeading)
                            .listRowBackground(Color.barsTabbar)
                            .modifier(SwipeSidesModifier(leftAction: {
                                
                                itemVM.action.send(MyProductsSectionItemAction.Swiped(
                                                    direction: .left, editMode: editMode))
                            }, rightAction: {
                                
                                itemVM.action.send(MyProductsSectionItemAction.Swiped(
                                                    direction: .right, editMode: editMode))
                            }))
                        
                    } //iOS15
                        
                    case .placeholder:
                        if #available(iOS 15.0, *) {
                            MyProductsSectionItemView.PlaceholderItemView(editMode: $editMode)
                                .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                                .listRowSeparator(separatorVisibility(item: item), edges: .bottom)
                                .listRowSeparatorTint(.mainColorsGrayMedium.opacity(0.6))
                                .listRowBackground(Color.barsTabbar)
                        } else {
                            MyProductsSectionItemView.PlaceholderItemView(editMode: $editMode)
                                .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                                .listRowBackground(Color.barsTabbar)
                        }
                    } //switch
                    } //for
                    .onMove { indexes, destination in
                        guard let first = indexes.first else { return }
                        
                        viewModel.action.send(MyProductsSectionViewModelAction
                                                .Events.ItemMoved(sectionId: viewModel.id, move: (first, destination)))
                    }
            
                } //List
                .frame(height: viewModel.isCollapsed ? 0 : 72 * CGFloat(viewModel.items.count) + 0)
                .listStyle(.plain)
                .environment(\.editMode, $editMode)
                .opacity(viewModel.isCollapsed ? 0 : 1)
                
        } //VStack section
        .background(Color.barsTabbar)
        .cornerRadius(12)
        .padding(.horizontal, 16)

    } //body
     
    @available(iOS 15.0, *)
    func separatorVisibility(item: MyProductsSectionViewModel.ItemViewModel) -> Visibility {
        
        viewModel.items[viewModel.items.count - 1].itemVM?.id == item.id ? .hidden : .visible
    }
    
}

struct MyProductsSectionView_Previews: PreviewProvider {
    
    static var previews: some View {
        MyProductsSectionView(viewModel: .sample2, editMode: .constant(.inactive))
            .previewLayout(.sizeThatFits)
    }
}
