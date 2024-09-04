//
//  PaymentsTransfersPersonalViewConfig+preview.swift
//
//
//  Created by Igor Malyarov on 03.09.2024.
//

import PayHubUI

extension PaymentsTransfersPersonalViewConfig {
    
    static let preview: Self = .init(
        titleSpacing: 16,
        spacing: 32,
        title: .init(
            text: "Payments",
            config: .init(
                textFont: .title3.bold(),
                textColor: .black
            )
        )
    )
}
