//
//  CreateDraftCollateralLoanApplicationConfig+Period.swift
//  
//
//  Created by Valentin Ozerov on 27.01.2025.
//

import SwiftUI
import OptionalSelectorComponent

extension CreateDraftCollateralLoanApplicationConfig {
    
    public struct Period {
        
        public let title: String
        public let viewConfig: OptionalSelectorViewConfig
        public let chevronViewConfig: ChevronViewConfig

        public init(
            title: String,
            viewConfig: OptionalSelectorViewConfig,
            chevronViewConfig: ChevronViewConfig
        ) {
            self.title = title
            self.viewConfig = viewConfig
            self.chevronViewConfig = chevronViewConfig
        }        
    }
}

extension CreateDraftCollateralLoanApplicationConfig.Period {
    
    static let preview = Self(
        title: "Срок кредита",
        viewConfig: .init(
            title: .init(
                text: "Срок кредита",
                config: .init(textFont: Font.system(size: 14), textColor: .title)
            ),
            search: .init(textFont: Font.system(size: 14), textColor: .primary),
            searchPlaceholder: "Поиск"
        ),
        chevronViewConfig: .init(color: .secondary, image: Image(systemName: "chevron.down"), size: 12)
    )
}

private extension Color {
    
    static let title: Self = .init(red: 0.6, green: 0.6, blue: 0.6)
}
