//
//  PaymentsProductSelectorViewComponet.swift
//  ForaBank
//
//  Created by Max Gribov on 15.03.2022.
//

import SwiftUI

//MARK: - View Model

extension PaymentsProductSelectorView {
    
    class ViewModel: ObservableObject {
        
        @Published var categories: OptionSelectorView.ViewModel
        @Published var products: [ProductView.ViewModel]
        
        init(categories: OptionSelectorView.ViewModel, products: [ProductView.ViewModel]) {
            
            self.categories = categories
            self.products = products
        }
    }
}

//MARK: - View

struct PaymentsProductSelectorView: View {
    
    @ObservedObject var viewModel: ViewModel
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 16) {
            
            OptionSelectorView(viewModel: viewModel.categories)
                .frame(height: 24)
            
            ScrollView(.horizontal, showsIndicators: false) {
                
                HStack(spacing: 8) {
                    
                    ForEach(viewModel.products) { productViewModel in
                        
                        ProductView(viewModel: productViewModel)
                            .frame(width: 112, height: 72)
                    }
                }
            }
        }
    }
}

//MARK: - Preview

struct PaymentsProductSelectorView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        PaymentsProductSelectorView(viewModel: .sample)
            .previewLayout(.fixed(width: 375, height: 200))
    }
}

extension PaymentsProductSelectorView.ViewModel {
    
    static let sample = PaymentsProductSelectorView.ViewModel(categories: .init(options: [.init(id: "0", name: "Карты"), .init(id: "1", name: "Счета"), .init(id: "2", name: "Вклады")], selected: "0", style: .products), products: [.classicSmall, .accountSmall])
}
