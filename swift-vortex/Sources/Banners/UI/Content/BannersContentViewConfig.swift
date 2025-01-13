//
//  BannersContentViewConfig.swift
//  
//
//  Created by Andryusina Nataly on 17.09.2024.
//

import Foundation

public struct BannersContentViewConfig: Equatable {
    
    public let bannerSectionHeight: CGFloat
    public let spacing: CGFloat
    
    public init(
        bannerSectionHeight: CGFloat,
        spacing: CGFloat
    ) {
        self.bannerSectionHeight = bannerSectionHeight
        self.spacing = spacing
    }
}
