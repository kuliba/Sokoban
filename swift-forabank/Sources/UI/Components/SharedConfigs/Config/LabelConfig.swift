//
//  LabelConfig.swift
//
//
//  Created by Igor Malyarov on 13.11.2024.
//

import SwiftUI

public struct LabelConfig: Equatable {
    
    public let imageConfig: ImageConfig
    public let spacing: CGFloat
    public let textConfig: TextConfigWithAlignment
    
    public init(
        imageConfig: ImageConfig,
        spacing: CGFloat,
        textConfig: TextConfigWithAlignment
    ) {
        self.imageConfig = imageConfig
        self.spacing = spacing
        self.textConfig = textConfig
    }
    
    public struct ImageConfig: Equatable {
        
        public let color: Color
        public let image: Image
        public let backgroundColor: Color
        public let backgroundSize: CGSize
        public let size: CGSize
        
        public init(
            color: Color,
            image: Image,
            backgroundColor: Color,
            backgroundSize: CGSize,
            size: CGSize
        ) {
            self.color = color
            self.image = image
            self.backgroundColor = backgroundColor
            self.backgroundSize = backgroundSize
            self.size = size
        }
    }
}
