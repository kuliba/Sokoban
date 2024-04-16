//
//  Subscription+preview.swift
//  
//
//  Created by Igor Malyarov on 11.02.2024.
//

extension GetC2BSubResponse.Details.ProductSubscription.Subscription {
    
    static let preview: Self = .init(
        token: "161fda956d884cf5b836d5642452044b",
        brandIcon: .svg("b8b31e25a275e3f04ae189f4a538536a"),
        brandName: "Цветы  у дома",
        purpose: "Оплата за доставку цветов",
        cancelAlert: "Вы действительно хотите отключить подписку Цветы  у дома?"
    )
}
