//
//  CreateDraftCollateralLoanApplicationConfig+City.swift
//  
//
//  Created by Valentin Ozerov on 27.01.2025.
//

import SwiftUI
import OptionalSelectorComponent

extension CreateDraftCollateralLoanApplicationConfig {
    
    public struct City {
        
        public let title: String
        public let cityConfig: CityConfig

        public init(
            title: String,
            cityConfig: CityConfig
        ) {
            self.title = title
            self.cityConfig = cityConfig
        }
        
        public struct CityConfig {
            
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

extension CreateDraftCollateralLoanApplicationConfig.City {
    
    static let preview = Self(
        title: "Город получения кредита",
        cityConfig: .init(
            chevron: .init(color: .secondary, image: Image(systemName: "chevron.down"), size: 12),
            selector: .init(
                title: .init(
                    text: "Город получения кредита",
                    config: .init(textFont: Font.system(size: 14), textColor: .title)
                ),
                search: .init(textFont: Font.system(size: 14), textColor: .primary),
                searchPlaceholder: "Поиск"
            )
        )
    )
}

private extension Color {
    
    static let title: Self = .init(red: 0.6, green: 0.6, blue: 0.6)
}
