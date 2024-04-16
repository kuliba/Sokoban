//
//  DigitModelConfig+preview.swift
//  
//
//  Created by Igor Malyarov on 12.02.2024.
//

import UIPrimitives

extension DigitModelConfig {

    static let preview: Self = .init(
        digitConfig: .init(
            textFont: .largeTitle.bold(),
            textColor: .green
        ), 
        rectColor: .orange
    )
}
