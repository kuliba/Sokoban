//
//  ProductProfileDetailFooterViewComponent.swift
//  ForaBank
//
//  Created by Max Gribov on 17.06.2022.
//

import SwiftUI

//MARK: - View Model

extension ProductProfileDetailView.ViewModel {
    
    struct FooterViewModel {
        
        let items: [ProductProfileDetailView.ViewModel.AmountViewModel]
    }
}

//MARK: - View

extension ProductProfileDetailView {
    
    struct FooterView: View {
        
        let viewModel: ProductProfileDetailView.ViewModel.FooterViewModel
        
        var body: some View {
            
            if #available(iOS 14, *) {
                
                LazyVGrid(columns: [.init(.flexible()), .init(.flexible())], alignment: .leading, spacing: 4) {
                    
                    ForEach(viewModel.items) { itemViewModel in
                        
                        ProductProfileDetailView.AmountView(viewModel: itemViewModel)
                    }
                }
                
            } else {
                
                //TODO: real implementation required
                HStack(spacing: 4) {
                    
                    ForEach(viewModel.items) { item in
                        
                        ProductProfileDetailView.AmountView(viewModel: item)
                    }
                }
            }
        }
    }
}

//MARK: - Preview

struct ProductProfileDetailFooterViewComponent_Previews: PreviewProvider {
    static var previews: some View {
        
        ZStack {
            
            Color.black
            
            ProductProfileDetailView.FooterView(viewModel: .sample)
                .padding(.horizontal, 20)
        }
        .previewLayout(.fixed(width: 375, height: 300))
    }
}

//MARK: - Preview Content

extension ProductProfileDetailView.ViewModel.FooterViewModel {
    
    static let sample = ProductProfileDetailView.ViewModel.FooterViewModel(items: [.sample, .sampleInfo, .sampleCheckmark, .sampleBackground])
}
