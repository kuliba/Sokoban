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
            
            header()
            if viewModel.groupingCards.isEmpty {
                itemsList(viewModel.items)
            } else {
                itemsList(viewModel.itemsId)
            }
        }
        .background(Color.barsBars)
        .cornerRadius(12)
        .padding(.horizontal, 16)
    }
    
    private func header() -> some View {
        
        return HStack(alignment: .center) {
            Text(viewModel.title)
                .font(.textH3Sb18240())
                .foregroundColor(.textSecondary)
            
            Color.barsBars
            
            Image.ic24ChevronDown
                .rotationEffect(viewModel.isCollapsed ? .degrees(0) : .degrees(-180))
                .foregroundColor(.iconGray)
        }
        .padding(.horizontal, 12)
        .frame(height: 48)
        .onTapGesture {
            
            withAnimation { viewModel.isCollapsed.toggle() }
        }
    }
}

extension MyProductsSectionView {
    
    private func itemsList(
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
    
    private func itemsList(
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
    
    private func _itemsList(
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
    
    private func itemView(
        _ itemModel: MyProductsSectionItemViewModel
    ) -> some View {
        
        return MyProductsSectionItemView(viewModel: itemModel, editMode: $editMode, openProfile: { viewModel.openProfile(productID: itemModel.id)})
            .modifier(ItemModifier(viewModel: itemModel, editMode: editMode))
    }
    
    private func placeholderView() -> some View {
        
        return MyProductsSectionItemView.PlaceholderItemView(editMode: $editMode)
            .modifier(PlaceholderItemModifier())
    }
    
    private func mainCardView(
        _ productID: ProductData.ID
    ) -> some View {
        
        if let product = viewModel.productByID(productID) {
            AnyView(itemView(viewModel.createSectionItemViewModel(product)))
        } else {
            AnyView(defaultMainCard())
        }
    }
    
    private func defaultMainCard() -> some View {
        
        HStack(spacing: 16) {
            
            Image.ic32GreySimple
                .renderingMode(.original)
                .resizable()
                .scaledToFit()
                .frame(width: 32)
                .accessibilityIdentifier("DefaultMainCardProductIcon")
            
            Image.ic16MainCardGrey
                .renderingMode(.template)
                .resizable()
                .aspectRatio(1, contentMode: .fit)
                .frame(width: 16, height: 16, alignment: .center)
                .foregroundColor(.mainColorsGray)
                .accessibilityIdentifier("DefaultMainCardCloverIcon")
            
            Text("Основная карта")
                .lineLimit(1)
                .font(.textH4M16240())
                .foregroundColor(.mainColorsBlack)
                .accessibilityIdentifier("DefaultMainCardName")
        }
        .listRowInsets(EdgeInsets())
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: 72)
        .padding(.leading, 12)
        .background(Color.barsBars)
        .gesture(DragGesture(minimumDistance: 0, coordinateSpace: .local)
            .onEnded({ value in
                // disable right swipe
                if value.translation.width > 0 {
                }
            }))
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

struct MyProductsSectionView_Previews: PreviewProvider {
    
    static var previews: some View {
        MyProductsSectionView(viewModel: .sample2, editMode: .constant(.inactive))
            .previewLayout(.sizeThatFits)
    }
}
