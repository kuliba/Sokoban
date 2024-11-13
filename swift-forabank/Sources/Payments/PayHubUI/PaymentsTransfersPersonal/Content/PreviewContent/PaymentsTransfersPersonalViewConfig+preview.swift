//
//  PaymentsTransfersPersonalViewConfig+preview.swift
//
//
//  Created by Igor Malyarov on 03.09.2024.
//

extension PaymentsTransfersPersonalViewConfig {
    
    static let preview: Self = .init(
        spacing: 32,
        titleSpacing: 16,
        title: .init(
            text: "Payments",
            config: .init(
                textFont: .title3.bold(),
                textColor: .black
            )
        )
    )
}
