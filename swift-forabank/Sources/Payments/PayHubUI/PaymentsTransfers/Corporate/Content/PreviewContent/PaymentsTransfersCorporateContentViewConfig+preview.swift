//
//  PaymentsTransfersCorporateContentViewConfig+preview.swift
//
//
//  Created by Igor Malyarov on 04.09.2024.
//

extension PaymentsTransfersCorporateContentViewConfig {
    
    static let preview: Self = .init(
        header: .init(
            text: "Payments",
            config: .init(
                textFont: .title2,
                textColor: .pink
            )
        ),
        headerTopPadding: 8,
        spacing: 16,
        title: .init(
            text: "Transfers",
            config: .init(
                textFont: .title3,
                textColor: .orange
            )
        ),
        titleTopPadding: 16
    )
}
