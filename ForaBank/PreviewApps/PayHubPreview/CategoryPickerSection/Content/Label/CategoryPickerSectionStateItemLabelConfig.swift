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
    let placeholderSpacing: CGFloat
    let placeholderRadius: CGFloat
    let placeholderSize: CGSize
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
