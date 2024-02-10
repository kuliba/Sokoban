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
    
    static func makeSubscriptionsViewModel(
        getProducts: @escaping () -> [SubscriptionsViewModel.Product],
        c2bSubscription: C2BSubscription?,
        scheduler: AnySchedulerOfDispatchQueue
    ) -> SubscriptionsViewModel {
        
        let products = getProducts()
        
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
            scheduler: scheduler
        )
    }
    
    static func getSubscriptionProducts(
        model: Model,
        onDelete: @escaping (SubscriptionViewModel.Token, String) -> Void,
        onDetail: @escaping (SubscriptionViewModel.Token) -> Void
    ) -> () -> [SubscriptionsViewModel.Product] {
        
        let items = model.subscriptions.value?.list ?? []
        
        return {
            
            items.compactMap { item in
                
                let product = model.allProducts.first { $0.id.description == item.productId }
                
                guard let product,
                      let balance = model.amountFormatted(
                        amount: product.balanceValue,
                        currencyCode: product.currency,
                        style: .fraction
                      ),
                      let icon = product.smallDesign.image
                else { return nil }
                
                let subscriptions = item.subscriptions.map {
                    
                    $0.makeSubscriptionViewModel(
                        model: model,
                        requestImage: {
                            
                            model.action.send(ModelAction.Dictionary.DownloadImages.Request(imagesIds: [$0]))
                        },
                        onDelete: onDelete,
                        onDetail: onDetail
                    )
                }
                
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
    
    func makeSubscriptionViewModel(
        model: Model,
        requestImage: @escaping (String) -> Void,
        onDelete: @escaping (SubscriptionViewModel.Token, String) -> Void,
        onDetail: @escaping (SubscriptionViewModel.Token) -> Void
    ) -> ManageSubscriptionsUI.SubscriptionViewModel {
        
        let image: SubscriptionViewModel.Icon
        
        let brandIcon = brandIcon
        
        #warning("reuse ImageCache")
        if let icon = model.images.value[brandIcon]?.image {
            
            image = .image(icon)
            
        } else {
            
            image = .default(.ic24ShoppingCart)
            requestImage(brandIcon)
        }
        
        return .init(
            token: subscriptionToken,
            name: brandName,
            image: image,
            subtitle: subscriptionPurpose,
            purposeTitle: cancelAlert,
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
