//
//  BannerPickerSectionStateItemViewConfig.swift
//  
//
//  Created by Andryusina Nataly on 11.09.2024.
//

import SwiftUI

public struct BannerPickerSectionStateItemViewConfig: Equatable {
    
    public let cornerRadius: CGFloat
    public let spacing: CGFloat
    public let size: CGSize
    
    public init(
        cornerRadius: CGFloat,
        spacing: CGFloat,
        size: CGSize
    ) {
        self.cornerRadius = cornerRadius
        self.spacing = spacing
        self.size = size
    }
}

