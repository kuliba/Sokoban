//
//  ProductsListViewComponent.swift
//  ForaBank
//
//  Created by Pavel Samsonov on 11.07.2022.
//

import SwiftUI
import Combine

extension ProductsListView {
    
    // MARK: - ViewModel

    class ViewModel: ObservableObject {
        
        let action: PassthroughSubject<Action, Never> = .init()
        
        @Published var products: [ProductView.ViewModel]
        
        init(products: [ProductView.ViewModel]) {
            self.products = products
        }
    }
}

// MARK: - View

struct ProductsListView: View {
    
    @ObservedObject var viewModel: ViewModel
    
    var body: some View {
        
        ScrollView(.horizontal, showsIndicators: false) {
            
            HStack(spacing: 8) {
                
                ForEach(viewModel.products) { product in
                    ProductView(viewModel: product)
                        .frame(width: 112, height: 72)
                        .onTapGesture {
                            
                            viewModel.action.send(
                                ProductsListAction.SelectedProduct(
                                    productId: product.id))
                        }
                }
            }.padding(.horizontal, 20)
        }
    }
}

enum ProductsListAction {
    
    struct SelectedProduct: Action {
        
        let productId: Int
    }
}

// MARK: - Preview Content

extension ProductsListView.ViewModel {
    
    static let sample = ProductsListView.ViewModel(products: [
        .classicSmall, .accountSmall, .accountSmall
    ])
}

// MARK: - Previews

struct ProductsListViewComponent_Previews: PreviewProvider {
    static var previews: some View {
        ProductsListView(viewModel: .sample)
            .previewLayout(.sizeThatFits)
            .padding()
    }
}
