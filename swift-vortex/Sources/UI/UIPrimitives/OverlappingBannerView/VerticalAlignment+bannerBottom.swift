//
//  VerticalAlignment+bannerBottom.swift
//  
//
//  Created by Igor Malyarov on 29.03.2025.
//

import SwiftUI

/// Extension to create a custom vertical alignment for aligning views relative to a banner’s bottom edge.
/// Use this vertical alignment when you want to position content with an offset relative to the banner's bottom.
extension VerticalAlignment {
    
    static let bannerBottom: Self = .init(BannerBottomAlignment.self)
    
    private enum BannerBottomAlignment: AlignmentID {
        
        static func defaultValue(in context: ViewDimensions) -> CGFloat {
            
            context[.bottom]
        }
    }
}
