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
            
            List {
                ForEach($viewModel.items) { $item in
                    
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
            
        } //VStack section
        .background(Color.barsBars)
        .cornerRadius(12)
        .padding(.horizontal, 16)
        
    } //body
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
