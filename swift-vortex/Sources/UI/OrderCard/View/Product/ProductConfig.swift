//
//  ProductConfig.swift
//  
//
//  Created by Igor Malyarov on 09.02.2025.
//

import SharedConfigs
import SwiftUI

struct ProductConfig {
    
    let padding: CGFloat
    let title: TextConfig
    let subtitle: TextConfig
    let optionTitle: TextConfig
    let optionSubtitle: TextConfig
    let openOptionTitle: String = "Открытие"
    let serviceOptionTitle: String = "Стоимость обслуживания"
    let shimmeringColor: Color
    let orderOptionIcon: Image
    let cornerRadius: CGFloat
    let background: Color
}
