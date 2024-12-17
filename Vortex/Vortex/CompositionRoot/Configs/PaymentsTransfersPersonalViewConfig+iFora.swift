//
//  PaymentsTransfersPersonalViewConfig+iFora.swift
//  ForaBank
//
//  Created by Igor Malyarov on 03.09.2024.
//

import PayHubUI

extension PaymentsTransfersPersonalViewConfig {
    
    static let iFora: Self = .init(
        titleSpacing: 16,
        title: .init(
            text: "Платежи",
            config: .init(
                textFont: .textH1Sb24322(),
                textColor: .textSecondary
            ),
            leadingPadding: 20
        )
    )
}
