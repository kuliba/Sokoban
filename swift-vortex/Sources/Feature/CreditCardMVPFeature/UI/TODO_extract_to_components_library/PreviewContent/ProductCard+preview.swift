//
//  ProductCard+preview.swift
//
//
//  Created by Igor Malyarov on 25.03.2025.
//

import Foundation

extension ProductCard {
    
    static func preview(
        limit: String = "!0 ₽",
        md5Hash: String = UUID().uuidString,
        options: [Option] = [
            .init(title: "!Открытие ", value: "!Бесплатно"),
            .init(title: "!Обслуживание ", value: "!Бесплатно"),
        ],
        title: String = "!Кредитная карта",
        subtitle: String = "!Бесплатное открытие и обслуживание"
    ) -> Self {
        
        return .init(limit: limit, md5Hash: md5Hash, options: options, title: title, subtitle: subtitle)
    }
}
