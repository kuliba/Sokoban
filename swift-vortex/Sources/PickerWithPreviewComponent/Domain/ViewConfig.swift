//
//  ViewConfig.swift
//
//
//  Created by Andryusina Nataly on 11.06.2023.
//

import SwiftUI

extension PickerWithPreviewContainerView {
    
    public struct ViewConfig: Equatable {
        
        public let fontPickerSegmentTitle: Font
        public let countinueButtonBackgroundColor: Color
        public let backgroundColor: Color
        
        public let leadingPadding: CGFloat
        public let trailingPadding: CGFloat

        public let navigationTitle: String
        
        public init(
            fontPickerSegmentTitle: Font,
            countinueButtonBackgroundColor: Color,
            backgroundColor: Color,
            leadingPadding: CGFloat = 20,
            trailingPadding: CGFloat = 19,
            navigationTitle: String = ""
        ) {
            self.fontPickerSegmentTitle = fontPickerSegmentTitle
            self.countinueButtonBackgroundColor = countinueButtonBackgroundColor
            self.backgroundColor = backgroundColor
            self.leadingPadding = leadingPadding
            self.trailingPadding = trailingPadding
            self.navigationTitle = navigationTitle
        }
    }
}
