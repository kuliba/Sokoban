//
//  PaymentsTransfersCorporateContentViewConfig+preview.swift
//
//
//  Created by Igor Malyarov on 04.09.2024.
//

extension PaymentsTransfersCorporateContentViewConfig {
    
    static let preview: Self = .init(
        bannerSectionHeight: 178,
        header: .init(
            text: "Payments",
            config: .init(
                textFont: .title2.bold(),
                textColor: .pink
            )
        ),
        headerTopPadding: 8,
        spacing: 16,
        stack: .init(top: 20, leading: 16, bottom: 0, trailing: 15),
        title: .init(
            text: "Transfers",
            config: .init(
                textFont: .title3.bold(),
                textColor: .orange
            )
        ),
        titleTopPadding: 16
    )
}
