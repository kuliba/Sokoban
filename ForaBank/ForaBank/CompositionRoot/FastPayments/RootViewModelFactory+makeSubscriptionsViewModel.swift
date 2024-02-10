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
        model: Model,
        onDelete: @escaping (SubscriptionViewModel.Token, String) -> Void,
        scheduler: AnySchedulerOfDispatchQueue
    ) -> SubscriptionsViewModel {
        
        let products = getSubscriptions(
            model: model,
            with: model.subscriptions.value?.list ?? [],
            onDelete: onDelete,
            detailAction: { token in
                
                model.action.send(ModelAction.C2B.GetC2BDetail.Request(token: token))
            }
        )
        
        let reducer = TransformingReducer(placeholderText: "Поиск")
        
        let emptyTitle = model.subscriptions.value?.emptyList?.compactMap({ $0 }).joined(separator: "\n")
        let emptySearchTitle = model.subscriptions.value?.emptySearch ?? "Нет совпадений"
        let titleCondition = (products.count == 0)
        let emptyViewModel = SubscriptionsViewModel.EmptyViewModel(
            icon: titleCondition ? Image.ic24Trello : Image.ic24Search,
            title: titleCondition ? (emptyTitle ?? "Нет совпадений") : emptySearchTitle
        )
        
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

    private static func getSubscriptions(
        model: Model,
        with items: [C2BSubscription.ProductSubscription],
        onDelete: @escaping (SubscriptionViewModel.Token, String) -> Void,
        detailAction: @escaping (SubscriptionViewModel.Token) -> Void
    ) -> [SubscriptionsViewModel.Product] {
        
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
                    onDelete: onDelete,
                    detailAction: detailAction
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

private extension C2BSubscription.ProductSubscription.Subscription {
    
    func makeSubscriptionViewModel(
        model: Model,
        onDelete: @escaping (SubscriptionViewModel.Token, String) -> Void,
        detailAction: @escaping (SubscriptionViewModel.Token) -> Void
    ) -> ManageSubscriptionsUI.SubscriptionViewModel {
        
        var image: SubscriptionViewModel.Icon = .default(.ic24ShoppingCart)
        
        let brandIcon = brandIcon
        
        #warning("reuse ImageCache")
        if let icon = model.images.value[brandIcon]?.image {
            
            image = .image(icon)
            
        } else {
            
            image = .default(.ic24ShoppingCart)
            model.action.send(ModelAction.Dictionary.DownloadImages.Request(imagesIds: [brandIcon]))
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
            detailAction: detailAction
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
