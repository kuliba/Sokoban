//
//  CategoryPickerSectionContentViewConfig+iFora.swift
//  ForaBank
//
//  Created by Igor Malyarov on 26.08.2024.
//

import PayHubUI

extension CategoryPickerSectionContentViewConfig {
    
    static let iFora: Self = .init(
        headerHeight: 24,
        spacing: 16,
        title: .init(
            text: "Оплатить",
            config: .init(
                textFont: .textH2Sb20282(),
                textColor: .textSecondary
            )
        ),
        titlePlaceholder: .init(
            color: .gray.opacity(0.5),
            radius: 12,
            size: .init(width: 148, height: 18)
        )
    )
}
