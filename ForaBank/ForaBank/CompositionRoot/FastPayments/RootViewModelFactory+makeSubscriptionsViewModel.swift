//
//  RootViewModelFactory+makeSubscriptionsViewModel.swift
//  ForaBank
//
//  Created by Igor Malyarov on 09.02.2024.
//

import SwiftUI
import ManageSubscriptionsUI
import TextFieldModel

extension RootViewModelFactory {
    
    typealias GetSubscriptionProducts = (@escaping OnSubscriptionDelete, @escaping OnSubscriptionDetail) -> [SubscriptionsViewModel.Product]
    typealias OnSubscriptionDelete = (SubscriptionViewModel.Token, String) -> Void
    typealias OnSubscriptionDetail = (SubscriptionViewModel.Token) -> Void
    
    func makeSubscriptionsViewModel(
        getProducts: @escaping GetSubscriptionProducts,
        c2bSubscription: C2BSubscription?
    ) -> UserAccountNavigationStateManager.MakeSubscriptionsViewModel {
        
        return { onDelete, onDetail in
            
            let products = getProducts(onDelete, onDetail)
            
            let emptyViewModel = SubscriptionsViewModel.EmptyViewModel(
                isEmpty: products.count == 0,
                c2bSubscription: c2bSubscription
            )
            
            let reducer = TransformingReducer(placeholderText: "Поиск")
            
            return .init(
                products: products,
                searchViewModel: .init(
                    initialState: .placeholder("Поиск"),
                    reducer: reducer,
                    keyboardType: .default
                ),
                emptyViewModel: emptyViewModel,
                configurator: .init(
                    backgroundColor: .mainColorsGrayLightest
                ),
                scheduler: self.schedulers.main
            )
        }
    }
    
    func getSubscriptionProducts(
        onDelete: @escaping OnSubscriptionDelete,
        onDetail: @escaping OnSubscriptionDetail
    ) -> [SubscriptionsViewModel.Product] {
        
        getSubscriptionProducts(
            items: model.subscriptions.value?.list ?? [],
            getProduct: model.product(forID:),
            getImage: { self.model.images.value[.init($0)]?.image },
            formatBalance: model.formatBalanceFraction(product:),
            makeSubscriptionViewModel: {
                
#warning("reuse ImageCache")
                return $0.makeSubscriptionViewModel(
                    getImage: { self.model.images.value[$0]?.image },
                    requestImage: {
                        
                        self.model.action.send(ModelAction.Dictionary.DownloadImages.Request(imagesIds: [$0]))
                    },
                    onDelete: onDelete,
                    onDetail: onDetail
                )
            }
        )
    }
    
    typealias ProductID = String
    typealias MakeSubscriptionViewModel = (C2BSubscription.ProductSubscription.Subscription) -> SubscriptionViewModel
    
    func getSubscriptionProducts(
        items: [C2BSubscription.ProductSubscription],
        getProduct: @escaping (ProductID) -> ProductData?,
        getImage: @escaping (MD5Hash) -> Image?,
        formatBalance: @escaping (ProductData) -> String?,
        makeSubscriptionViewModel: @escaping MakeSubscriptionViewModel
    ) -> [SubscriptionsViewModel.Product] {
        
        items.compactMap { item in
            
            guard let product = getProduct(item.productId),
                  let balance = formatBalance(product),
                  let icon = getImage(.init(product.smallDesignMd5hash))
            else { return nil }
            
            let subscriptions = item.subscriptions.map(makeSubscriptionViewModel)
            
            return .init(
                image: icon,
                title: item.productTitle,
                paymentSystemIcon: nil,
                name: product.displayName,
                balance: balance,
                descriptions: product.description,
                isLocked: product.isLocked,
                subscriptions: subscriptions
            )
        }
    }
}

private extension Model {
    
    func product(forID productID: String) -> ProductData? {
        
        allProducts.first { $0.id.description == productID }
    }
    
    func formatBalanceFraction(product: ProductData) -> String? {
        
        amountFormatted(
            amount: product.balanceValue,
            currencyCode: product.currency,
            style: .fraction
        )
    }
}

private extension SubscriptionsViewModel.EmptyViewModel {
    
    init(
        isEmpty: Bool,
        c2bSubscription: C2BSubscription?
    ) {
        let emptyTitle = c2bSubscription?.emptyList?.compactMap({ $0 }).joined(separator: "\n")
        let title = isEmpty ? emptyTitle : c2bSubscription?.emptySearch
        
        self.init(
            icon: isEmpty ? Image.ic24Trello : Image.ic24Search,
            title: title ?? "Нет совпадений"
        )
    }
}

private extension C2BSubscription.ProductSubscription.Subscription {
    
    typealias BrandIcon = String
    
    func makeSubscriptionViewModel(
        getImage: @escaping (BrandIcon) -> Image?,
        requestImage: @escaping (BrandIcon) -> Void,
        onDelete: @escaping (SubscriptionViewModel.Token, String) -> Void,
        onDetail: @escaping (SubscriptionViewModel.Token) -> Void
    ) -> ManageSubscriptionsUI.SubscriptionViewModel {
        
        let image: SubscriptionViewModel.Icon
        
        if let icon = getImage(brandIcon) {
            
            image = .image(icon)
            
        } else {
            
            image = .default(.ic24ShoppingCart)
            requestImage(brandIcon)
        }
        
        return .init(
            token: subscriptionToken,
            name: brandName,
            image: image,
            subtitle: subscriptionServiceName,
            purposeTitle: subscriptionPurpose,
            trash: .ic24Trash2,
            config: .init(
                headerFont: .textH4M16240(),
                subtitle: .textBodySR12160()
            ),
            onDelete: onDelete,
            onDetail: onDetail
        )
    }
}

private extension ProductData {
    
    var isLocked: Bool {
        
        guard let card = self as? ProductCardData
        else { return false }
        
        return card.isBlocked
    }
}
