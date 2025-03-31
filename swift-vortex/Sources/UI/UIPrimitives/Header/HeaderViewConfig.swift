//
//  HeaderViewConfig.swift
//  
//
//  Created by Igor Malyarov on 30.03.2025.
//

import SharedConfigs
import SwiftUI

/// A configuration object defining the styling and layout properties for a header view.
public struct HeaderViewConfig: Equatable {
    
    /// The configuration for the back button image.
    public let backImage: BackImage
    /// The height of the header view.
    public let height: CGFloat
    /// The horizontal padding for the header view.
    public let hPadding: CGFloat
    /// The text configuration for the header title.
    public let title: TextConfig
    /// The text configuration for the header subtitle.
    public let subtitle: TextConfig
    /// The vertical spacing between title and subtitle.
    public let vSpacing: CGFloat
    
    /// Initializes a `HeaderViewConfig` with the specified style properties.
    public init(
        backImage: BackImage,
        height: CGFloat,
        hPadding: CGFloat,
        title: TextConfig,
        subtitle: TextConfig,
        vSpacing: CGFloat
    ) {
        self.backImage = backImage
        self.height = height
        self.hPadding = hPadding
        self.title = title
        self.subtitle = subtitle
        self.vSpacing = vSpacing
    }
}

extension HeaderViewConfig {
    
    /// A structure representing the appearance and dimensions of a back button image.
    public struct BackImage: Equatable {
        
        /// The image used for the back button.
        public let image: Image
        /// The color applied to the back button image.
        public let color: Color
        /// The frame size for the back button.
        public let frame: CGSize
        
        /// Initializes a `BackImage` with the specified image, color, and frame dimensions.
        public init(
            image: Image,
            color: Color,
            frame: CGSize
        ) {
            self.image = image
            self.color = color
            self.frame = frame
        }
    }
}
