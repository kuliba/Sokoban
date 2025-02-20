//
//  DetailCellViewConfig.swift
//  Vortex
//
//  Created by Igor Malyarov on 20.02.2025.
//

import SwiftUI
import SharedConfigs

struct DetailCellViewConfig: Equatable {
    
    let insets: EdgeInsets
    let imageSize: CGSize
    let imageTopPadding: CGFloat
    let hSpacing: CGFloat
    let vSpacing: CGFloat
    let title: TextConfig
    let value: TextConfig
}
