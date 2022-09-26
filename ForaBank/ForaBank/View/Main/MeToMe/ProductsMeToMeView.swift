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
        
        VStack(alignment: .leading, spacing: 20) {
            
            Text(viewModel.title)
                .font(.textH3SB18240())
                .foregroundColor(.mainColorsBlack)
            
            VStack(spacing: 0) {
                
                ProductsSwapView(viewModel: viewModel.swapViewModel)
                PaymentsAmountView(viewModel: viewModel.paymentsAmount)
            }
            
        }.padding(.horizontal, 20)
    }
}

// MARK: - Previews

struct ProductsMeToMeView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        ProductsMeToMeView(viewModel: .init(model: .emptyMock, items: [.sample1, .sample2], amount: 150))
            .previewLayout(.sizeThatFits)
            .padding(.vertical)
    }
}
