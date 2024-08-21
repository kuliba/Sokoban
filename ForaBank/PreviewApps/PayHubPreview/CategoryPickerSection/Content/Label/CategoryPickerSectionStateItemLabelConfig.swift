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
    let placeholder: Placeholder
    let spacing: CGFloat
    let title: TextConfig
    let showAll: TitleConfig
}

extension CategoryPickerSectionStateItemLabelConfig {
    
    struct IconBackground: Equatable {
        
        let color: Color
        let roundedRect: RoundedRect
    }
    
    struct Placeholder: Equatable {
        
        let icon: RoundedRect
        let title: RoundedRect
        let spacing: CGFloat
    }
    
    struct RoundedRect: Equatable {
        
        let radius: CGFloat
        let size: CGSize
    }
}
