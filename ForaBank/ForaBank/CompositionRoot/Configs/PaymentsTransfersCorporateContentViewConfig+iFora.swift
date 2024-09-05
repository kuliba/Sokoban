//
//  PaymentsTransfersCorporateContentViewConfig+iFora.swift
//  ForaBank
//
//  Created by Igor Malyarov on 04.09.2024.
//

import PayHubUI

extension PaymentsTransfersCorporateContentViewConfig {
    
    static let iFora: Self = .init(
        bannerSectionHeight: 178,
        header: .init(
            text: "Платежи",
            config: .init(
                textFont: .textH1Sb24322(),
                textColor: .textSecondary
            )
        ),
        headerTopPadding: 8,
        spacing: 16,
        stack: .init(top: 20, leading: 16, bottom: 0, trailing: 15),
        title: .init(
            text: "Перевести",
            config: .init(
                textFont: .textH2Sb20282(),
                textColor: .textSecondary
            )
        ),
        titleTopPadding: 16,
        transfersSectionHeight: 124
    )
}
