//
//  CategoryPickerSectionStateItemLabelConfig.swift
//  PayHubPreview
//
//  Created by Igor Malyarov on 21.08.2024.
//

import SharedConfigs
import SwiftUI

struct CategoryPickerSectionStateItemLabelConfig: Equatable {
    
    let iconBackground: IconBackground
    let iconSize: CGSize
    let spacing: CGFloat
    let title: TextConfig
    let showAll: TitleConfig
}

extension CategoryPickerSectionStateItemLabelConfig {
    
    struct IconBackground: Equatable {
        
        let color: Color
        let radius: CGFloat
        let size: CGSize
    }
}

extension CategoryPickerSectionStateItemLabelConfig {
    
    static let preview: Self = .init(
        iconBackground: .init(
            color: .gray.opacity(0.1), // main colors/Gray lightest,
            radius: 8,
            size: .init(width: 48, height: 48)
        ),
        iconSize: .init(width: 24, height: 24),
        spacing: 16,
        title: .init(textFont: .headline, textColor: .green),
        showAll: .init(
            text: "show all".uppercased(),
            config: .init(textFont: .caption, textColor: .blue)
        )
    )
}
