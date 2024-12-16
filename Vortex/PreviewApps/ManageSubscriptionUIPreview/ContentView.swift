//
//  ContentView.swift
//  ManageSubscriptionUIPreview
//
//  Created by Дмитрий Савушкин on 19.07.2023.
//

import ManageSubscriptionsUI
import SearchBarComponent
import TextFieldUI
import TextFieldComponent
import SwiftUI
import Combine

typealias SearchViewModel = ReducerTextFieldViewModel<ToolbarViewModel, KeyboardType>

final class SubscriptionsViewModel: ObservableObject {
    
    @Published private(set) var products: [Product]
    let searchViewModel: SearchViewModel
    
    init(
        products: [Product],
        searchViewModel: SearchViewModel
    ) {
        
        self.products = products
        self.searchViewModel = searchViewModel
    }
}

struct Product: ManageSubscriptionsUI.Product {
    
    let id = UUID()
    let image: Image
    let title: String
    let paymentSystemIcon: Image?
    let name: String
    let balance: String
    let descriptions: [String]
    var subscriptions: [ManageSubscriptionsUI.SubscriptionViewModel]
    
    var productViewModel: ProductViewModel {
        .init(image: image,
              title: title,
              name: name,
              balance: balance,
              descriptions: descriptions
        )
    }
}

struct ContentView: View {
    
    @ObservedObject var subscriptionViewModel: SubscriptionsViewModel
    
    var body: some View {
        
        ManagingSubscriptionsView(
            products: subscriptionViewModel.products,
            productView: { product in
                
                ProductView(viewModel: product.productViewModel)
                
            },
            searchView: {
                CancellableSearchBarView(
                    viewModel: subscriptionViewModel.searchViewModel,
                    textFieldConfig: .sample,
                    clearButtonLabel: { Image(systemName: "xmark") },
                    cancelButton: { Button("Cancel", action: {}) }
                )
            },
            emptyListView: {
                
                Color.clear
                    .overlay {
                        
                        Text("Empty List View")
                    }
            }
        )
        .padding(.top, 12)
    }
}

private extension TextFieldView.TextFieldConfig {
    
    static let sample: Self = .init(
        font: .systemFont(ofSize: 18),
        textColor: .black,
        tintColor: .red,
        backgroundColor: .clear,
        placeholderColor: .pink
    )
}

struct ContentView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        NavigationView {
            
            ContentView(subscriptionViewModel: .preview)
                .navigationBarTitleDisplayMode(.inline)
        }
    }
}

extension SubscriptionViewModel {
    
    static let sample: SubscriptionViewModel = .init(
        token: "Token",
        name: "Name",
        image: .init(systemName: "photo"),
        subtitle: "Subtitle",
        trash: .init(systemName: "trash"),
        onDelete: { _ in }
    )
}

extension SubscriptionsViewModel {
    
    static let preview: SubscriptionsViewModel = .init(
        products: [
            Product(
                image: .init(systemName: "creditcard"),
                title: "Счет списания",
                paymentSystemIcon: nil,
                name: "Карта банка",
                balance: "100 ₽",
                descriptions: ["3372"],
                subscriptions: [.sample]
            ),
            Product(
                image: .init(systemName: "creditcard"),
                title: "Счет списания",
                paymentSystemIcon: nil,
                name: "Счет банка",
                balance: "100 ₽",
                descriptions: ["3375"],
                subscriptions: [.sample]
            )
        ],
        searchViewModel: .init(
            initialState: .placeholder("Search subscriptions"),
            reducer: TransformingReducer(
                placeholderText: "Search subscriptions"
            ),
            keyboardType: .decimal
        ))
}
