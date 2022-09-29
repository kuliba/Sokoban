//
//  ProductsMeToMeView.swift
//  ForaBank
//
//  Created by Pavel Samsonov on 26.09.2022.
//

import SwiftUI

// MARK: - View

struct ProductsMeToMeView: View {
    
    @ObservedObject var viewModel: ProductsMeToMeViewModel
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 0) {
            
            Text(viewModel.title)
                .font(.textH3SB18240())
                .foregroundColor(.mainColorsBlack)
                .padding(.horizontal, 20)
            
            VStack {
                
                ProductsSwapView(viewModel: viewModel.swapViewModel)
                PaymentsAmountView(viewModel: viewModel.paymentsAmount)
            }
        }
    }
}

// MARK: - Previews

struct ProductsMeToMeView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        Group {
            
            ProductsMeToMeView(
                viewModel: .init(
                    model: .emptyMock,
                    items: [.sample1, .sample2],
                    amount: 150))
            
            ProductsMeToMeView(
                viewModel: .init(
                    model: .emptyMock,
                    items: [.sample1, .sample4],
                    amount: 150))
        }
        .previewLayout(.sizeThatFits)
        .padding(.top)
    }
}
