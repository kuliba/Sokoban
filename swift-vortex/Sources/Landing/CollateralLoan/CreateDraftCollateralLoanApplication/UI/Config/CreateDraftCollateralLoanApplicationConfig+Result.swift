//
//  CreateDraftCollateralLoanApplicationConfig+Result.swift
//
//
//  Created by Valentin Ozerov on 25.02.2025.
//

import SwiftUI

extension CreateDraftCollateralLoanApplicationConfig {
    
    public struct Result {
        
        public let titles: Titles
        public let icons: Icons
        
        public init(
            titles: Titles,
            icons: Icons
        ) {
            self.titles = titles
            self.icons = icons
        }
        
        public struct Titles {
            
            public let productName: String
            public let period: String
            public let percent: String
            public let amount: String
            public let collateralType: String
            public let city: String

            public init(
                productName: String,
                period: String,
                percent: String,
                amount: String,
                collateralType: String,
                city: String
            ) {
                self.productName = productName
                self.period = period
                self.percent = percent
                self.amount = amount
                self.collateralType = collateralType
                self.city = city
            }
        }
        
        public struct Icons {
            
            public let more: Image
            public let car: Image
            public let home: Image
            
            public init(
                more: Image,
                car: Image,
                home: Image
            ) {
                self.more = more
                self.car = car
                self.home = home
            }
        }
    }
}

extension CreateDraftCollateralLoanApplicationConfig.Result {
    
    static let preview = Self(
        titles: .preview,
        icons: .preview
    )
}

extension CreateDraftCollateralLoanApplicationConfig.Result.Titles {
    
    static let preview = Self(
        productName: "Наименование кредита",
        period: "Срок кредита",
        percent: "Процентная ставка",
        amount: "Сумма кредита",
        collateralType: "Тип залога",
        city: "Город получения кредита"
    )
}

extension CreateDraftCollateralLoanApplicationConfig.Result.Icons {
    
    static let preview = Self(
        more: .iconPlaceholder,
        car: .iconPlaceholder,
        home: .iconPlaceholder
    )
}
