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
        public let periodConfig: PeriodConfig

        public init(
            title: String,
            periodConfig: PeriodConfig
        ) {
            self.title = title
            self.periodConfig = periodConfig
        }
        
        public struct PeriodConfig {
            
            public let chevron: ChevronViewConfig
            public let selector: OptionalSelectorViewConfig
            
            public init(
                chevron: ChevronViewConfig,
                selector: OptionalSelectorViewConfig
            ) {
                self.chevron = chevron
                self.selector = selector
            }
        }
    }
}

extension CreateDraftCollateralLoanApplicationConfig.Period {
    
    static let preview = Self(
        title: "Срок кредита",
        periodConfig: .init(
            chevron: .init(color: .secondary, image: Image(systemName: "chevron.down"), size: 12),
            selector: .init(
                title: .init(
                    text: "Срок кредита",
                    config: .init(textFont: Font.system(size: 14), textColor: .title)
                ),
                search: .init(textFont: Font.system(size: 14), textColor: .primary),
                searchPlaceholder: ""
            )
        )
    )
}

private extension Color {
    
    static let title: Self = .init(red: 0.6, green: 0.6, blue: 0.6)
}
