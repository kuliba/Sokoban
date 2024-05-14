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
            
            title()
            itemsList(viewModel.items)
        }
        .background(Color.barsBars)
        .cornerRadius(12)
        .padding(.horizontal, 16)
    }
    
    private func title() -> some View {
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

struct MyProductsSectionView_Previews: PreviewProvider {
    
    static var previews: some View {
        MyProductsSectionView(viewModel: .sample2, editMode: .constant(.inactive))
            .previewLayout(.sizeThatFits)
    }
}
