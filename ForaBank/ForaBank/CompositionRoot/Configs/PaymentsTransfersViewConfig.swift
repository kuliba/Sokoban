//
//  PaymentsTransfersViewConfig.swift
//  ForaBank
//
//  Created by Igor Malyarov on 03.09.2024.
//

import PayHubUI

extension PaymentsTransfersViewConfig {
    
    static let iFora: Self = .init(
        titleSpacing: 16,
        spacing: 32,
        title: .init(
            text: "Платежи",
            config: .init(
                textFont: .textH1Sb24322(),
                textColor: .textSecondary
            )
        )
    )
}
