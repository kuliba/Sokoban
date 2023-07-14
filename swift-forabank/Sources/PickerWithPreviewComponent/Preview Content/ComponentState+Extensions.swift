//
//  ComponentState+Extensions.swift
//  
//
//  Created by Andryusina Nataly on 09.06.2023.
//

import Foundation

public extension ComponentState {
    
    static let monthlyOne: Self = .monthly(
        .init(
            selection: OptionWithMapImage.oneWithHtml,
            options: .monthlyOptions
        )
    )
    
    static let yearlyOne: Self = .yearly(
        .init(
            selection: OptionWithMapImage.oneWithHtml,
            options: .yearlyOptions
        )
    )
}
