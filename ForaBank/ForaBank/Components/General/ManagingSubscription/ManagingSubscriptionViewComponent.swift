//
//  ManagingSubscriptionView.swift
//  ForaBank
//
//  Created by Дмитрий Савушкин on 27.07.2023.
//

import ManageSubscriptionsUI
import SearchBarComponent
import TextFieldUI
import TextFieldComponent
import SwiftUI
import Combine

final class SubscriptionsViewModel: ObservableObject {
    
    @Published private(set) var products: [Product]
    @Published private(set) var notFilteredProducts: [Product]
    let searchViewModel: RegularFieldViewModel
    var emptyViewModel: EmptyViewModel
    let configurator: ManageSubscriptionsUI.ViewConfigurator
    
    init(
        products: [Product],
        searchViewModel: RegularFieldViewModel,
        emptyViewModel: EmptyViewModel,
        configurator: ManageSubscriptionsUI.ViewConfigurator,
        scheduler: AnySchedulerOfDispatchQueue = .makeMain()
    ) {
        
        self.products = products
        self.searchViewModel = searchViewModel
        self.emptyViewModel = emptyViewModel
        self.notFilteredProducts = products
        self.configurator = configurator
        
        Publishers.CombineLatest(
            $notFilteredProducts,
            searchViewModel.$state.map(\.text)
        )
        .map(SearchProductsMapper.map)
        .receive(on: scheduler)
        .assign(to: &$products)
    }
}

enum SearchProductsMapper {}

extension SearchProductsMapper {
    
    static func map(
        _ products: [SubscriptionsViewModel.Product],
        _ searchString: String?
    ) -> [SubscriptionsViewModel.Product] {
        
        guard let text = searchString,
              !text.isEmpty else {
            
            return products
        }
        
        var filteredProducts = [SubscriptionsViewModel.Product]()
        
        products.forEach({ product in
            
            let subscriptions = product.subscriptions.filter { $0.name.lowercased().contained(in: [text.lowercased()]) }
            if !subscriptions.isEmpty {
                
                filteredProducts.append(.init(
                    image: product.image,
                    title: product.title,
                    paymentSystemIcon: product.paymentSystemIcon,
                    name: product.name,
                    balance: product.balance,
                    descriptions: product.descriptions,
                    isLocked: product.isLocked,
                    subscriptions: subscriptions
                ))
            }
        })
        
        return filteredProducts
    }
}

extension SubscriptionsViewModel {
    
    struct Product: ManageSubscriptionsUI.Product {
        
        let id = UUID()
        let image: Image
        let title: String
        let paymentSystemIcon: Image?
        let name: String
        let balance: String
        let descriptions: [String]
        let isLocked: Bool
        var subscriptions: [ManageSubscriptionsUI.SubscriptionViewModel]
        
        var productViewModel: ManageSubscriptionsUI.ProductViewModel {
            .init(image: image,
                  title: title,
                  name: name,
                  balance: balance,
                  descriptions: descriptions,
                  isLocked: isLocked
            )
        }
    }
    
    struct EmptyViewModel {
        
        let icon: Image
        let title: String
    }
}

struct ManagingSubscriptionView: View {
    
    @ObservedObject var subscriptionViewModel: SubscriptionsViewModel
    let configurator: ManageSubscriptionsUI.ProductViewConfig
    let footerImage: Image
    let searchCancelAction: () -> Void
    
    var body: some View {
        
        ManagingSubscriptionsView(
            products: subscriptionViewModel.products,
            productView: { product in productView(product) },
            searchView: { searchView(searchCancelAction) },
            emptyListView: emptyListView,
            footerImage: footerImage,
            configurator: subscriptionViewModel.configurator
        )
        .padding(.top, 12)
    }
    
    private func productView(
        _ product: SubscriptionsViewModel.Product
    ) -> ManageSubscriptionsUI.ProductView {
        
        return ManageSubscriptionsUI.ProductView(
            viewModel: product.productViewModel,
            configurator: configurator
        )
    }
    
    private func searchView(
        _ searchCancelAction: @escaping () -> Void
    ) -> some View {

        DefaultCancellableSearchBarView(
            viewModel: subscriptionViewModel.searchViewModel,
            textFieldConfig: .black16,
            cancel: searchCancelAction
        )
    }
    
    private func emptyListView() -> some View {
        
        VStack(spacing: 24) {
            
            ZStack {
                
                Circle()
                    .foregroundColor(.mainColorsGrayLightest)
                    .frame(width: 64, height: 64, alignment: .center)
                
                subscriptionViewModel.emptyViewModel.icon
                    .foregroundColor(.iconGray)
                    .frame(width: 32, height: 32, alignment: .center)
            }
            
            Text(subscriptionViewModel.emptyViewModel.title)
                .font(.textH4R16240())
                .foregroundColor(.mainColorsGray)
                .multilineTextAlignment(.center)
        }
    }
}

//MARK: - Preview Content

extension SubscriptionsViewModel {
    
    static let preview: SubscriptionsViewModel = .init(
        products: [
            .sample1,
            .sample2
        ],
        searchViewModel: .init(
            initialState: .placeholder("Search subscriptions"),
            reducer: TransformingReducer(
                placeholderText: "Search subscriptions"
            ),
            keyboardType: .decimal
        ),
        emptyViewModel: .init(icon: Image.ic24Trello, title: "У вас нет активных подписок."),
        configurator: .init(backgroundColor: .red))
}

private extension TextFieldComponent.TextFieldView.TextFieldConfig {
    
    static let sample: Self = .init(
        font: .systemFont(ofSize: 18),
        textColor: .black,
        tintColor: .red,
        backgroundColor: .clear,
        placeholderColor: .pink
    )
}

private extension SubscriptionViewModel {
    
    static let sample: SubscriptionViewModel = .init(
        token: "Token",
        name: "Name",
        image: .image(.init(systemName: "photo")),
        subtitle: "Subtitle",
        purposeTitle: "Cancel alert",
        trash: .init(systemName: "trash"),
        config: .init(headerFont: .body, subtitle: .subheadline),
        onDelete: { _,_ in },
        onDetail: { _ in }
    )
}

private extension SubscriptionsViewModel.Product {
    
    static let sample1 = SubscriptionsViewModel.Product(
        image: .init(systemName: "creditcard"),
        title: "Счет списания",
        paymentSystemIcon: nil,
        name: "Карта банка",
        balance: "100 ₽",
        descriptions: ["3372"],
        isLocked: false,
        subscriptions: [.sample]
    )
    
    static let sample2 = SubscriptionsViewModel.Product(
        image: .init(systemName: "creditcard"),
        title: "Счет списания",
        paymentSystemIcon: nil,
        name: "Счет банка",
        balance: "100 ₽",
        descriptions: ["3375"],
        isLocked: true,
        subscriptions: [.sample]
    )
}
