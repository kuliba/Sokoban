//
//  CategoryPickerSectionContentViewConfig.swift
//  PayHubPreview
//
//  Created by Igor Malyarov on 21.08.2024.
//

import SharedConfigs
import SwiftUI

struct CategoryPickerSectionContentViewConfig: Equatable {
    
    let headerHeight: CGFloat
    let title: TitleConfig
    let titlePlaceholder: TitlePlaceholder
}

extension CategoryPickerSectionContentViewConfig {
    
    struct TitlePlaceholder: Equatable {
        
        let color: Color
        let radius: CGFloat
        let size: CGSize
    }
}
